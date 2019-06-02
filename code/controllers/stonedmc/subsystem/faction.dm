SUBSYSTEM_DEF(faction)
	name = "Factions"
	init_order = INIT_ORDER_FACTIONS // Must be before SSjobs
	flags = SS_NO_FIRE

	var/datum/faction/marine/base_marine
	var/datum/faction/hive/base_xeno
	var/list/all_factions[0]
	var/list/factions_by_name[0]

/datum/controller/subsystem/faction/Initialize(timeofday)
	init_factions()

/datum/controller/subsystem/faction/proc/init_factions()
	base_marine = new
	base_xeno = new
	for (var/F in subtypesof(/datum/faction))
		var/datum/faction/_faction = new F()
		if(_faction.name && _faction.name != "unnamed faction") // TODO: need a better way to exclude
			factions_by_name[_faction.name] = _faction
		all_factions += _faction


/datum/controller/subsystem/faction/proc/assign_faction(mob/M, rank, latejoin = FALSE, faction_name="Unknown")
	// TOOD: Something smarter.
	if(!faction_name)
		faction_name = pick(factions_by_name)// Random faction
	var/datum/faction/F = factions_by_name[faction_name]
	F.add_member(M)
	return TRUE


/datum/controller/subsystem/faction/proc/reset()
	for(var/i in all_factions)
		var/datum/faction/F = i
		F.reset()


// /proc/handle_squad(mob/M, rank, latejoin = FALSE)
// 	var/strict = FALSE

// 	var/datum/faction/F
// 	var/list/squads = SSfaction.factions_by_name.Copy()
// 	var/datum/faction/P = squads[M.client.prefs.preferred_squad]
// 	var/datum/faction/R = squads[pick(squads)]
// 	if(M.client?.prefs?.be_special && (M.client.prefs.be_special & BE_SQUAD_STRICT))
// 		strict = TRUE
// 	switch(rank)
// 		if("Squad Marine")
// 			if(P && P.assign(M, rank))
// 				return TRUE
// 			else if(R.assign(M, rank))
// 				return TRUE
// 		if("Squad Engineer")
// 			for(var/i in shuffle(squads))
// 				var/datum/faction/S = squads[i]
// 				if(!S.check_entry(rank))
// 					continue
// 				if(P && P == S && S.assign(M, rank, latejoin))
// 					return TRUE
// 			if(strict && !latejoin)
// 				return FALSE
// 			for(var/i in shuffle(squads))
// 				var/datum/faction/S = squads[i]
// 				if(!S.check_entry(rank))
// 					continue
// 				else if(S.assign(M, rank, latejoin))
// 					return TRUE
// 		if("Squad Corpsman")
// 			for(var/i in shuffle(squads))
// 				var/datum/faction/S = squads[i]
// 				if(!S.check_entry(rank))
// 					continue
// 				if(P && P == S && S.assign(M, rank, latejoin))
// 					return TRUE
// 			if(strict && !latejoin)
// 				return FALSE
// 			for(var/i in shuffle(squads))
// 				var/datum/faction/S = squads[i]
// 				if(!S.check_entry(rank))
// 					continue
// 				else if(S.assign(M, rank, latejoin))
// 					return TRUE
// 		if("Squad Smartgunner")
// 			for(var/i in shuffle(squads))
// 				var/datum/faction/S = squads[i]
// 				if(!S.check_entry(rank))
// 					continue
// 				if(P && P == S && S.assign(M, rank, latejoin))
// 					return TRUE
// 			if(strict && !latejoin)
// 				return FALSE
// 			for(var/i in shuffle(squads))
// 				var/datum/faction/S = squads[i]
// 				if(!S.check_entry(rank, latejoin))
// 					continue
// 				else if(S.assign(M, rank, latejoin))
// 					return TRUE
// 		if("Squad Specialist")
// 			for(var/i in shuffle(squads))
// 				var/datum/faction/S = squads[i]
// 				if(!S.check_entry(rank))
// 					continue
// 				if(P && P == S && S.assign(M, rank, latejoin))
// 					return TRUE
// 			if(strict && !latejoin)
// 				return FALSE
// 			for(var/i in shuffle(squads))
// 				var/datum/faction/S = squads[i]
// 				if(!S.check_entry(rank))
// 					continue
// 				else if(S.assign(M, rank, latejoin))
// 					return TRUE
// 		if("Squad Leader")
// 			for(var/i in shuffle(squads))
// 				var/datum/faction/S = squads[i]
// 				if(!S.check_entry(rank))
// 					continue
// 				if(P && P == S && S.assign(M, rank, latejoin))
// 					return TRUE
// 			if(strict && !latejoin)
// 				return FALSE
// 			for(var/i in shuffle(squads))
// 				var/datum/faction/S = squads[i]
// 				if(!S.check_entry(rank))
// 					continue
// 				else if(S.assign(M, rank, latejoin))
// 					return TRUE
// 	return FALSE


