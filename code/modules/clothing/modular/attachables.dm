/** Shoulder lamp stength module */
/obj/item/armor_module/attachable/better_shoulder_lamp
	name = "Baldur Light Amplification System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Substantially increases the power output of the Jaeger Combat Exoskeletons mounted flashlight. Doesn’t really slow you down."

	var/light_amount = 4 /// The amount of light provided

/obj/item/armor_module/attachable/better_shoulder_lamp/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.set_light(light_amount)

/obj/item/armor_module/attachable/better_shoulder_lamp/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.set_light(light_amount * -1)
	return ..()


/** Shoulder lamp stength module */
/obj/item/armor_module/attachable/valkyrie_autodoc
	name = "Valkyrie Automedical Armor System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Has a variety of chemicals it can inject, as well as automatically securing the bones and body of the wearer, to minimise the impact of broken bones or mangled limbs in the field. Will definitely impact mobility."
	icon_state = "mod_autodoc"

/obj/item/armor_module/attachable/valkyrie_autodoc/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent?.AddComponent(/datum/component/suit_autodoc)


/obj/item/armor_module/attachable/valkyrie_autodoc/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	var/datum/component/suit_autodoc/autodoc = parent?.GetComponent(/datum/component/suit_autodoc)
	autodoc.RemoveComponent()
	return ..()



/** Fire poof module */
/obj/item/armor_module/attachable/fire_proof
	name = "Surt Pyrotechnical Insulation System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Providing a near immunity to being bathed in flames, and amazing flame retardant qualities, this is every pyromaniacs first stop to survival. Will impact mobility somewhat."
	armor = list("fire" = 100)

/obj/item/armor_module/attachable/fire_proof/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.armor = parent.armor.attachArmor(src.armor)
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/armor_module/attachable/fire_proof/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE * -1
	parent.armor = parent.armor.detachArmor(src.armor)
	return ..()



/** Extra armor module */
/obj/item/armor_module/attachable/tyr_extra_armor
	name = "Tyr Armor Reinforcement"
	desc = "designed for mounting on the Jaeger Combat Exoskeleton. A substantial amount of additional armor plating designed to fit inside some of the vulnerable portions of the Jaeger Combat Exoskeletons conventional armor patterns. Will definitely impact mobility."
	icon_state = "mod_plate"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 10

/obj/item/armor_module/attachable/tyr_extra_armor/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.armor = parent.armor.attachArmor(armor)
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	parent.slowdown += slowdown

/obj/item/armor_module/attachable/tyr_extra_armor/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.armor = parent.armor.detachArmor(armor)
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE * -1
	parent.slowdown += slowdown * -1
	return ..()


/** Environment protecttion module */
/obj/item/armor_module/attachable/mimir_environment_protection
	name = "Mimir Environmental Resistance System"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. When activated, this system provides substantial resistance to environmental hazards, such as gases, acidic elements, and radiological exposure. Best paired with the Mimir Environmental Helmet System. Will impact mobility when active. Must be toggled to function.."
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 10
	module_type = ARMOR_MODULE_TOGGLE

/obj/item/armor_module/attachable/fire_proof/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.armor = parent.armor.attachArmor(armor)
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	parent.slowdown += slowdown

/obj/item/armor_module/attachable/fire_proof/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.max_heat_protection_temperature += FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE * -1
	parent.armor = parent.armor.detachArmor(armor)
	parent.slowdown += slowdown * -1
	return ..()
