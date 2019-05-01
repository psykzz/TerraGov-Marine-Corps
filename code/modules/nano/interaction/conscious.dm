/*
	This state only checks if user is conscious.
*/
GLOBAL_DATUM_INIT(conscious_state, /datum/topic_state/conscious_state, new)

/datum/topic_state/conscious_state/can_use_topic(src_object, mob/user)
	return user.stat == CONSCIOUS ? STATUS_INTERACTIVE : STATUS_CLOSE