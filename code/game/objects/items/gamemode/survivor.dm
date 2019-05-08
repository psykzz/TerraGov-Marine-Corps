/obj/item/laptop/rescue
    name = "Communications laptop"
    desc = "A device used for augmenting communication. Someone seems to have left it logged in with open communications to a nearby ship. Set this up next to a rescue beacon."
    icon = 'icons/obj/machines/laptop_beacon.dmi'
    icon_state = "tandy0"
    luminosity = 4
    resistance_flags = UNACIDABLE|INDESTRUCTIBLE
    w_class = WEIGHT_CLASS_BULKY
    var/activation_time = 5 SECONDS

/obj/item/laptop/rescue/update_icon()
    icon_state = "tandy0"
    cut_overlays()
    if(anchored)
        icon_state = "tandy1"
        add_overlay("tandy1o_wifi")

    return ..()

/obj/item/laptop/rescue/attack_hand(mob/user as mob)
    if(!anchored)
        return ..()
    if(!ishuman(user)) 
        return ..()

    user.visible_message("<span class='notice'>[user] starts packing up \the [src].</span>",
    "<span class='notice'>You start packing up \the [src]. <b>This will interrupt the process.</b></span>")
    if(user.get_active_held_item() || !do_after(user, activation_time*1.2, TRUE, 5, BUSY_ICON_FRIENDLY,, TRUE))
        return

    reset_state()
    user.put_in_hands(src)
    
    return ..()
    
/obj/item/laptop/rescue/attack_self(mob/user)
    if(anchored)
        to_chat(user, "<span class='warning'>It's already been anchored. Just leave it.</span>")
        return

    if(!ishuman(user)) 
        return

    if(!user.mind)
        to_chat(user, "<span class='warning'>It doesn't seem to do anything for you.</span>")
        return

    var/area/A = get_area(user)
    if(istype(A) && A.ceiling >= CEILING_METAL)
        to_chat(user, "<span class='warning'>You have to be outside or under a glass ceiling to activate this.</span>")
        return

    user.visible_message("<span class='notice'>[user] starts setting up [src] on the ground.</span>",
    "<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")

    if(!do_after(user, activation_time, TRUE, 5, BUSY_ICON_FRIENDLY,, TRUE))
        return

    log_game("[key_name(user)] placed \the [src] near [AREACOORD(A.loc)]")

    user.transferItemToLoc(src, user.loc)
    anchored = TRUE
    w_class = 10
    update_icon()
        


/obj/item/laptop/rescue/proc/reset_state()
    icon_state = "tandy0"
    w_class = initial(w_class)
    anchored = FALSE
    SetLuminosity(initial(luminosity))
    update_icon()


/obj/item/laptop/rescue/attack_alien(mob/living/carbon/Xenomorph/M)
    if(!anchored)
        to_chat(M, "<span class='warning'>It's already broken.</span>")
        return

    M.animation_attack_on(src)
    M.visible_message("<span class='danger'>\The [M] slices [src] apart!</span>", \
        "<span class='danger'>You slice [src] apart!</span>", null, 5)
    playsound(loc, "alien_claw_metal", 25, 1)

    if (!anchored)
        return

    reset_state()
   
    if(prob(10))
        new /obj/effect/decal/cleanable/blood/oil(loc)

/obj/item/beacon/rescue
    name = "Rescue beacon"
    desc = "A rugged, glorified laser pointer capable of sending a beam into space. Activate and throw this to call for someone to rescue you."
    icon_state = "motion0"
    resistance_flags = UNACIDABLE|INDESTRUCTIBLE
    w_class = WEIGHT_CLASS_BULKY
    luminosity = 4 

    var/activated = FALSE
    var/activation_time = 10 SECONDS
    var/icon_activated = "motion2"

    var/distress_timer = 10 MINUTES
    var/required_components = list(
        /obj/item/cell,
    )

    // Requirements for nearby components that need setting up
    var/scan_range = 2
    var/required_nearby = list(
        /obj/item/laptop/rescue,
    )

    // Contents list, for when it gets broken. We spit everything out again
    var/internal_components = list()

    // Custom health, It can't be destroyed but it can be stopped by reducing health to 0
    var/max_hp = 100
    var/current_hp = 0

    // Timer to remove the distress beacon if we get distroyed
    var/noise_timer_id = null
    var/beacon_timer_id = null


