/datum/game_mode/crash
	name = "Crash"
	config_tag = "Crash"
	required_players = 3
	flags_round_type = MODE_INFESTATION|MODE_FOG_ACTIVATED
	flags_landmarks = MODE_LANDMARK_SPAWN_XENO_TUNNELS|MODE_LANDMARK_SPAWN_MAP_ITEM

	round_end_states = list(MODE_CRASH_X_MAJOR, MODE_CRASH_M_MAJOR, MODE_CRASH_X_MINOR, MODE_CRASH_M_MINOR, MODE_CRASH_DRAW_DEATH)

	// Round end conditions
	var/shuttle_landed = FALSE
	var/marines_evac = FALSE
	var/planet_nuked = FALSE

	// Shuttle details
	var/shuttle_id = "tgs_canterbury"
	var/obj/docking_port/mobile/crashmode/shuttle

	// Round start info
	var/starting_squad = "Alpha"
	var/latejoin_tally		= 0
	var/latejoin_larva_drop = 0


/datum/game_mode/crash/New()
	. = ..()
	// All marine roles, MD, Synth, and FC
	valid_job_types = subtypesof(/datum/job/marine) + list(
		/datum/job/medical/professor,
		/datum/job/civilian/synthetic,
		/datum/job/command/fieldcommander
	)


/datum/game_mode/crash/can_start()
	. = ..()
	// Check if enough players have signed up for xeno & queen roles.
	init_scales()
	var/ruler = initialize_xeno_leader()
	var/xenos = initialize_xenomorphs()
	

	if(!ruler && !xenos) // we need at least 1
		return FALSE
	return TRUE

/datum/game_mode/crash/proc/init_scales()
	latejoin_larva_drop = CONFIG_GET(number/latejoin_larva_required_num)
	xeno_starting_num = max(round(GLOB.ready_players / (CONFIG_GET(number/xeno_number) + CONFIG_GET(number/xeno_coefficient) * GLOB.ready_players)), xeno_required_num)

	var/current_smartgunners = 0
	var/maximum_smartgunners = CLAMP(GLOB.ready_players / CONFIG_GET(number/smartgunner_coefficient), 1, 4)
	var/current_specialists = 0
	var/maximum_specialists = CLAMP(GLOB.ready_players / CONFIG_GET(number/specialist_coefficient), 1, 4)

	var/datum/job/SG = SSjob.GetJobType(/datum/job/marine/smartgunner)
	SG.total_positions = maximum_smartgunners

	var/datum/job/SP = SSjob.GetJobType(/datum/job/marine/specialist)
	SP.total_positions = maximum_specialists

	for(var/i in SSjob.squads)
		var/datum/squad/S = SSjob.squads[i]
		if(current_specialists >= maximum_specialists)
			S.max_specialists = 0
		else
			S.max_specialists = 1
			current_specialists++
		if(current_smartgunners >= maximum_smartgunners)
			S.max_smartgun = 0
		else
			S.max_smartgun = 1
			current_smartgunners++

/datum/game_mode/crash/pre_setup()
	. = ..()

	// Spawn the ship
	if(!SSmapping.shuttle_templates[shuttle_id])
		CRASH("Shuttle [shuttle_id] wasn't found and can't be loaded")
		return FALSE

	var/datum/map_template/shuttle/ST = SSmapping.shuttle_templates[shuttle_id]
	var/obj/docking_port/stationary/L = SSshuttle.getDock("canterbury_loadingdock")
	shuttle = SSshuttle.action_load(ST, L)

	// Reset all spawnpoints after spawning the ship
	GLOB.marine_spawns_by_job = shuttle.marine_spawns_by_job

	GLOB.jobspawn_overrides = list()
	GLOB.latejoin = shuttle.latejoins
	GLOB.latejoin_cryo = shuttle.latejoins
	GLOB.latejoin_gateway = shuttle.latejoins
	
	var/list/validdocks = list()
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(!shuttle.check_dock(S, silent=TRUE))
			continue
		validdocks += S.name

	var/dock = pick(validdocks)

	var/obj/docking_port/stationary/target
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(S.name == dock)
			target = S
			break

	if(!target)
		CRASH("Unable to get a valid shuttle target!")
		return
	addtimer(CALLBACK(src, .proc/crash_shuttle, target), 10 MINUTES)

	// Create xenos
	var/number_of_xenos = length(xenomorphs)
	var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
	for(var/i in xenomorphs)
		var/datum/mind/M = i
		if(M.assigned_role == ROLE_XENO_QUEEN)
			transform_ruler(M, number_of_xenos > HN.xenos_per_queen)
		else
			transform_xeno(M)


