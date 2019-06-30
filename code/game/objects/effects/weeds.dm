#define NODERANGE 3

/obj/effect/alien/weeds
	name = "weeds"
	desc = "Weird black weeds..."
	icon = 'icons/Xeno/weeds.dmi'
	icon_state = "base"

	anchored = TRUE
	density = 0
	plane = FLOOR_PLANE
	layer = TURF_LAYER
	var/obj/effect/alien/weeds/node/parent_node
	max_integrity = 4

/obj/effect/alien/weeds/healthcheck()
	if(obj_integrity <= 0)
		GLOB.round_statistics.weeds_destroyed++
		qdel(src)

/obj/effect/alien/weeds/Initialize(mapload, obj/effect/alien/weeds/node/node)
	. = ..()

	parent_node = node

	update_sprite()
	update_neighbours()


/obj/effect/alien/weeds/Destroy()
	var/turf/oldloc = loc
	if(oldloc.is_weedable())  //If the turf hasn't been changed, let's queue to rebuild it.
		SSweeds.add_weed(src)
	else	//Else let's just remove our tile to stop wasting processing.
		parent_node.remove_turfs_from_node(oldloc)
	. = ..()
	update_neighbours(oldloc)


/obj/effect/alien/weeds/examine(mob/user)
	..()
	var/turf/T = get_turf(src)
	if(isfloorturf(T))
		T.ceiling_desc(user)


/obj/effect/alien/weeds/Crossed(atom/movable/AM)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		H.next_move_slowdown += 1


/obj/effect/alien/weeds/proc/update_neighbours(turf/U)
	if(!U)
		U = loc
	if(istype(U))
		for (var/dirn in GLOB.cardinals)
			var/turf/T = get_step(U, dirn)

			if (!istype(T))
				continue

			var/obj/effect/alien/weeds/W = locate() in T
			if(W)
				W.update_sprite()


/obj/effect/alien/weeds/proc/update_sprite()
	var/my_dir = 0
	for (var/check_dir in GLOB.cardinals)
		var/turf/check = get_step(src, check_dir)

		if (!istype(check))
			continue
		if(istype(check, /turf/closed/wall/resin))
			my_dir |= check_dir

		else if (locate(/obj/effect/alien/weeds) in check)
			my_dir |= check_dir

	if (my_dir == 15) //weeds in all four directions
		icon_state = "weed[rand(0,15)]"
	else if(my_dir == 0) //no weeds in any direction
		icon_state = "base"
	else
		icon_state = "weed_dir[my_dir]"


/obj/effect/alien/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(70))
				qdel(src)
		if(3.0)
			if(prob(50))
				qdel(src)

/obj/effect/alien/weeds/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(I.flags_item & NOBLUDGEON || !isliving(user))
		return

	var/damage = I.force
	if(I.w_class < 4 || !I.sharp || I.force < 20) //only big strong sharp weapon are adequate
		damage *= 0.25

	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.remove_fuel(0))
			return
		damage = 15
		playsound(loc, 'sound/items/welder.ogg', 25, 1)
	else
		playsound(loc, "alien_resin_break", 25)

	var/mob/living/L = user
	L.animation_attack_on(src)

	var/multiplier = 1
	if(I.damtype == "fire") //Burn damage deals extra vs resin structures (mostly welders).
		multiplier += 1

	if(istype(I, /obj/item/tool/pickaxe/plasmacutter) && !user.action_busy)
		var/obj/item/tool/pickaxe/plasmacutter/P = I
		if(P.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD))
			multiplier += PLASMACUTTER_RESIN_MULTIPLIER //Plasma cutters are particularly good at destroying resin structures.
			P.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD) //Minimal energy cost.

	else //Plasma cutters have their own message.
		if(istype(src, /obj/effect/alien/weeds/node)) //The pain is real
			to_chat(user, "<span class='warning'>You hit \the [src] with \the [I].</span>")
		else
			to_chat(user, "<span class='warning'>You cut \the [src] away with \the [I].</span>")

	obj_integrity -= damage * multiplier
	healthcheck()
	return TRUE //don't call afterattack

/obj/effect/alien/weeds/update_icon()
	return

/obj/effect/alien/weeds/fire_act()
	if(!gc_destroyed)
		spawn(rand(100,175))
			qdel(src)


/obj/effect/alien/weeds/weedwall
	layer = RESIN_STRUCTURE_LAYER
	icon_state = "weedwall"

/obj/effect/alien/weeds/weedwall/update_sprite()
	if(iswallturf(loc))
		var/turf/closed/wall/W = loc
		if(W.junctiontype)
			icon_state = "weedwall[W.junctiontype]"



