#define TRACK_FRIENDLY (1<<1)
#define TRACK_HOSTILE (1<<2)
#define TRACK_REVIVABLE (1<<3)
#define TRACK_DEAD (1<<4)


/obj/item/tracking
    // icon = 'icons/obj/items/traps.dmi' // TODO: Create coder sprites (or coke i don't judge)
    
    var/mob/living/owner = null
    var/owner_faction
    var/tracking_range = 1 // How close does a mob need to be set off
    var/flag_tracking = TRACK_HOSTILE|TRACK_FRIENDLY|TRACK_REVIVABLE|TRACK_DEAD

    var/tracked_mobs = list() // list of currently tracked mobs

    var/ping = TRUE // Should the device regularly ping
    var/ping_sound = 'sound/items/detector.ogg'
    var/detected_sound = 'sound/items/tick.ogg'

    var/active = FALSE

/obj/item/tracking/Destroy()
    STOP_PROCESSING(SSobj, src)
    return ..()

/obj/item/tracking/proc/deactivate()
    STOP_PROCESSING(SSobj, src)
    active = FALSE
    owner = null
    update_icon()

/obj/item/tracking/proc/on_tracked_mob(mob/M, status)
    return

/obj/item/tracking/process()
    if(!active)
        deactivate()
        return

    if(owner != src && !owner)
        deactivate()
        return

    if(owner != src && get_turf(src) != get_turf(owner))
        deactivate()
        return

    if(owner != src && owner.stat == DEAD)
        deactivate()
        return

    if(owner != src && !owner.client)
        deactivate()
        return

    if(ping)
        playsound(loc, ping_sound, 60, 0, 7, 2)

    tracked_mobs = list()

    . = FALSE
    var/origin = owner ? owner : src
    var/status
    for(var/mob/living/M in orange(tracking_range, origin))
        to_chat(world, "Found [M]")
        if(!isturf(M.loc))
            continue
        status = MOTION_DETECTOR_HOSTILE //Reset the status to default
        var/mob/living/carbon/human/H = M
        if(ishuman(M))
            H = M
        if(CHECK_BITFIELD(flag_tracking, TRACK_FRIENDLY) && M.faction == owner_faction /*H.get_target_lock(iff_signal)*/)
            if(CHECK_BITFIELD(flag_tracking, TRACK_REVIVABLE|TRACK_DEAD) && M.stat == DEAD)
                if(CHECK_BITFIELD(flag_tracking, TRACK_REVIVABLE) && (H?.is_revivable() && H?.get_ghost()))
                    status = MOTION_DETECTOR_DEAD //Dead, but revivable.
                else
                    status = MOTION_DETECTOR_FUBAR //Dead and unrevivable; FUBAR
            else
                status = MOTION_DETECTOR_FRIENDLY
        if(world.time > M.l_move_time + 1 SECONDS && (status == MOTION_DETECTOR_HOSTILE))
            to_chat(world, "[M] has not moved")
            continue //hasn't moved recently

        to_chat(world, "[M] is [status]")

        tracked_mobs[M] = status
        on_tracked_mob(M, status)
        . = TRUE



/obj/item/tracking/motiondetector
    name = "tactical sensor"
    desc = "A device that detects hostile movement. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface."
    icon = 'icons/Marine/marine-items.dmi'
    icon_state = "detector_off"
    item_state = "electronic"
    flags_atom = CONDUCT
    flags_equip_slot = ITEM_SLOT_BELT
    w_class = 2

    tracking_range = 14
    var/mode = 0
    var/longrange_delay = 2 SECONDS

    var/list/blip_pool = list()
    var/recycletime = 120
    var/iff_signal = ACCESS_IFF_MARINE

/obj/item/tracking/motiondetector/examine(mob/user as mob)
    if(get_dist(user,src) > 2)
        to_chat(user, "<span class='warning'>You're too far away to see [src]'s display!</span>")
    else
        var/details
        details += "<b>Power:</b> [active ? "ON" : "OFF"]</br>"
        details += "<b>Friendly detection:</b> [CHECK_BITFIELD(flag_tracking, TRACK_FRIENDLY) ? "ACTIVE" : "INACTIVE"]</br>"
        details += "<b>Friendly revivable corpse detection:</b> [CHECK_BITFIELD(flag_tracking, TRACK_REVIVABLE) ? "ACTIVE" : "INACTIVE"]</br>"
        details += "<b>Friendly unrevivable corpse detection:</b> [CHECK_BITFIELD(flag_tracking, TRACK_DEAD) ? "ACTIVE" : "INACTIVE"]</br>"
        to_chat(user, "<span class='notice'>[src]'s display shows the following settings:</br>[details]</span>")
    return ..()


/obj/item/tracking/motiondetector/Destroy()
    STOP_PROCESSING(SSobj, src)
    for(var/obj/X in blip_pool)
        qdel(X)
    blip_pool = list()
    return ..()

/obj/item/tracking/motiondetector/dropped(mob/user)
    . = ..()
    owner = null