/datum/game_mode/crash/setup()
	SSjob.DivideOccupations() 

	// For each player that has an assigned squad set it to alpha
	for(var/i in GLOB.new_player_list)
		var/mob/new_player/player = i
		if(player.ready && player.mind?.assigned_squad)
			player.mind.assigned_squad = SSjob.squads[starting_squad]
			
	create_characters() //Create player characters
	collect_minds()
	reset_squads()
	equip_characters()
	transfer_characters()	//transfer keys to the new mobs

	return TRUE


/datum/game_mode/crash/post_setup()
	. = ..()
	var/list/xeno_silo_spawns = GLOB.xeno_resin_silo_turfs.Copy()
	for(var/i in 1 to 3)
		var/turf/loc_to_spawn_silo = pick(xeno_silo_spawns)
		new /obj/structure/resin/silo(loc_to_spawn_silo)
		xeno_silo_spawns -= loc_to_spawn_silo

	for(var/i in GLOB.shuttle_controls_list)
		var/obj/machinery/computer/shuttle/shuttle_control/computer_to_disable
		computer_to_disable.machine_stat |= BROKEN
		computer_to_disable.update_icon()

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_CRASH)

	addtimer(CALLBACK(src, .proc/add_larva), 10 MINUTES, TIMER_LOOP)


/datum/game_mode/crash/announce()
	to_chat(world, "<span class='round_header'>The current map is - [SSmapping.configs[GROUND_MAP].map_name]!</span>")
	priority_announce("Scheduled for landing in T-10 Minutes. Prepare for landing. Known hostiles near LZ. Detonation Protocol Active, planet disposable. Marines disposable.", type = ANNOUNCEMENT_PRIORITY)
	playsound(shuttle, 'sound/machines/warning-buzzer.ogg', 75, 0, 30)
	

/datum/game_mode/crash/proc/add_larva()
	var/list/living_player_list = count_humans_and_xenos(count_ssd = TRUE)
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2] + HS.stored_larva
	if(!num_xenos)
		return respawn_xenos(num_humans)
	var/marines_per_xeno = num_humans / num_xenos
	switch(marines_per_xeno)
		if(0)
			return check_finished() //No more marines.
		if(0 to 3) //Xenos grow up until they are a third the number of marines.
			return
		if(3 to 4)
			HS.stored_larva++
		if(4 to 5)
			HS.stored_larva += min(2, round(num_humans * 0.25)) //Two, unless there are less than 10 marines.
		else //If there's more than 5 marines per xenos, then xenos gain larvas to fill the gap.
			HS.stored_larva += CLAMP(round(num_humans * 0.2), 1, num_humans - num_xenos)


/datum/game_mode/crash/proc/respawn_xenos(num_humans)
	if(!length(GLOB.xeno_resin_silos))
		return FALSE //RIP benos.
	var/datum/hive_status/normal/xeno_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(xeno_hive.stored_larva)
		return TRUE //No need for respawns nor to end the game. They can use their burrowed larvas.
	var/new_xeno_batch = min(1, round(num_humans * 0.2))
	for(var/i in new_xeno_batch)
		var/obj/structure/resin/silo/spawn_point = pick(GLOB.xeno_resin_silos)
		var/mob/living/carbon/xenomorph/larva/new_xeno = new /mob/living/carbon/xenomorph/larva(spawn_point.loc)

		// Try to find someone for the xeno
		var/xeno_candidate = get_alien_candidate()
		if(!xeno_candidate)
			new_xeno.visible_message("<span class='xenodanger'>A larva suddenly burrows out of the ground!</span>")
			continue

		transfer_xeno(xeno_candidate, new_xeno)
		new_xeno.visible_message("<span class='xenodanger'>A larva suddenly burrows out of the ground!</span>",
		"<span class='xenodanger'>We burrow out of the ground and awaken from our slumber. For the Hive!</span>")
		
	return TRUE


