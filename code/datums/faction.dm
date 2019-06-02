/*
This file defines factions within TGMC.

Original concept by LaKiller8
Squads would be: fully modular.
There would be a determined amount of them at the start of the round based on pop to make things go smoothly without command. But, command could create anywhere between 1-4(possibly 5) squads via a squad management console.
They would be able to choose a custom name for that squad (user input)
And a color from a list(since overlays would be hardcoded) of like 10
There would be no transfer restrictions between squads. THere would be a predetermined amount of available roles in total (like SL, but anyone could be the aSL, this would tie in nicely via the job subsystem)
You could also toggle the squad for latejoins - there would always have to be at least one that people could join
*/

// Defined list of colors valid for factions as limited by the UI.

#define HAS_TRACKING 			(1 << 1) // If this faction should setup SSdirection
#define CAN_REASSIGN_LEADER 	(1 << 2) // If this squad is able to change the leader

GLOBAL_LIST_INIT(valid_faction_colors, list("#e61919","#ffc32d","#c864c8","#4148c8"))
GLOBAL_LIST_EMPTY(all_factions)



/datum/faction
	var/id								// Internal ID for sorting and references ?
	var/name = "unnamed faction"		// Display name of the squad
	var/color = "#ffffff"				// Color for identification: helmets, etc.

	var/mob/leader
	var/list/mob/members[0]
	var/list/datum/faction/subfactions[0]

	var/flag = NONE						// By default nothing is enabled for factions
	var/tracking_id = null 				// Use in reference with SSdirection

	var/datum/faction/parent = null		// Parent faction, if any

/datum/faction/New()
	GLOB.all_factions += src

	if (CHECK_BITFIELD(flag, HAS_TRACKING) && !tracking_id)
		tracking_id = SSdirection.init_faction(src)

/datum/faction/Destroy()
	GLOB.all_factions -= src

/datum/faction/proc/reset()
	return

/datum/faction/proc/on_member_join(mob/M)
	SSdirection.start_tracking(tracking_id, M)
	return

/datum/faction/proc/on_member_leave(mob/M)
	SSdirection.stop_tracking(tracking_id, M)
	return

/datum/faction/proc/on_leader_changed(mob/M)
	SSdirection.set_leader(tracking_id, M)
	return

/datum/faction/proc/add_member(mob/M)
	if(!istype(M))
		return FALSE

	if(M.faction && M.faction == src)
		return TRUE

	// M.faction?.remove_member(src)
	M.faction = src
	members += M

	on_member_join(M)

	return TRUE

/datum/faction/proc/remove_member(mob/M)
	if(!istype(M))
		return FALSE

	if(M.faction && M.faction != src)
		return FALSE

	M.faction = null
	members -= M

	on_member_leave(M)

	return TRUE

/datum/faction/proc/set_leader(mob/M)
	if(!istype(M) || leader == M)
		return FALSE

	leader = M

	on_leader_changed(M)

	return TRUE

/datum/faction/proc/get_subfactions()
	return subfactions.Copy()


/datum/faction/proc/create_named_subfaction(faction_name)
	var/datum/faction/F = new
	F.name = faction_name
	F.parent = src
	subfactions += F




// Use for Xenos
/datum/faction/hive
	var/flags = HAS_TRACKING

/datum/faction/hive/normal
	name = "Normal Hive"

/datum/faction/hive/corrupt
	name = "Corrupt Hive"

/datum/faction/hive/delta
	name = "Delta Hive"

/datum/faction/hive/beta
	name = "Beta Hive"

/datum/faction/hive/zeta
	name = "Zeta Hive"


// Use for shipside marines
// This is currently the dump for the original squad.dm stuff and will require a cleanup later.
/datum/faction/marine
	var/flags = HAS_TRACKING
	var/mob/overwatch_officer
	var/radio_freq

	// limits
	var/num_engineers = 0
	var/num_medics = 0
	var/num_smartgun = 0
	var/num_specialists = 0
	var/num_leaders = 0

	// Extra access
	var/list/access[0]

	// OB related
	var/list/squad_laser_targets[0]
	var/list/squad_orbital_beacons[0]

	var/primary_objective = null //Text strings
	var/secondary_objective = null

	var/supply_cooldown = 0 //Cooldown for supply drops
	var/obj/item/squad_beacon/sbeacon = null
	var/obj/structure/supply_drop/drop_pad = null


/datum/faction/marine/reset()
	num_engineers = 0
	num_medics = 0
	num_smartgun = 0
	num_specialists = 0
	num_leaders = 0



/datum/faction/marine/alpha
	id = ALPHA_SQUAD
	name = "Alpha"
	radio_freq = FREQ_ALPHA

/datum/faction/marine/bravo
	id = BRAVO_SQUAD
	name = "Bravo"
	radio_freq = FREQ_BRAVO

/datum/faction/marine/charlie
	id = CHARLIE_SQUAD
	name = "Charlie"
	radio_freq = FREQ_CHARLIE

/datum/faction/marine/delta
	id = DELTA_SQUAD
	name = "Delta"
	radio_freq = FREQ_DELTA


// Misc faction for neutral mobs
/datum/faction/neutral
	name = "Unknown"




/datum/faction/marine/proc/remove_leader(killed)
	var/mob/living/carbon/human/old_lead = leader
	leader = null
	SSdirection.clear_leader(tracking_id)
	if(old_lead.mind.assigned_role)
		if(old_lead.mind.cm_skills)
			if(old_lead.mind.assigned_role == ("Squad Specialist" || "Squad Engineer" || "Squad Corpsman" || "Squad Smartgunner"))
				old_lead.mind.cm_skills.leadership = SKILL_LEAD_BEGINNER

			else if(old_lead.mind == "Squad Leader")
				if(!leader_killed)
					old_lead.mind.cm_skills.leadership = SKILL_LEAD_NOVICE
			else
				old_lead.mind.cm_skills.leadership = SKILL_LEAD_NOVICE

		old_lead.update_action_buttons()

	if(!old_lead.mind || old_lead.mind.assigned_role != "Squad Leader" || !leader_killed)
		if(istype(old_lead.wear_ear, /obj/item/radio/headset/almayer/marine))
			var/obj/item/radio/headset/almayer/marine/R = old_lead.wear_ear
			if(istype(R.keyslot, /obj/item/encryptionkey/squadlead))
				qdel(R.keyslot)
				R.keyslot = null
			else if(istype(R.keyslot2, /obj/item/encryptionkey/squadlead))
				qdel(R.keyslot2)
				R.keyslot2 = null
			R.recalculateChannels()
		if(istype(old_lead.wear_id, /obj/item/card/id))
			var/obj/item/card/id/ID = old_lead.wear_id
			ID.access -= list(ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)
	old_lead.hud_set_squad()
	old_lead.update_inv_head() //updating marine helmet leader overlays
	old_lead.update_inv_wear_suit()
	to_chat(old_lead, "<font size='3' color='blue'>You're no longer the Squad Leader for [src]!</font>")