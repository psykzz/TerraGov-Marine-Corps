//Bot Construction

/obj/item/bot_assembly
	icon = 'icons/obj/aibots.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 3
	throw_speed = 2
	throw_range = 5
	var/created_name
	var/build_step = 0
	var/robot_arm = /obj/item/robot_parts/r_leg

/obj/item/bot_assembly/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/tool/pen))
		rename_bot()
		return

/obj/item/bot_assembly/proc/rename_bot()
	var/t = sanitize_name(stripped_input(usr, "Enter new robot name", name, created_name,MAX_NAME_LEN))
	if(!t)
		return
	if(!in_range(src, usr) && loc != usr)
		return
	created_name = t

/**
  * Checks if the user can finish constructing a bot with a given item.
  *
  * Arguments:
  * * I - Item to be used
  * * user - Mob doing the construction
  * * drop_item - Whether or no the item should be dropped; defaults to 1. Should be set to 0 if the item is a tool, stack, or otherwise doesn't need to be dropped. If not set to 0, item must be deleted afterwards.
  */
/obj/item/bot_assembly/proc/can_finish_build(obj/item/I, mob/user, drop_item = 1)
	if(istype(loc, /obj/item/storage/backpack))
		to_chat(user, "<span class='warning'>You must take [src] out of [loc] first!</span>")
		return FALSE
	if(!I || !user || (drop_item && !user.temporarilyRemoveItemFromInventory(I)))
		return FALSE
	return TRUE


//Medbot Assembly
/obj/item/bot_assembly/medbot
	name = "incomplete medibot assembly"
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon_state = "firstaid_arm"
	created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	var/healthanalyzer = /obj/item/healthanalyzer
	var/firstaid = /obj/item/storage/firstaid

/obj/item/bot_assembly/medbot/proc/set_skin(new_skin)
	skin = new_skin
	if(skin)
		add_overlay("kit_skin_[skin]")


/obj/item/bot_assembly/medbot/attackby(obj/item/W, mob/user, params)
	..()
	switch(build_step)
		if(ASSEMBLY_FIRST_STEP)
			if(istype(W, /obj/item/healthanalyzer))
				if(!user.temporarilyRemoveItemFromInventory(W))
					return
				healthanalyzer = W.type
				to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
				qdel(W)
				name = "first aid/robot arm/health analyzer assembly"
				add_overlay("na_scanner")
				build_step++

		if(ASSEMBLY_SECOND_STEP)
			if(isprox(W))
				if(!can_finish_build(W, user))
					return
				qdel(W)
				var/mob/living/simple_animal/bot/medbot/S = new(drop_location(), skin)
				to_chat(user, "<span class='notice'>You complete the Medbot. Beep boop!</span>")
				S.name = created_name
				S.firstaid = firstaid
				S.robot_arm = robot_arm
				S.healthanalyzer = healthanalyzer
				qdel(src)