/obj/effect/alien/weeds/weedwall/window
	layer = ABOVE_TABLE_LAYER

/obj/effect/alien/weeds/weedwall/window/update_sprite()
	var/obj/structure/window/framed/F = locate() in loc
	if(F && F.junction)
		icon_state = "weedwall[F.junction]"

/obj/effect/alien/weeds/weedwall/frame
	layer = ABOVE_TABLE_LAYER

/obj/effect/alien/weeds/weedwall/frame/update_sprite()
	var/obj/structure/window_frame/WF = locate() in loc
	if(WF && WF.junction)
		icon_state = "weedframe[WF.junction]"



/obj/effect/alien/weeds/node
	name = "purple sac"
	desc = "A weird, pulsating node."
	icon_state = "weednode"
	var/node_range = NODERANGE
	max_integrity = 15

	var/list/node_turfs[][][] // Potential turfs that we can expand to. Ordered this way: node_turfs[distance to node][turf reference][expansion direction]


/obj/effect/alien/weeds/node/update_icon()
	overlays.Cut()
	overlays += "weednode"


/obj/effect/alien/weeds/node/Initialize(mapload, obj/effect/alien/weeds/node/node, mob/living/carbon/xenomorph/X)
	for(var/obj/effect/alien/weeds/W in loc)
		if(W != src)
			qdel(W) //replaces the previous weed
			break

	overlays += "weednode"
	. = ..(mapload, src)

	// Generate our full graph before adding to SSweeds
	generate_weed_graph()
	SSweeds.add_node(src)


/obj/effect/alien/weeds/node/proc/generate_weed_graph()
	node_turfs =  new/list(node_range, null, null)
	for(var/direction in GLOB.alldirs) //First pass to get the adjacent ones.
		var/turf/adjacent_turf = get_step(src, direction)
		if(!adjacent_turf.is_weedable() || LinkBlocked(src, adjacent_turf) || TurfBlockedNonWindow(adjacent_turf))
			continue
		to_chat(world, "Name of turf: [adjacent_turf]")
		node_turfs[1] += adjacent_turf
		node_turfs[1][adjacent_turf] = direction
	to_chat(world, "first len: [length(node_turfs)]")

	var/list/next_iteration = node_turfs[1].Copy()
	var/list/turfs_to_check
	for(var/weed_to_node_dist in 2 to node_range) //Second to get the rest, one square at a time.
		turfs_to_check = next_iteration
		next_iteration = list()
		for(var/neighbor in turfs_to_check)
			var/turf/current_turf = neighbor
			var/expansion_dir = turfs_to_check[current_turf]
			switch(expansion_dir)
				if(NORTH, SOUTH, WEST, EAST) //These only check the next step in their direction.
					var/turf/next_turf = get_step(current_turf, expansion_dir)
					if(next_turf.is_weedable() && !LinkBlocked(current_turf, next_turf) && !TurfBlockedNonWindow(next_turf))
						next_iteration += next_turf
						next_iteration[next_turf] = expansion_dir
						to_chat(world, "new turf - [expansion_dir]")
				if(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST) //These are corner cases and check both their direction and their cardinal cases, three in total.
					for(var/next_direction in list(expansion_dir, expansion_dir & NORTH|SOUTH, expansion_dir & WEST|EAST))
						var/turf/next_turf = get_step(current_turf, next_direction)
						if(next_turf.is_weedable() && !LinkBlocked(current_turf, next_turf) && !TurfBlockedNonWindow(next_turf))
							next_iteration += next_turf
							next_iteration[next_turf] = next_direction
							to_chat(world, "new turf - [next_direction] (diag)")
			turfs_to_check -= current_turf
		node_turfs[weed_to_node_dist] += next_iteration

	to_chat(world, "last len: [length(node_turfs)]")


/obj/effect/alien/weeds/node/proc/remove_turfs_from_node(turf/weedloc)
	var/distance = get_dist(weedloc, src)
	node_turfs[distance] -= weedloc
	var/direction = get_dir(src, weedloc)
	var/turf/next_orphaned_turf = get_step(weedloc, direction)
	for(var/i in ++distance to node_range)
		node_turfs[distance] -= next_orphaned_turf
		next_orphaned_turf = get_step(next_orphaned_turf, direction)


/obj/effect/alien/weeds/node/proc/check_link_weed_to_node(turf/weedloc)
	if(isnull(loc))
		return FALSE
	var/turf/list/weed_to_node = getline(weedloc, src)
	for(var/i in weed_to_node)
		if(!(locate(/obj/effect/alien/weeds) in i) && !(locate(/obj/effect/alien/weeds/node) in i))
			return FALSE
	return TRUE

#undef NODERANGE