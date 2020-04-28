/**
	Modular armor pieces

	These are straight armor attachments that equip into 1 of 3 slots on modular armor
	There are chest arms and leg variants, each with their own light medium and heavy armor (not mentioning special types)

	Each armor will merge its armor with the modular armor on attachment and remove it when detached, similar with other stats like slowdown.
*/
/obj/item/armor_module/armor
	name = "modular armor - armor module"
	icon = 'icons/mob/modular/modular_armor.dmi'

	/// The additional armor provided by equipping this piece.
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	/// Addititve Slowdown of this armor piece
	slowdown = 0

/obj/item/armor_module/armor/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.armor = parent.armor.attachArmor(armor)
	parent.slowdown += slowdown

/obj/item/armor_module/armor/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.armor = parent.armor.detachArmor(armor)
	parent.slowdown -= slowdown
	return ..()



/** Chest pieces */
/obj/item/armor_module/armor/chest
	icon_state = "medium_chest_icon"
	item_state = "medium_chest"

/obj/item/armor_module/armor/chest/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_chest = src
	parent.update_overlays()

/obj/item/armor_module/armor/chest/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_chest = null
	return ..()

/obj/item/armor_module/armor/chest/light
	name = "Jaeger Pattern light Chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a light amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides somewhat minimal defensive qualities, but has very little impact on the users mobility."
	icon_state = "light_chest_icon"
	item_state = "light_chest"
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15)
	slowdown = 0.2

/obj/item/armor_module/armor/chest/medium
	name = "medium chest armor module"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a medium amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides moderate defensive qualities, with a moderate impact on the users mobility."
	icon_state = "medium_chest_icon"
	item_state = "medium_chest"
	armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25)
	slowdown = 0.7

/obj/item/armor_module/armor/chest/heavy
	name = "heavy chest armor module"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a heavy amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides heavy defensive qualities, with a notable impact on the users mobility."
	icon_state = "heavy_chest_icon"
	item_state = "heavy_chest"
	armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 35)
	slowdown = 1.5



/** Legs pieces */
/obj/item/armor_module/armor/legs
	icon_state = "medium_legs_icon"
	item_state = "medium_legs"

/obj/item/armor_module/armor/legs/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_legs = src
	parent.update_overlays()

/obj/item/armor_module/armor/legs/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_legs = null
	return ..()

/obj/item/armor_module/armor/legs/light
	name = "Jaeger Pattern light Leg Plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a light amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides somewhat minimal defensive qualities, but has very little impact on the users mobility."
	icon_state = "light_legs_icon"
	item_state = "light_legs"
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15)
	slowdown = 0.2

/obj/item/armor_module/armor/legs/medium
	name = "Jaeger Pattern medium Leg Plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a medium amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides moderate defensive qualities, with a moderate impact on the users mobility."
	icon_state = "medium_legs_icon"
	item_state = "medium_legs"
	armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25)
	slowdown = 0.7

/obj/item/armor_module/armor/legs/heavy
	name = "Jaeger Pattern heavy Leg Plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a heavy amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides heavy defensive qualities, with a notable impact on the users mobility."
	icon_state = "heavy_legs_icon"
	item_state = "heavy_legs"
	armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 35)
	slowdown = 1.5


/** Arms pieces */
/obj/item/armor_module/armor/arms
	icon_state = "medium_arms_icon"
	item_state = "medium_arms"

/obj/item/armor_module/armor/arms/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_arms = src
	parent.update_overlays()

/obj/item/armor_module/armor/arms/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_arms = null
	return ..()

/obj/item/armor_module/armor/arms/light
	name = "Jaeger Pattern light Arm Plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a light amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides somewhat minimal defensive qualities, but has very little impact on the users mobility."
	icon_state = "light_arms_icon"
	item_state = "light_arms"
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15)
	slowdown = 0.2

/obj/item/armor_module/armor/arms/medium
	name = "Jaeger Pattern medium Arm Plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a medium amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides moderate defensive qualities, with a moderate impact on the users mobility."
	icon_state = "medium_arms_icon"
	item_state = "medium_arms"
	armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25)
	slowdown = 0.7

/obj/item/armor_module/armor/arms/heavy
	name = "Jaeger Pattern heavy Arm Plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a heavy amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides heavy defensive qualities, with a notable impact on the users mobility."
	icon_state = "heavy_arms_icon"
	item_state = "heavy_arms"
	armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 35)
	slowdown = 1.5
