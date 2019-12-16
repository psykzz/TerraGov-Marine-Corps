/*// Balance datum

This is for tracking and storing balance values that are automatically added to the database on edit.

*/
GLOBAL_DATUM_INIT(balance, /datum/balance, new())


/datum/balance
	var/list/factions
	var/list/balance_values 

/datum/balance/proc/Initialize()
	factions = list("marines", "xeno", "other")
	balance_values = list()
	for(var/faction in factions)
		balance_values[faction] = 0
	
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGIN, .proc/gain_points)
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGOUT, .proc/lose_points)
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, .proc/lose_points)

/datum/balance/proc/gain_points(datum/dcs, mob/source)
	if(!isliving(source))
		return FALSE
	var/mob/living/living = source
	if("Xenomorph")
		balance_values["xeno"] -= 1
	if ("Marine")
		balance_values["marine"] -= 1
	else
		balance_values["other"] -= 1

	record_feedback()
	


/datum/balance/proc/lose_points(datum/dcs, mob/source)
	if(!isliving(source))
		return FALSE
	var/mob/living/living = source
	switch(living.faction)
		if("Xenomorph")
			balance_values["xeno"] -= 1
		if ("Marine")
			balance_values["marine"] -= 1
		else
			balance_values["other"] -= 1

	record_feedback()

/datum/balance/proc/record_feedback()
	var/list/data = deepCopyList(balance_values)
	data["timestamp"] = world.time
	SSblackbox.record_feedback("associative", "balance", 1, data)
