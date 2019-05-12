#define MOTION_DETECTOR_HOSTILE		0
#define MOTION_DETECTOR_FRIENDLY	1
#define MOTION_DETECTOR_DEAD		2
#define MOTION_DETECTOR_FUBAR		3 //i.e. can't be revived. Might have useful gear to loot though!


/obj/effect/detector_blip
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "detector_blip"
	var/identifier = MOTION_DETECTOR_HOSTILE
	layer = BELOW_FULLSCREEN_LAYER

/obj/effect/detector_blip/friendly
	icon_state = "detector_blip_friendly"
	identifier = MOTION_DETECTOR_FRIENDLY

/obj/effect/detector_blip/dead
	icon_state = "detector_blip_dead"
	identifier = MOTION_DETECTOR_DEAD

/obj/effect/detector_blip/fubar
	icon_state = "detector_blip_fubar"
	identifier = MOTION_DETECTOR_FUBAR