/datum/game_mode/crash/proc/crash_shuttle(obj/docking_port/stationary/target)
	shuttle.crashing = TRUE
	SSshuttle.moveShuttleToDock(shuttle.id, target, FALSE) // FALSE = instant arrival
	shuttle_landed = TRUE

	announce_bioscans(TRUE, 0, FALSE, TRUE) // Announce exact information to the xenos.
	addtimer(CALLBACK(src, .proc/announce_bioscans, TRUE, 0, FALSE, TRUE), 5 MINUTES, TIMER_LOOP)


/datum/game_mode/crash/check_finished()
	if(round_finished)
		return TRUE

	if(!shuttle_landed)
		return FALSE

	var/list/living_player_list = count_humans_and_xenos()
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2]

	if(num_humans && !planet_nuked)
		if(!num_xenos)
			if(respawn_xenos(num_humans))
				return FALSE //Xenos keep respawning for like an hour or so.
		else
			if(num_humans / num_xenos > 5)
				add_larva()
			return FALSE

	var/list/grounded_living_player_list = count_humans_and_xenos(SSmapping.levels_by_any_trait(list(ZTRAIT_GROUND)))
	var/num_grounded_humans = grounded_living_player_list[1]
	
	var/victory_options = (num_humans == 0 && num_xenos == 0 || (planet_nuked && !marines_evac)) 						<< 0 // Draw, for all other reasons
	victory_options |= (!planet_nuked && num_humans == 0 && num_xenos > 0) 												<< 1 // XENO Major (All marines killed)
	victory_options |= (marines_evac && !planet_nuked) 																	<< 2 // XENO Minor (Marines evac'd )
	victory_options |= (planet_nuked && (num_humans == 0 || num_grounded_humans > 0)) 									<< 3 // Marine minor (Planet nuked, some human left on planet)
	victory_options |= ((marines_evac && planet_nuked && num_grounded_humans == 0) || num_xenos == 0 && num_humans > 0) << 4 // Marine Major (Planet nuked, marines evac, or they wiped the xenos out)

	switch(victory_options)
		if(CRASH_DRAW)
			message_admins("Round finished: [MODE_CRASH_DRAW_DEATH]")
			round_finished = MODE_CRASH_DRAW_DEATH 
		if(CRASH_XENO_MAJOR)
			message_admins("Round finished: [MODE_CRASH_X_MAJOR]")
			round_finished = MODE_CRASH_X_MAJOR 
		if(CRASH_XENO_MINOR)
			message_admins("Round finished: [MODE_CRASH_X_MINOR]")
			round_finished = MODE_CRASH_X_MINOR 
		if(CRASH_MARINE_MINOR)
			message_admins("Round finished: [MODE_CRASH_M_MINOR]")
			round_finished = MODE_CRASH_M_MINOR 
		if(CRASH_MARINE_MAJOR)
			message_admins("Round finished: [MODE_CRASH_M_MAJOR]")
			round_finished = MODE_CRASH_M_MAJOR 

	return FALSE


/datum/game_mode/crash/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|[round_finished]|</span>")
	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the TGS Cantebury and their struggle on [SSmapping.configs[GROUND_MAP].map_name].</span>")
	
	// Music
	var/xeno_track
	var/human_track
	switch(round_finished)
		if(MODE_CRASH_X_MAJOR)
			xeno_track = pick('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg')
			human_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
		if(MODE_CRASH_M_MAJOR)
			xeno_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
			human_track = pick('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg')
		if(MODE_CRASH_X_MINOR)
			xeno_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
			human_track = pick('sound/theme/neutral_melancholy1.ogg','sound/theme/neutral_melancholy2.ogg')
		if(MODE_CRASH_M_MINOR)
			xeno_track = pick('sound/theme/neutral_melancholy1.ogg','sound/theme/neutral_melancholy2.ogg')
			human_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
		if(MODE_CRASH_DRAW_DEATH)
			xeno_track = pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg') 
			human_track = pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg')

	for(var/i in GLOB.xeno_mob_list)
		var/mob/M = i
		SEND_SOUND(M, xeno_track)

	for(var/i in GLOB.human_mob_list)
		var/mob/M = i
		SEND_SOUND(M, human_track)

	for(var/i in GLOB.observer_list)
		var/mob/M = i
		if(ishuman(M.mind.current))
			SEND_SOUND(M, human_track)
			continue

		if(isxeno(M.mind.current))
			SEND_SOUND(M, xeno_track)
			continue

		SEND_SOUND(M, pick('sound/misc/gone_to_plaid.ogg', 'sound/misc/good_is_dumb.ogg', 'sound/misc/hardon.ogg', 'sound/misc/surrounded_by_assholes.ogg', 'sound/misc/outstanding_marines.ogg', 'sound/misc/asses_kicked.ogg'))

	
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

	announce_medal_awards()
	announce_round_stats()



