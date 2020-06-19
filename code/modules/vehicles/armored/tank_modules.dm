/**
  *TANK MODULES
  *
  * Attached to the tank and provide abilities/ passive upgrades
  */
/obj/item/tank_module //base
	name = "Tank Module"
	desc = "Yell at the admin that spawned this in please."
	icon = 'icons/obj/vehicles/hardpoint_modules.dmi'
	icon_state = "ltb_cannon"

///Called to apply modules to a vehicle
/obj/item/tank_module/proc/on_equip(target)
	if(isarmoredvehicle(target))
		return

/obj/item/tank_module/proc/on_unequip(target)
	if(isarmoredvehicle(target))
		return

/obj/item/tank_module/overdrive
	name = "Overdrive Module"
	desc = "A module that enhances the speed of armored combat vehicles by increasing fuel efficiency."
	icon_state = "odrive_enhancer"

/obj/item/tank_module/overdrive/on_equip(target)
	. = ..()
	var/obj/vehicle/armored/vehicle = target
	vehicle.move_delay -= 0.15 SECONDS

/obj/item/tank_module/overdrive/on_unequip(target)
	. = ..()
	var/obj/vehicle/armored/vehicle = target
	vehicle.move_delay += 0.15 SECONDS

/obj/item/tank_module/passenger
	name = "Passenger Module"
	desc = "A module that increases the carrying capacity of a vehicle with extra seats."
	icon_state = "uninstalled APC frieght carriage"

/obj/item/tank_module/passenger/on_equip(target)
	. = ..()
	var/obj/vehicle/armored/vehicle = target
	vehicle.max_passengers += 4

/obj/item/tank_module/passenger/on_unequip(target)
	. = ..()
	var/obj/vehicle/armored/vehicle = target
	vehicle.max_passengers -= 4
	if(vehicle.max_passengers < vehicle.passengers.len)
		for(var/m in vehicle.passengers)
			var/mob/living/carbon/human/H
			vehicle.exit_tank(H)
			if(vehicle.max_passengers > vehicle.passengers.len)//Kick people out till the cap is reached again
				return
