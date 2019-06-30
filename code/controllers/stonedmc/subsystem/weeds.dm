SUBSYSTEM_DEF(weeds)
	name = "Weed"
	priority = FIRE_PRIORITY_WEED
	runlevels = RUNLEVEL_LOBBY|RUNLEVEL_SETUP|RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 5 SECONDS

	// This is a list of nodes on the map.
	var/list/creating = list()
	var/list/pending = list()	//The list of nodes to process. It's referenced this way: pending[node to process][distances from weeds to node][turfs of said weeds]
	var/list/currentrun

/datum/controller/subsystem/weeds/stat_entry()
	return ..("Nodes: [length(pending)]")

/datum/controller/subsystem/weeds/fire(resumed = FALSE)
	if(!resumed)
		currentrun = pending.Copy()
		creating = list()

	for(var/i in currentrun)
		var/obj/effect/alien/weeds/node/N = currentrun[i]
		currentrun -= N

		if(QDELETED(N)) //Node no more, these weeds no longer process.
			pending -= N
			continue

		var/found_something_to_process = FALSE
		for(var/j in 1 to N.node_range) //Let's check one radius-step at a time.
			for(var/k in N.node_turfs[j]) //If there's something to process.
				var/turf/turf_to_check = k
				if((locate(/obj/effect/alien/weeds) in turf_to_check) || (locate(/obj/effect/alien/weeds/node) in turf_to_check))
					N.remove_turfs_from_node(turf_to_check) //This place has been hijacked. It no longer belongs to us.
					continue
				if(!turf_to_check.is_weedable())
					N.remove_turfs_from_node(turf_to_check) //No longer safe to grow. We won't return here.
					continue
				if(!N.check_link_weed_to_node(turf_to_check))
					N.remove_turfs_from_node(turf_to_check) //We have been orphaned. The route home is no longer safe. We won't regrow.
					continue
				creating[turf_to_check] = N //A valid was found!
				found_something_to_process = TRUE //Since we found something, we'll leave the next radius-step for the next iteration.
			if(found_something_to_process)
				break
		if(!found_something_to_process)
			pending -= N //We'll rest until duty calls us again.

		if(MC_TICK_CHECK)
			return

	// We create weeds outside of the loop to not influence new weeds within the loop
	for(var/i in creating)
		var/turf/turf_to_weed = i

		var/obj/effect/alien/weeds/node/parent_node = creating[turf_to_weed]
		// Adds a bit of jitter to the spawning weeds.
		addtimer(CALLBACK(src, .proc/create_weed, turf_to_weed, parent_node), rand(0, 1 SECONDS))

		creating -= turf_to_weed

		if(MC_TICK_CHECK)
			return
		

/datum/controller/subsystem/weeds/proc/add_node(obj/effect/alien/weeds/node/N)
	if(!N)
		CRASH("SSweed.add_node called with a null obj")

	pending += N


/datum/controller/subsystem/weeds/proc/add_weed(obj/effect/alien/weeds/W)
	if(!W)
		CRASH("SSweed.add_turf called with a null obj")

	var/turf/weed_turf = get_turf(W)
	W.parent_node.node_turfs[get_dist(W, W.parent_node)] = weed_turf
	if(W.parent_node in pending)
		return
	pending += W.parent_node


/datum/controller/subsystem/weeds/proc/create_weed(turf/T, obj/effect/alien/weeds/node/N)
	if(iswallturf(T))
		new /obj/effect/alien/weeds/weedwall(T)
		return

	for (var/obj/O in T)
		if(istype(O, /obj/structure/window/framed))
			new /obj/effect/alien/weeds/weedwall/window(T)
			return
		else if(istype(O, /obj/structure/window_frame))
			new /obj/effect/alien/weeds/weedwall/frame(T)
			return
		else if(istype(O, /obj/machinery/door) && O.density /*&& (!(O.flags_atom & ON_BORDER) || O.dir != dirn)*/)
			return

	new /obj/effect/alien/weeds(T, N)