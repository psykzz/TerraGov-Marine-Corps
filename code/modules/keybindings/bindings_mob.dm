// Technically the client argument is unncessary here since that SHOULD be src.client but let's not assume things
// All it takes is one badmin setting their focus to someone else's client to mess things up
// Or we can have NPC's send actual keypresses and detect that by seeing no client

/mob/key_down(_key, client/user)
	switch(_key)
		if("Delete", "H")
			if(!pulling)
				to_chat(src, "<span class='notice'>You are not pulling anything.</span>")
			else
				stop_pulling()
			return
		if("Insert", "G")
			a_intent_change(INTENT_HOTKEY_RIGHT)
			return
		if("F")
			a_intent_change(INTENT_HOTKEY_LEFT)
			return
		if("Y", "Z", "Southeast")	// Southeast is Page-down
			mode()					// attack_self(). No idea who came up with "mode()"
			return
		if("Q", "Northwest") // Northwest is Home
			var/obj/item/I = get_active_held_item()
			if(!I)
				to_chat(src, "<span class='warning'>You have nothing to drop in your hand!</span>")
			else
				dropItemToGround(I)
			return
		if("E")
			return
		if("Alt")
			toggle_move_intent()
			return
		//Bodypart selections
		if("Numpad8")
			src.a_select_zone("head")
			return
		if("Numpad4") 
			src.a_select_zone("larm")
			return
		if("Numpad5") 
			src.a_select_zone("chest")
			return
		if("Numpad6") 
			src.a_select_zone("rarm")
			return
		if("Numpad1") 
			src.a_select_zone("lleg")
			return
		if("Numpad2") 
			src.a_select_zone("groin")
			return
		if("Numpad3") 
			src.a_select_zone("rleg")
			return

	if(client.keys_held["Ctrl"])
		switch(SSinput.movement_keys[_key])
			if(NORTH)
				northface()
				return
			if(SOUTH)
				southface()
				return
			if(WEST)
				westface()
				return
			if(EAST)
				eastface()
				return
	return ..()

/mob/key_up(_key, client/user)
	switch(_key)
		if("Alt")
			toggle_move_intent()
			return
	return ..()