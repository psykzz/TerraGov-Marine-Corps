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
	var/name = "" 						// Display name of the squad
	var/color = "#ffffff"				// Color for identification: helmets, etc.

	var/mob/leader						// Single mob that leads the squad
	var/list/mob/living/members[0]		// List of children, this can be mobs or squads or both, includes the leader

	var/flag = NONE						// By default nothing is enabled for factions
	var/tracking_id = null 				// Use in reference with SSdirection

	var/datum/faction/parent = null		// Parent faction, if any

/datum/faction/New()
	GLOB.all_factions += src

	if (CHECK_BITFIELD(flag, HAS_TRACKING) && !tracking_id)
		tracking_id = SSdirection.init_faction(src)

/datum/faction/Destroy()
	GLOB.all_factions -= src

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

// Use for XENOS
/datum/faction/hive



// Use for humans
/datum/faction/marines

/datum/faction/marines/alpha
	var/flags = HAS_TRACKING

/datum/faction/marines/bravo
	var/flags = HAS_TRACKING

/datum/faction/marines/charlie
	var/flags = HAS_TRACKING

/datum/faction/marines/delta
	var/flags = HAS_TRACKING

