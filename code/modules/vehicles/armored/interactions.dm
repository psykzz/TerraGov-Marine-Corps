#define MODULE_PRIMARY "Primary weapon"
#define MODULE_SECONDARY "Secondary weapon"
#define MODULE_UTILITY "Utility Module"

/obj/vehicle/armored/attackby(obj/item/I, mob/user) //This handles reloading weapons, or changing what kind of mags they'll accept
	. = ..()
	if(user.loc == src) //Gotta get out to reload
		to_chat(user, "<span class='warning'>You can't reach [src]'s hardpoints while you're seated in it.</span>")
		return

	if(is_type_in_list(I, primary_weapon?.accepted_ammo))
		var/mob/living/M = user
		var/time = 8 SECONDS - (1 SECONDS * M.skills.getRating("large_vehicle"))
		to_chat(user, "You start to swap out [primary_weapon]'s magazine...")
		if(!do_after(M, time, TRUE, src, BUSY_ICON_BUILD))
			return
		playsound(get_turf(src), 'sound/weapons/guns/interact/working_the_bolt.ogg', 100, 1)
		primary_weapon.ammo.forceMove(get_turf(user))
		primary_weapon.ammo.update_icon()
		primary_weapon.ammo = I
		to_chat(user, "You load [I] into [primary_weapon] with a satisfying click.")
		user.transferItemToLoc(I,src)
		return

	if(is_type_in_list(I, secondary_weapon?.accepted_ammo))
		var/mob/living/M = user
		var/time = 8 SECONDS - (1 SECONDS * M.skills.getRating("large_vehicle"))
		to_chat(user, "You start to swap out [secondary_weapon]'s magazine...")
		if(!do_after(M, time, TRUE, src, BUSY_ICON_BUILD))
			return
		playsound(get_turf(src), 'sound/weapons/guns/interact/working_the_bolt.ogg', 100, 1)
		secondary_weapon.ammo.forceMove(get_turf(user))
		secondary_weapon.ammo.update_icon()
		secondary_weapon.ammo = I
		to_chat(user, "You load [I] into [secondary_weapon] with a satisfying click.")
		user.transferItemToLoc(I,src)
		return

	if(istype(I, /obj/item/tank_weapon))
		var/obj/item/tank_weapon/W = I
		var/mob/living/M = user
		var/slotchoice = alert("What weapon would you like to attach?.", name, MODULE_PRIMARY, MODULE_SECONDARY, "Cancel")
		if(!slotchoice || slotchoice == "Cancel")
			return
		var/time = 8 SECONDS - (1 SECONDS * M.skills.getRating("large_vehicle"))
		if(!do_after(M, time, TRUE, src, BUSY_ICON_BUILD))
			return
		if(slotchoice == MODULE_PRIMARY)
			primary_weapon = W
			turret_overlay.icon = turret_icon
		if(slotchoice == MODULE_SECONDARY)
			if(!istype(I, /obj/item/tank_weapon/secondary_weapon))
				to_chat(user, "<span class='warning'>You can't attach non-secondary weapons to secondary weapon slots!</span>")
				return
			secondary_turret_icon = W.secondary_equipped_icon
			secondary_turret_name = W.secondary_icon_name
			secondary_weapon = W
			secondary_weapon_overlay.icon = secondary_turret_icon
			secondary_weapon_overlay.icon_state = "[secondary_turret_name]" + "_" + "[primary_weapon.dir]"
		to_chat(user, "You attach [W] to the tank.")
		user.transferItemToLoc(W,src)
		return

	if(istype(I, /obj/item/tank_module))
		var/obj/item/tank_module/M = I
		if(utility_module)
			to_chat(user, "There's already a Utility Module attached, remove it with a crowbar first!")
			return
		utility_module = M
		to_chat(user, "You attach [M] to the tank.")
		utility_module.on_equip(src)
		user.transferItemToLoc(M,src)

/obj/vehicle/armored/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.loc == src) //Nice try
		to_chat(user, "<span class='warning'>You can't reach [src]'s hardpoints while youre seated in it.</span>")
		return
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='warning'>You can't see any visible dents on [src].</span>")
		return
	var/obj/item/tool/weldingtool/WT = I
	if(!WT.isOn())
		to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
		return

	user.visible_message("<span class='notice'>[user] starts repairing [src].</span>",
	"<span class='notice'>You start repairing [src].</span>")
	if(!do_after(user, 20 SECONDS, TRUE, src, BUSY_ICON_BUILD, extra_checks = iswelder(I) ? CALLBACK(I, /obj/item/tool/weldingtool/proc/isOn) : null))
		return

	WT.remove_fuel(3, user) //3 Welding fuel to repair the tank. To repair a small tank, it'd take 4 goes AKA 12 welder fuel and 1 minute
	obj_integrity += 100
	if(obj_integrity > max_integrity)
		obj_integrity = max_integrity //Prevent overheal

	user.visible_message("<span class='notice'>[user] welds out a few of the dents on [src].</span>",
	"<span class='notice'>You weld out a few of the dents on [src].</span>")
	update_icon() //Check damage overlays

/obj/vehicle/armored/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	var/position = alert("What module would you like to remove?", name, MODULE_PRIMARY, MODULE_SECONDARY, MODULE_UTILITY, "Cancel")
	if(!position || position == "Cancel")
		return
	var/time = 5 SECONDS - (1 SECONDS * user.skills.getRating("large_vehicle"))
	if(position == MODULE_PRIMARY)
		to_chat(user, "You begin detaching \the [primary_weapon]")
		if(!do_after(user, time, TRUE, src, BUSY_ICON_BUILD))
			return
		primary_weapon.forceMove(get_turf(user))
		to_chat(user, "You detach \the [primary_weapon].")
		turret_overlay.icon = null
		turret_overlay.icon_state = null
		primary_weapon = null
		return
	if(position == MODULE_SECONDARY)
		to_chat(user, "You begin detaching \the [secondary_weapon]")
		if(!do_after(user, time, TRUE, src, BUSY_ICON_BUILD))
			return
		secondary_weapon.forceMove(get_turf(user))
		to_chat(user, "You detach \the [secondary_weapon]")
		secondary_weapon_overlay.icon = null
		secondary_weapon_overlay.icon_state = null
		secondary_weapon = null
		return
	if(position == MODULE_UTILITY)
		to_chat(user, "You begin detaching \the [utility_module]")
		if(!do_after(user, time, TRUE, src, BUSY_ICON_BUILD))
			return
		utility_module.forceMove(get_turf(user))
		utility_module.on_unequip(src)
		to_chat(user, "You detach \the [utility_module]")
		utility_module = null
		return