/obj/item/tracking/motiondetector/update_icon()
    if(active)
        icon_state = "detector_on_[mode]"
    else
        icon_state = "detector_off"
    return ..()

/obj/item/tracking/motiondetector/deactivate()
    active = FALSE
    owner = null
    update_icon()
    STOP_PROCESSING(SSobj, src)

/obj/item/tracking/motiondetector/process()
    recycletime--
    if(!recycletime)
        recycletime = initial(recycletime)
        for(var/X in blip_pool) //we dump and remake the blip pool every few minutes
            if(blip_pool[X])	//to clear blips assigned to mobs that are long gone.
                qdel(blip_pool[X]) //the blips are garbage-collected and reused via rnew() below
        blip_pool = list()

    // if(!mode)
    //     long_range_cooldown--
    //     if(long_range_cooldown)
    //         return
    //     else
    //         long_range_cooldown = initial(long_range_cooldown)

    . = ..()

    if(. && ping)
        playsound(loc, detected_sound, 50, 0, 7, 2)
        


/obj/item/tracking/motiondetector/on_tracked_mob(mob/M, status)
    if (owner == src) // can't show a blip to the tracker
        return
    show_blip(owner, M, status)
    addtimer(CALLBACK(src, .proc/remove_tracked_mob, M), 5 SECONDS)


/obj/item/tracking/motiondetector/proc/remove_tracked_mob(mob/M)
    tracked_mobs -= M


/obj/item/tracking/motiondetector/proc/show_blip(mob/user, mob/target, status)
    set waitfor = FALSE
    if(user.client)

        if(!blip_pool[target])
            switch(status)
                if(MOTION_DETECTOR_HOSTILE)
                    blip_pool[target] = new /obj/effect/detector_blip()
                    //blip_pool[target].icon_state = "detector_blip_friendly"
                if(MOTION_DETECTOR_FRIENDLY)
                    blip_pool[target] = new /obj/effect/detector_blip/friendly()
                    //blip_pool[target].icon_state = "detector_blip_friendly"
                if(MOTION_DETECTOR_DEAD)
                    blip_pool[target] = new /obj/effect/detector_blip/dead()
                    //blip_pool[target].icon_state = "detector_blip_dead"
                if(MOTION_DETECTOR_FUBAR)
                    blip_pool[target] = new /obj/effect/detector_blip/fubar()
                    //blip_pool[target].icon_state = "detector_blip_fubar"

        var/obj/effect/detector_blip/DB = blip_pool[target]
        var/c_view = user.client.view
        var/view_x_offset = 0
        var/view_y_offset = 0
        if(c_view > 7)
            if(user.client.pixel_x >= 0) view_x_offset = round(user.client.pixel_x/32)
            else view_x_offset = CEILING(user.client.pixel_x/32, 1)
            if(user.client.pixel_y >= 0) view_y_offset = round(user.client.pixel_y/32)
            else view_y_offset = CEILING(user.client.pixel_y/32, 1)

        var/diff_dir_x = 0
        var/diff_dir_y = 0
        if(target.x - user.x > c_view + view_x_offset) diff_dir_x = 4
        else if(target.x - user.x < -c_view + view_x_offset) diff_dir_x = 8
        if(target.y - user.y > c_view + view_y_offset) diff_dir_y = 1
        else if(target.y - user.y < -c_view + view_y_offset) diff_dir_y = 2
        if(diff_dir_x || diff_dir_y)
            switch(status)
                if(MOTION_DETECTOR_HOSTILE)
                    DB.icon_state = "detector_blip_dir"
                if(MOTION_DETECTOR_FRIENDLY)
                    DB.icon_state = "detector_blip_dir_friendly"
                if(MOTION_DETECTOR_DEAD)
                    DB.icon_state = "detector_blip_dir_dead"
                if(MOTION_DETECTOR_FUBAR)
                    DB.icon_state = "detector_blip_dir_fubar"
            DB.setDir(diff_dir_x + diff_dir_y)

        else
            DB.setDir(initial(DB.dir)) //Update the ping sprite
            switch(status)
                if(MOTION_DETECTOR_HOSTILE)
                    DB.icon_state = "detector_blip"
                if(MOTION_DETECTOR_FRIENDLY)
                    DB.icon_state = "detector_blip_friendly"
                if(MOTION_DETECTOR_DEAD)
                    DB.icon_state = "detector_blip_dead"
                if(MOTION_DETECTOR_FUBAR)
                    DB.icon_state = "detector_blip_fubar"

        DB.screen_loc = "[CLAMP(c_view + 1 - view_x_offset + (target.x - user.x), 1, 2*c_view+1)],[CLAMP(c_view + 1 - view_y_offset + (target.y - user.y), 1, 2*c_view+1)]"
        user.client.screen += DB
        addtimer(CALLBACK(src, .proc/remove_blip, user, DB), 1 SECONDS)


/obj/item/tracking/motiondetector/proc/remove_blip(mob/user, blip)
    if(!user?.client)
        return
    user.client.screen -= blip


