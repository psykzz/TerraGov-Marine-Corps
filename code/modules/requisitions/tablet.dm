
/obj/item/tablet
	name = "tablet"
	desc = "a handheld device"
	icon = 'icons/obj/items/bloodpack.dmi' // these look okay for now...
	icon_state = "full" // these look okay for now...

	var/screen = null

/obj/item/tablet/requisitions
	name = "requisitions tablet"
	desc = "a bluespace device connected to the requisitions computer."

	var/datum/product_listing/products
	var/linked_console

/obj/item/tablet/requisitions/Initialize()
	. = ..()
	products = new /datum/product_listing/tablet/requisitions


/obj/item/tablet/requisitions/attack_self(mob/user)
	. = ..()
	ui_interact(user)


/obj/item/tablet/requisitions/proc/purchase(type_path)
	if(!products.is_available(type_path))
		return FALSE
	return products.remove(type_path)

/obj/item/tablet/requisitions/Topic(href, href_list)
	. = ..()
	if(.)
		return

/obj/item/tablet/requisitions/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0)
	if(!ishuman(user)) 
		return
	var/mob/living/carbon/human/H = user
	
	var/list/data = list(
		"current_user" = H,
		"availabe_points" = FLOOR(SSpoints.supply_points, 1),
		"available_products" = products.list_products(),
		"current_orders" = products.list_products()
	)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "fulton_tablet.tmpl", name, 800, 600)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