/datum/game_mode/crash/attempt_to_join_as_larva(mob/xeno_candidate)
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	return HS.attempt_to_spawn_larva(xeno_candidate)


/datum/game_mode/crash/spawn_larva(mob/xeno_candidate, mob/living/carbon/xenomorph/mother)
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	return HS.spawn_larva(xeno_candidate, mother)


/datum/game_mode/crash/AttemptLateSpawn(mob/M, rank)
	if(!isnewplayer(M))
		return
	var/mob/new_player/NP = M
	if(!NP.IsJobAvailable(rank))
		to_chat(usr, "<span class='warning'>Selected job is not available.<spawn>")
		return
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished!<spawn>")
		return
	if(!GLOB.enter_allowed)
		to_chat(usr, "<span class='warning'>Spawning currently disabled, please observe.<spawn>")
		return
	if(!SSjob.AssignRole(NP, rank, TRUE))
		to_chat(usr, "<span class='warning'>Failed to assign selected role.<spawn>")
		return

	// reset their squad to the correct squad for the gamemode.
	if(rank in GLOB.jobs_marines)
		NP.mind.assigned_squad = SSjob.squads[starting_squad]

	NP.close_spawn_windows()
	NP.spawning = TRUE

	var/mob/living/character = NP.create_character(TRUE)	//creates the human and transfers vars and mind
	var/equip = SSjob.EquipRank(character, rank, TRUE)
	if(isliving(equip))	//Borgs get borged in the equip, so we need to make sure we handle the new mob.
		character = equip

	var/datum/job/job = SSjob.GetJob(rank)

	if(job && !job.override_latejoin_spawn(character))
		SSjob.SendToLateJoin(character)

	GLOB.datacore.manifest_inject(character)
	SSticker.minds += character.mind

	handle_late_spawn(character)

	qdel(NP)


/datum/game_mode/crash/handle_late_spawn()
	var/datum/game_mode/crash/GM = SSticker.mode
	GM.latejoin_tally++

	if(GM.latejoin_larva_drop && GM.latejoin_tally >= GM.latejoin_larva_drop)
		GM.latejoin_tally -= GM.latejoin_larva_drop
		var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
		HS.stored_larva++


/datum/game_mode/crash/mode_new_player_panel(mob/new_player/NP)

	var/output = "<div align='center'>"
	output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=show_preferences'>Setup Character</A></p>"

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		output += "<p>\[ [NP.ready? "<b>Ready</b>":"<a href='byond://?src=\ref[src];lobby_choice=ready'>Ready</a>"] | [NP.ready? "<a href='byond://?src=[REF(NP)];lobby_choice=ready'>Not Ready</a>":"<b>Not Ready</b>"] \]</p>"
	else
		output += "<a href='byond://?src=[REF(NP)];lobby_choice=manifest'>View the Crew Manifest</A><br><br>"
		output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=late_join'>Join the TGMC!</A></p>"
		output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=late_join_xeno'>Join the Hive!</A></p>"

	output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=observe'>Observe</A></p>"

	output += append_player_votes_link(NP)

	output += "</div>"

	var/datum/browser/popup = new(NP, "playersetup", "<div align='center'>New Player Options</div>", 240, 300)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(FALSE)

	return TRUE
