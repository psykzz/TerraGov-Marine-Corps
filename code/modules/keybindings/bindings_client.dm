// Clients aren't datums so we have to define these procs indpendently.
// These verbs are called for all key press and release events
/client/verb/keyDown(_key as text)
	set instant = TRUE
	set hidden = TRUE

	keys_held[_key] = world.time
	var/focus_chat = prefs.focus_chat
	var/movement = focus_chat ? SSinput.arrow_movement_keys[_key] : SSinput.wasd_movement_keys[_key]
	if(!(next_move_dir_sub & movement) && !keys_held["Ctrl"])
		next_move_dir_add |= movement

	// Check if chat should have focus but doesn't, give it focus and pre-enter the key.
	if(focus_chat && !winget(src, null, "input.focus"))
		winset(src, null, "input.focus=true")
		winset(src, null, "input=[list2params(list(text = _key))]")
		return

	// Client-level keybindings are ones anyone should be able to do at any time
	// Things like taking screenshots, hitting tab, and adminhelps.
	var/AltMod = keys_held["Alt"] ? "Alt-" : ""
	var/CtrlMod = keys_held["Ctrl"] ? "Ctrl-" : ""
	var/ShiftMod = keys_held["Shift"] ? "Shift-" : ""
	var/full_key = "[_key]"
	if (!(_key in list("Alt", "Ctrl", "Shift")))
		full_key = "[AltMod][CtrlMod][ShiftMod][_key]"
	for (var/kb_name in prefs.key_bindings[full_key])
		var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
		if (kb.down(src))
			break

	holder?.key_down(full_key, src)
	mob.focus?.key_down(full_key, src)


/client/verb/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	keys_held -= _key

	var/focus_chat = prefs.focus_chat
	var/movement = focus_chat ? SSinput.arrow_movement_keys[_key] : SSinput.wasd_movement_keys[_key]
	if(!(next_move_dir_add & movement))
		next_move_dir_sub |= movement

	// We don't do full key for release, because for mod keys you
	// can hold different keys and releasing any should be handled by the key binding specifically
	for (var/kb_name in prefs.key_bindings[_key])
		var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
		if (kb.up(src))
			break

	holder?.key_up(_key, src)
	mob.focus?.key_up(_key, src)


// Called every game tick
/client/keyLoop()
	holder?.keyLoop(src)
	mob.focus?.keyLoop(src)
