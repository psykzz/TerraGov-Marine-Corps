/obj/item/transfer_valve
	icon = 'icons/obj/items/assemblies.dmi'
	name = "tank transfer valve"
	icon_state = "valve_1"
	desc = "Regulates the transfer of air between two tanks"
	var/obj/item/tank/tank_one
	var/obj/item/tank/tank_two
	var/obj/item/attached_device
	var/mob/attacher = null
	var/valve_open = 0
	var/toggle = 1

/obj/item/transfer_valve/proc/process_activation(var/obj/item/D)

/obj/item/transfer_valve/IsAssemblyHolder()
	return 1

/obj/item/transfer_valve/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tank))
		if(tank_one && tank_two)
			to_chat(user, "<span class='warning'>There are already two tanks attached, remove one first.</span>")
			return

		if(!tank_one)
			if(!user.drop_held_item())
				return

			tank_one = I
			I.forceMove(src)
			to_chat(user, "<span class='notice'>You attach the tank to the transfer valve.</span>")

		else if(!tank_two)
			if(!user.drop_held_item())
				return

			tank_two = I
			I.forceMove(src)
			to_chat(user, "<span class='notice'>You attach the tank to the transfer valve.</span>")

		update_icon()
		SSnano.update_uis(src) // update all UIs attached to src

	else if(isassembly(I))
		var/obj/item/assembly/A = I
		if(A.secured)
			to_chat(user, "<span class='notice'>The device is secured.</span>")
			return

		if(attached_device)
			to_chat(user, "<span class='warning'>There is already an device attached to the valve, remove it first.</span>")
			return

		user.temporarilyRemoveItemFromInventory(A)
		attached_device = A
		A.forceMove(src)
		to_chat(user, "<span class='notice'>You attach the [I] to the valve controls and secure it.</span>")
		A.holder = src
		A.toggle_secure()	//this calls update_icon(), which calls update_icon() on the holder (i.e. the bomb).

		attacher = user
		SSnano.update_uis(src) // update all UIs attached to src


/obj/item/transfer_valve/HasProximity(atom/movable/AM as mob|obj)
	if(!attached_device)	return
	attached_device.HasProximity(AM)
	return


/obj/item/transfer_valve/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/transfer_valve/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	// this is the data which will be sent to the ui
	var/data[0]
	data["attachmentOne"] = tank_one ? tank_one.name : null
	data["attachmentTwo"] = tank_two ? tank_two.name : null
	data["valveAttachment"] = attached_device ? attached_device.name : null
	data["valveOpen"] = valve_open ? 1 : 0

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "transfer_valve.tmpl", "Tank Transfer Valve", 460, 280)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		//ui.set_auto_update(1)

/obj/item/transfer_valve/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if ( usr.stat || usr.restrained() )
		return 0
	if (src.loc != usr)
		return 0
	if(tank_one && href_list["tankone"])
		split_gases()
		valve_open = 0
		tank_one.loc = get_turf(src)
		tank_one = null
		update_icon()
	else if(tank_two && href_list["tanktwo"])
		split_gases()
		valve_open = 0
		tank_two.loc = get_turf(src)
		tank_two = null
		update_icon()
	else if(href_list["open"])
		toggle_valve()
	else if(attached_device)
		if(href_list["rem_device"])
			attached_device.loc = get_turf(src)
			attached_device:holder = null
			attached_device = null
			update_icon()
		if(href_list["device"])
			attached_device.attack_self(usr)
	return 1 // Returning 1 sends an update to attached UIs

/obj/item/transfer_valve/process_activation(var/obj/item/D)
	if(toggle)
		toggle = 0
		toggle_valve()
		spawn(50) // To stop a signal being spammed from a proxy sensor constantly going off or whatever
			toggle = 1

/obj/item/transfer_valve/update_icon()
	overlays.Cut()
	underlays = null

	if(!tank_one && !tank_two && !attached_device)
		icon_state = "valve_1"
		return
	icon_state = "valve"

	if(tank_one)
		overlays += "[tank_one.icon_state]"
	if(tank_two)
		var/icon/J = new(icon, icon_state = "[tank_two.icon_state]")
		J.Shift(WEST, 13)
		underlays += J
	if(attached_device)
		overlays += "device"

/obj/item/transfer_valve/proc/merge_gases()

/obj/item/transfer_valve/proc/split_gases()



/obj/item/transfer_valve/proc/toggle_valve()
	if(valve_open==0 && (tank_one && tank_two))
		valve_open = 1
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)

		var/attacher_name = ""
		if(!attacher)
			attacher_name = "Unknown"
		else
			attacher_name = "[attacher.name]([attacher.ckey])"

		var/log_str = "Bomb valve opened in <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name]</a> "
		log_str += "with [attached_device ? attached_device : "no device"] attacher: [attacher_name]"

		if(attacher)
			log_str += "(<A HREF='?_src_=holder;adminmoreinfo=\ref[attacher]'>?</A>)"

		log_admin(log_str)
		message_admins(log_str)
		merge_gases()
		spawn(20) // In case one tank bursts
			for (var/i=0,i<5,i++)
				src.update_icon()
				sleep(10)
			src.update_icon()

	else if(valve_open==1 && (tank_one && tank_two))
		split_gases()
		valve_open = 0
		src.update_icon()

// this doesn't do anything but the timer etc. expects it to be here
// eventually maybe have it update icon to show state (timer, prox etc.) like old bombs
/obj/item/transfer_valve/proc/c_state()
	return