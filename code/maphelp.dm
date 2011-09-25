/turf/maphelp/auto_window
	icon = 'icons/immibis/maphelp.dmi'
	icon_state = "autowindow"

/world/New()
	. = ..()

	var/dirs[] = list(NORTH, SOUTH, EAST, WEST)

	for(var/turf/maphelp/auto_window/aw)
		new /obj/grille(aw)
		for(var/d in dirs)
			var/turf/maphelp/auto_window/T = get_step(aw, d)
			if(!istype(T))
				var/obj/window/reinforced/W = new(aw)
				W.dir = d

	for(var/turf/maphelp/auto_window/aw)
		new/turf/simulated/floor/plating(aw)

/turf/maphelp/connection_point
	icon = 'icons/immibis/maphelp.dmi'
	icon_state = "connection_point"