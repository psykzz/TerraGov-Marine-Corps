/mob
	var/datum/focus //What receives our keyboard inputs. src by default

/mob/proc/set_focus(datum/new_focus)
	if(focus == new_focus)
		return
	focus = new_focus