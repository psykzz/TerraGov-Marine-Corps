//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "wiki"
	set hidden = TRUE

	if(!CONFIG_GET(string/wikiurl))
		to_chat(src, "<span class='warning'>The wiki URL is not set in the server configuration.</span>")
		return

	if(alert("This will open the wiki in your browser. Are you sure?", "Wiki", "Yes", "No") != "Yes")
		return

	DIRECT_OUTPUT(src, link(CONFIG_GET(string/wikiurl)))


/client/verb/forum()
	set name = "forum"
	set hidden = TRUE

	if(!CONFIG_GET(string/forumurl))
		to_chat(src, "<span class='warning'>The forum URL is not set in the server configuration.</span>")
		return

	if(alert("This will open the forum in your browser. Are you sure?", "Forum", "Yes", "No") != "Yes")
		return

	DIRECT_OUTPUT(src, link(CONFIG_GET(string/forumurl)))


/client/verb/rules()
	set name = "rules"
	set hidden = TRUE

	if(!CONFIG_GET(string/rulesurl))
		to_chat(src, "<span class='warning'>The rules URL is not set in the server configuration.</span>")
		return

	if(alert("This will open the rules in your browser. Are you sure?", "Rules", "Yes", "No") != "Yes")
		return

	DIRECT_OUTPUT(src, link(CONFIG_GET(string/rulesurl)))


/client/verb/discord()
	set name = "discord"
	set hidden = TRUE

	if(!CONFIG_GET(string/discordurl))
		to_chat(src, "<span class='warning'>The Discord URL is not set in the server configuration.</span>")
		return

	if(alert("This will open our Discord in your browser. Are you sure?", "Discord", "Yes", "No") != "Yes")
		return

	DIRECT_OUTPUT(src, link(CONFIG_GET(string/discordurl)))


/client/verb/github()
	set name = "github"
	set hidden = TRUE

	if(!CONFIG_GET(string/githuburl))
		to_chat(src, "<span class='warning'>The bug tracker URL is not set in the server configuration.</span>")
		return

	if(alert("This will open our bug tracker page in your browser. Are you sure?", "Github", "Yes", "No") != "Yes")
		return

	DIRECT_OUTPUT(src, link(CONFIG_GET(string/githuburl)))


/client/verb/webmap()
	set name = "webmap"
	set hidden = TRUE

	var/map_url

	var/choice = alert("Do you want to view the ground or the ship?",,"Ship","Ground","Cancel")
	switch(choice)
		if("Ship")
			map_url = get_ship_map_url()
			if(!map_url)
				to_chat(src, "<span class='warning'>This ship map has no webmap setup.</span>")
				return
		if("Ground")
			map_url = get_ground_map_url()
			if(!map_url)
				to_chat(src, "<span class='warning'>This ground map has no webmap setup.</span>")
				return

	DIRECT_OUTPUT(src, link(map_url))