/obj/item/beacon/rescue/examine()
    . = ..() // show parent examines (if any) first
    if (beacon_timer_id)
        to_chat(usr, "<span class='notice'>It shows [timeleft(beacon_timer_id) / 10] seconds left.</span>")
    if (current_hp < max_hp)
        var/integrity = current_hp / max_hp * 100
        switch(integrity)
            if(85 to 100)
                to_chat(usr, "<span class='warning'>It's fully intact.</span>")
            if(65 to 85)
                to_chat(usr, "<span class='warning'>It's slightly damaged.</span>")
            if(45 to 65)
                to_chat(usr, "<span class='warning'>It's badly damaged.</span>")
            if(25 to 45)
                to_chat(usr, "<span class='warning'>It's heavily damaged.</span>")
            else
                to_chat(usr, "<span class='warning'>It's falling apart.</span>")
    if (length(required_components))
        to_chat(usr, "<span class='warning'>It looks like a few parts are missing.</span>")


/obj/item/beacon/rescue/process()
    var/list/nearby = range(scan_range, src)
    var/nearby_setup = 0
    for (var/R in required_nearby)
        var/obj/found = locate(R) in nearby
        if (found && found.anchored == 1)
            nearby_setup++

    if(nearby_setup == length(required_nearby))    
        return

    visible_message("\The [src] emits an erroneous beep and turns off.", "You hear erroneous beep.")
    log_game("Beacon is too far from the laptop and reset [AREACOORD(src.loc)]")
    reset_state(FALSE)


/obj/item/beacon/rescue/proc/reset_state(dump_contents = TRUE)
    activated = FALSE
    anchored = FALSE
    icon_state = "motion0"
    w_class = WEIGHT_CLASS_BULKY
    SetLuminosity(initial(luminosity))
    update_icon()

    if (issurvivorgamemode(SSticker.mode))
        var/datum/game_mode/survivor/GM = SSticker.mode
        GM.beacon = null
    
    if (dump_contents && length(internal_components))
        required_components = initial(required_components)
        for (var/I in internal_components)
            var/turf/T = get_step(src, pick(cardinal))
            if (T.obscured)
                usr.transferItemToLoc(I, src)
            else
                usr.transferItemToLoc(I, T)

    if (beacon_timer_id && noise_timer_id)
        distress_timer = timeleft(beacon_timer_id)
        deltimer(noise_timer_id)
        deltimer(beacon_timer_id)
        for (var/i in GLOB.alive_human_list)
            var/mob/M = i
            SEND_SOUND(M, sound('sound/misc/notice2.ogg'))
            to_chat(M, "<h2 class='alert'>MESSAGE RECIEVED</h2>")
            to_chat(M, "<span class='alert'>We have lost signal with your beacon! Get it set back up or we'll never find you.</span>")
        log_game("[src] was stopped. Timer had [distress_timer] time left.")

    STOP_PROCESSING(SSobj, src)


/obj/item/beacon/rescue/attack_alien(mob/living/carbon/Xenomorph/M)
    if(current_hp <= 0)
        to_chat(M, "<span class='warning'>It's already broken.</span>")
        return

    M.animation_attack_on(src)
    M.visible_message("<span class='danger'>\The [M] slices [src] apart!</span>", \
        "<span class='danger'>You slice [src] apart!</span>", null, 5)
    playsound(loc, "alien_claw_metal", 25, 1)

    if (!activated)
        return

    current_hp -= max(0, rand(15, 30))
    if(current_hp <= 0)
        log_game("[key_name(M)] destroyed \the [src].")
        reset_state()
   
    if(prob(10))
        new /obj/effect/decal/cleanable/blood/oil(loc)
    

// TODO: Handle other click types (altclick etc)
/obj/item/beacon/rescue/attack_hand(mob/user)
    if(!anchored)
        return ..()

    if(!ishuman(user)) 
        return ..()

    user.visible_message("<span class='notice'>[user] starts packing up \the [src].</span>",
    "<span class='notice'>You start packing up \the [src]. <b>This will interrupt the process.</b></span>")
    if(user.get_active_held_item() || !do_after(user, activation_time*1.2, TRUE, 5, BUSY_ICON_FRIENDLY,, TRUE))
        return

    log_game("[key_name(user)] picked up \the [src].")
    reset_state()
    user.put_in_hands(src)

    return ..()


