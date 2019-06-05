/* Gifts and wrapping paper
 * Contains:
 *		Gifts
 *		Wrapping Paper
 */

/*
 * Gifts
 */
/obj/item/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift1"
	item_state = "gift1"

/obj/item/a_gift/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	if(w_class > 0 && w_class < 4)
		icon_state = "gift[w_class]"
	else
		icon_state = "gift[pick(1, 2, 3)]"
	return

/obj/item/gift/attack_self(mob/user as mob)
	user.drop_held_item()
	if(gift)
		user.put_in_active_hand(gift)
	else
		to_chat(user, "<span class='notice'>The gift was empty!</span>")
	qdel(src)
	return

/obj/item/a_gift/ex_act()
	qdel(src)
	return

/obj/effect/spresent/relaymove(mob/user)
	if (user.stat)
		return
	to_chat(user, "<span class='notice'>You cant move.</span>")

/obj/effect/spresent/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!iswirecutter(I))
		to_chat(user, "<span class='notice'>You need wirecutters for that.</span>")
		return

	to_chat(user, "<span class='notice'>You cut open the present.</span>")

	for(var/mob/M in src) //Should only be one but whatever.
		M.forceMove(loc)
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

	qdel(src)

/obj/item/a_gift/attack_self(mob/M as mob)
	var/gift_type = pick(
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/belt/champion,
		/obj/item/tool/soap/deluxe,
		/obj/item/tool/pickaxe/silver,
		/obj/item/tool/pen/invisible,
		/obj/item/explosive/grenade/smokebomb,
		/obj/item/corncob,
		/obj/item/contraband/poster,
		/obj/item/book/manual/barman_recipes,
		/obj/item/book/manual/chef_recipes,
		/obj/item/toy/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/toy/beach_ball/holoball,
		/obj/item/weapon/banhammer,
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/toy/crossbow,
		/obj/item/toy/gun,
		/obj/item/toy/katana,
		/obj/item/toy/prize/deathripley,
		/obj/item/toy/prize/durand,
		/obj/item/toy/prize/fireripley,
		/obj/item/toy/prize/gygax,
		/obj/item/toy/prize/honk,
		/obj/item/toy/prize/marauder,
		/obj/item/toy/prize/mauler,
		/obj/item/toy/prize/odysseus,
		/obj/item/toy/prize/phazon,
		/obj/item/toy/prize/ripley,
		/obj/item/toy/prize/seraph,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/reagent_container/food/snacks/grown/ambrosiadeus,
		/obj/item/reagent_container/food/snacks/grown/ambrosiavulgaris,
		/obj/item/violin,
		/obj/item/clothing/tie/horrible)

	if(!ispath(gift_type,/obj/item))	return

	var/obj/item/I = new gift_type(M)
	M.temporarilyRemoveItemFromInventory(src)
	M.put_in_hands(I)
	qdel(src)
	return

/*
 * Wrapping Paper
 */
/obj/item/wrapping_paper
	name = "wrapping paper"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "wrap_paper"
	var/amount = 20.0

/obj/item/wrapping_paper/attackby(obj/item/I, mob/user, params)
	. = ..()

	var/a_used = 2 ** (w_class - 1)

	if(!(locate(/obj/structure/table) in loc))
		to_chat(user, "<span class='notice'>You must put the paper on a table!</span>")

	else if(I.w_class >= 4)
		to_chat(user, "<span class='notice'>The object is far too large!</span>")


	else if(!iswirecutter(user.l_hand) && !iswirecutter(user.r_hand))
		to_chat(user, "<span class='notice'>You need scissors!</span>")

	else if (amount < a_used)
		to_chat(user, "<span class='notice'>You need more paper!</span>")

	else if(istype(I, /obj/item/smallDelivery) || istype(I, /obj/item/gift)) //No gift wrapping gifts!
		return

	else if(user.drop_held_item())
		amount -= a_used
		var/obj/item/gift/G = new(loc)
		G.size = I.w_class
		G.w_class = G.size + 1
		G.icon_state = text("gift[]", G.size)
		G.gift = I
		I.forceMove(G)

		if(amount <= 0)
			new /obj/item/trash/c_tube(loc)
			qdel(src)


/obj/item/wrapping_paper/examine(mob/user)
	..()
	to_chat(user, "There is about [amount] square units of paper left!")


/obj/item/wrapping_paper/attack(mob/target as mob, mob/user as mob)
	if (!ishuman(target)) return
	var/mob/living/carbon/human/H = target

	if (istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket) || H.stat)
		if (src.amount > 2)
			var/obj/effect/spresent/present = new /obj/effect/spresent (H.loc)
			src.amount -= 2

			if (H.client)
				H.client.perspective = EYE_PERSPECTIVE
				H.client.eye = present

			H.loc = present

			log_combat(user, H, "wrapped")
			msg_admin_attack("[key_name(user)] used [src] to wrap [key_name(H)]")

		else
			to_chat(user, "<span class='notice'>You need more paper.</span>")
	else
		to_chat(user, "They are moving around too much. A straightjacket would help.")