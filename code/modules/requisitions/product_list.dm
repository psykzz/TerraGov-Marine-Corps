#define INFINITE (0 << 1)

/datum/product_listing
	var/list/list/items_by_type_path
	/*
	list(
		list(
			"path" = /obj/item/fulton_extraction_pack 	// Required
			"amount" = -1 								// optional
			"name" = null 								// optional
			"path" = NONE 								// optional
		)
	)

	*/
/datum/product_listing/New()
	. = ..()
	items_by_type_path = list()

/datum/product_listing/proc/list_products()
	. = list()
	for(var/path in items_by_type_path)
		var/list/item_detail = items_by_type_path[path]
		. += item_detail

/datum/product_listing/proc/remove(type_path, amount = 1)
	if(!items_by_type_path || !items_by_type_path[type_path])
		return FALSE
	
	var/list/item = items_by_type_path[type_path]
	if(item["flags"] & INFINITE)
		return TRUE

	// remove an amount
	item["amount"] = max(item["amount"] - amount, 0)
	items_by_type_path[type_path] = item
	return TRUE

/datum/product_listing/proc/is_available(type_path, amount = 1)
	if(!items_by_type_path || !items_by_type_path[type_path])
		return FALSE

	return length(items_by_type_path[type_path].amount) > 0

/datum/product_listing/proc/add_product(type_path, amount = 1, name = null, cost = 0, flags = NONE)
	var/obj/item/temp = type_path
	name = initial(temp.name)

	items_by_type_path[type_path] = list(
		"_type_path" = type_path,
		"amount" = amount,
		"name" = name,
		"cost" = cost,
		"flags" = flags
	)	

/datum/product_listing/tablet/requisitions/New()
	. = ..()
	add_product(/obj/item/fulton_extraction_pack)


#undef INFINITE