/obj/item/beacon/rescue/attackby(obj/item/I, mob/user, params)
    if(!anchored || activated)
        return

    // Install components
    for (var/R in required_components)
        if (istype(I, R))
            var/obj/item/cell/C = I
            if (C.charge < 2000)
                to_chat(user, "<span class='warning'>\The [C] doesn't have enough charge!</span>")
                return
            if (user.transferItemToLoc(I, src))
                required_components -= R
                internal_components += I
                user.visible_message("<span class='notice'>[user] installed \the [C]</span>","<span class='notice'>You installed \the [C]</span>")
                break

    // repair dmg
    if(iswelder(I))
        if (current_hp == max_hp)
            to_chat(user, "That doesn't look damaged!")
            return 

        if(!do_after(user, 1 SECONDS, TRUE, 5, BUSY_ICON_BUILD,, TRUE))
            return

        var/obj/item/tool/weldingtool/WT = I
        if(WT.remove_fuel(0, user))
            user.visible_message("<span class='notice'>[user] started repairing \the [src]</span>","<span class='notice'>You started repairing \the [src]</span>")
            playsound(get_turf(src), 'sound/items/Welder2.ogg', 25, 1)
            current_hp = min(current_hp + 25, max_hp)
            
    // Required Nearby components
    // TODO: Check if this is wasteful.
    var/list/nearby = range(2, src)
    var/nearby_setup = 0
    for (var/R in required_nearby)
        var/obj/found = locate(R) in nearby
        if (found?.anchored)
            nearby_setup++

    if(!length(required_components) && current_hp == max_hp && nearby_setup == length(required_nearby))
        log_game("[key_name(user)] activated \the [src].")
        activate_beacon(user)

/obj/item/beacon/rescue/proc/activate_beacon(mob/user as mob)
    icon_state = "[icon_activated]"
    playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
    user.visible_message("<span class='notice'>[user] activates \the [src]</span>", "<span class='notice'>You activates \the [src]</span>")
    activated = TRUE
    SetLuminosity(5)

    if (issurvivorgamemode(SSticker.mode))
        var/datum/game_mode/survivor/GM = SSticker.mode
        GM.beacon = src

    noise_timer_id = addtimer(CALLBACK(src, .proc/make_noise), 7 SECONDS, TIMER_LOOP|TIMER_STOPPABLE)
    beacon_timer_id = addtimer(CALLBACK(src, .proc/call_distress_team), distress_timer, TIMER_UNIQUE|TIMER_STOPPABLE)
    
    for (var/I in GLOB.alive_human_list)
        var/mob/M = I
        to_chat(M, "<h2 class='alert'>MESSAGE RECIEVED</h2>")
        to_chat(M, "<span class='alert'>We have gotten your messages, we are sending units to your location. Hold out until they get there, they shouldn't be more than [distress_timer / 600] minutes.</span>")

    START_PROCESSING(SSobj, src)


/obj/item/beacon/rescue/attack_self(mob/user)
    if(anchored)
        to_chat(user, "<span class='warning'>It's already been anchored. Just leave it.</span>")
        return

    if(!ishuman(user)) 
        return

    if(!user.mind)
        to_chat(user, "<span class='warning'>It doesn't seem to do anything for you.</span>")
        return

    var/area/A = get_area(user)
    if(istype(A) && A.ceiling >= CEILING_METAL)
        to_chat(user, "<span class='warning'>You have to be outside or under a glass ceiling to activate this.</span>")
        return

    user.visible_message("<span class='notice'>[user] starts setting up [src] on the ground.</span>",
    "<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")
    if(!do_after(user, activation_time, TRUE, 5, BUSY_ICON_FRIENDLY))
        return

    log_game("[key_name(user)] placed \the [src] near [AREACOORD(A.loc)]")
    user.transferItemToLoc(src, user.loc)
    anchored = TRUE
    w_class = 10
       

/obj/item/beacon/rescue/proc/make_noise()
    playsound(loc, 'sound/machines/twobeep.ogg', 15, 1)


/obj/item/beacon/rescue/proc/humans_win()
    SSticker.mode.round_finished = MODE_SURIVOR_HUMAN_WIN


/obj/item/beacon/rescue/proc/call_distress_team()
    log_game("[src] called a PMC distress beacon.")
    var/datum/emergency_call/pmc/T = new
    SSticker.mode.picked_call = T
    T.mob_min = 5
    T.mob_max = length(GLOB.player_list) // everyone is allowed
    T.activate()
    addtimer(CALLBACK(src, .proc/humans_win), 5 MINUTES)
    log_game("Humans win in 5 minutes.")