/obj/item/tracking/motiondetector/pmc
    name = "motion detector (PMC)"
    desc = "A device that detects hostile movement. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface. This one has been modified for use by the NT PMC forces."
    iff_signal = ACCESS_IFF_PMC


/obj/item/tracking/motiondetector/Topic(href, href_list)
    //..()
    if(!ishuman(usr) || usr.stat != CONSCIOUS || usr.restrained())
        usr << browse(null, "window=radio")
        return  
    if (!(src in usr.contents) || !(in_range(src, usr) && istype(loc, /turf)))
        usr << browse(null, "window=radio")
        return  
    
    usr.set_interaction(src)
    if(href_list["power"])
        active = !active
        if(active)
            to_chat(usr, "<span class='notice'>You activate [src].</span>")
            owner = usr
            START_PROCESSING(SSobj, src)
        else
            to_chat(usr, "<span class='notice'>You deactivate [src].</span>")
            STOP_PROCESSING(SSobj, src)
        update_icon()

    else if(href_list["mode"])
        mode = !mode
        if(mode)
            to_chat(usr, "<span class='notice'>You switch [src] to short range mode.</span>")
            tracking_range = 7
        else
            to_chat(usr, "<span class='notice'>You switch [src] to long range mode.</span>")
            tracking_range = 14

    else if(href_list["toggle_friendly"])
        TOGGLE_BITFIELD(flag_tracking, TRACK_FRIENDLY)
    else if(href_list["toggle_revivable"])
        TOGGLE_BITFIELD(flag_tracking, TRACK_REVIVABLE)
    else if(href_list["toggle_dead"])
        TOGGLE_BITFIELD(flag_tracking, TRACK_DEAD)

    update_icon()

    // if(!( master ))
    //     if(istype(loc, /mob))
    //         attack_self(loc)
    //     else
    //         for(var/mob/M in viewers(1, src))
    //             if(M.client)
    //                 attack_self(M)
    // else
    //     if(istype(master.loc, /mob))
    //         attack_self(master.loc)
    //     else
    //         for(var/mob/M in viewers(1, master))
    //             if(M.client)
    //                 attack_self(M)


/obj/item/tracking/motiondetector/attack_self(mob/user as mob, flag1)
    if(!ishuman(user))
        return
    user.set_interaction(src)
    var/dat = {"<p>
    <A href='?src=\ref[src];power=1'><B>Power Control:</B>  [active ? "On" : "Off"]</A><BR>
    <BR>
    <B>Detection Settings:</B><BR>
    <BR>
    <B>Detection Mode:</B> [mode ? "Short Range" : "Long Range"]<BR>
    <A href='byond://?src=\ref[src];mode=1'><B>Set Detector Mode:</B> [mode ? "Long Range" : "Short Range"]</A><BR>
    <BR>
    <B>Friendly Detection Status:</B> [CHECK_BITFIELD(flag_tracking, TRACK_FRIENDLY) ? "ACTIVE" : "INACTIVE"]<BR>
    <A href='?src=\ref[src];toggle_friendly=1'><B>Set Friendly Detection:</B> [CHECK_BITFIELD(flag_tracking, TRACK_FRIENDLY) ? "Off" : "On"]</A><BR>
    <BR>
    <B>Revivable Detection Status:</B> [CHECK_BITFIELD(flag_tracking, TRACK_REVIVABLE) ? "ACTIVE" : "INACTIVE"]<BR>
    <A href='?src=\ref[src];toggle_revivable=1'><B>Set Revivable Detection:</B> [CHECK_BITFIELD(flag_tracking, TRACK_REVIVABLE) ? "Off" : "On"]</A><BR>
    <BR>
    <B>Unrevivable Detection Status:</B> [CHECK_BITFIELD(flag_tracking, TRACK_DEAD) ? "ACTIVE" : "INACTIVE"]<BR>
    <A href='?src=\ref[src];toggle_dead=1'><B>Set Unrevivable Detection:</B> [CHECK_BITFIELD(flag_tracking, TRACK_DEAD) ? "Off" : "On"]</A><BR>
 </p>"}
    user << browse(dat, "window=radio")
    onclose(user, "radio")


/obj/item/tracking/motiondetector/scout
    name = "MK2 recon tactical sensor"
    desc = "A device that detects hostile movement; this one is specially minaturized for reconnaissance units. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface."
    icon_state = "minidetector_off"
    w_class = 1 //We can have this in our pocket and still get pings
    ping = FALSE //Stealth modo


/obj/item/tracking/motiondetector/scout/update_icon()
    if(active)
        icon_state = "minidetector_on_[mode]"
    else
        icon_state = "minidetector_off"



// --- 

// // Tracking item that triggers item to spawn or attach to the mob
// /obj/item/tracking/trap
    // var/activation_delay = 1 SECONDS // How long after being triggered to fire


// // Check to see 
// /obj/item/tracking/trap/proc/should_fire(mob/M)
//     if (!active)
//     return FALSE
//     if (owner == M)
//         return FALSE

//     if CHECK_BITFIELD(flags, TRACK_ALL)

//     return TRUE

    
