//this exists purely to avoid meta by pre-loading all language icons.
/datum/asset/language/register()
	for(var/path in typesof(/datum/language))
		set waitfor = FALSE
		var/datum/language/L = new path ()
		L.get_icon()


/datum/asset/simple/tgui
	assets = list(
		"tgui.bundle.js" = 'tgui/packages/tgui/public/tgui.bundle.js',
		"tgui.bundle.css" = 'tgui/packages/tgui/public/tgui.bundle.css',
	)

/datum/asset/group/tgui
	children = list(
		/datum/asset/simple/tgui,
		/datum/asset/simple/fontawesome
	)

/datum/asset/simple/changelog
	assets = list(
		"88x31.png" = 'html/images/88x31.png',
		"bug-minus.png" = 'html/images/bug-minus.png',
		"cross-circle.png" = 'html/images/cross-circle.png',
		"hard-hat-exclamation.png" = 'html/images/hard-hat-exclamation.png',
		"image-minus.png" = 'html/images/image-minus.png',
		"image-plus.png" = 'html/images/image-plus.png',
		"music-minus.png" = 'html/images/music-minus.png',
		"music-plus.png" = 'html/images/music-plus.png',
		"tick-circle.png" = 'html/images/tick-circle.png',
		"wrench-screwdriver.png" = 'html/images/wrench-screwdriver.png',
		"spell-check.png" = 'html/images/spell-check.png',
		"burn-exclamation.png" = 'html/images/burn-exclamation.png',
		"chevron.png" = 'html/images/chevron.png',
		"chevron-expand.png" = 'html/images/chevron-expand.png',
		"scales.png" = 'html/images/scales.png',
		"coding.png" = 'html/images/coding.png',
		"ban.png" = 'html/images/ban.png',
		"chrome-wrench.png" = 'html/images/chrome-wrench.png',
		"changelog.css" = 'html/browser/changelog.css'
	)


/datum/asset/group/goonchat
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/goonchat,
		/datum/asset/spritesheet/goonchat,
		/datum/asset/simple/fontawesome
	)

/datum/asset/simple/fontawesome
	assets = list(
		"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"font-awesome.css"    = 'html/font-awesome/css/all.min.css',
		"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css'
	)

/datum/asset/simple/jquery
	assets = list(
		"jquery.min.js"            = 'code/modules/goonchat/jquery.min.js',
	)


/datum/asset/simple/goonchat
	assets = list(
		"json2.min.js"             = 'code/modules/goonchat/json2.min.js',
		"browserOutput.js"         = 'code/modules/goonchat/browserOutput.js',
		"fontawesome-webfont.eot"  = 'code/modules/goonchat/fonts/fontawesome-webfont.eot',
		"fontawesome-webfont.svg"  = 'code/modules/goonchat/fonts/fontawesome-webfont.svg',
		"fontawesome-webfont.ttf"  = 'code/modules/goonchat/fonts/fontawesome-webfont.ttf',
		"fontawesome-webfont.woff" = 'code/modules/goonchat/fonts/fontawesome-webfont.woff',
		"goonchatfont-awesome.css" = 'code/modules/goonchat/font-awesome.css',
		"browserOutput.css"	       = 'code/modules/goonchat/browserOutput.css',
		"browserOutput_white.css"  = 'code/modules/goonchat/browserOutput_white.css',
	)


/datum/asset/spritesheet/goonchat
	name = "chat"


/datum/asset/spritesheet/goonchat/register()
	InsertAll("emoji", 'icons/misc/emoji.dmi')

	// pre-loading all lanugage icons also helps to avoid meta
	InsertAll("language", 'icons/misc/language.dmi')
	// catch languages which are pulling icons from another file
	for(var/path in typesof(/datum/language))
		var/datum/language/L = path
		var/icon = initial(L.icon)
		if(icon != 'icons/misc/language.dmi')
			var/icon_state = initial(L.icon_state)
			Insert("language-[icon_state]", icon, icon_state = icon_state)

	return ..()


/datum/asset/spritesheet/pipes
	name = "pipes"

/datum/asset/spritesheet/pipes/register()
	for (var/each in list('icons/obj/pipes/disposal.dmi'))
		InsertAll("", each, GLOB.alldirs)
	return ..()


/datum/asset/simple/permissions
	assets = list(
		"padlock.png"	= 'html/images/padlock.png'
	)

/datum/asset/simple/notes
	assets = list(
		"high_button.png" = 'html/images/high_button.png',
		"medium_button.png" = 'html/images/medium_button.png',
		"minor_button.png" = 'html/images/minor_button.png',
		"none_button.png" = 'html/images/none_button.png',
	)

/datum/asset/simple/logo
	assets = list(
		"ntlogo.png"	= 'html/images/ntlogo.png',
		"tgmclogo.png"	= 'html/images/tgmclogo.png'
	)

/datum/asset/simple/vv
	assets = list(
		"view_variables.css" = 'html/admin/view_variables.css'
	)
