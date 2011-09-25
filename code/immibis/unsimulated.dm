var/obj/substance/gas/unsimulated_gas = new
var/obj/substance/gas/default_unsimulated_gas = new

turf/unsimulated
	updatecell = 0

	New()
		. = ..()
		gas = unsimulated_gas
		ngas = unsimulated_gas

	floor
		icon = 'icons/ss13/icons.dmi'
		icon_state = "floor"
		goonstation/icon = 'icons/goonstation/floor.dmi'
		shuttle/icon = 'icons/ss13/shuttle.dmi'
		engine/icon = 'icons/ss13/engine.dmi'
		name = "floor"
		grid
			icon = 'icons/ss13/weap_sat.dmi'
			icon_state = "Floor"
		plating
			intact = 0
			name = "plating"
			icon_state = "Floor1"

	wall
		name = "wall"
		opacity = 1
		density = 1
		icon = 'icons/ss13/wall.dmi'
		ccwall/icon_state = "CCWall"
		rwall/icon_state = "r_wall"
		shuttle/icon = 'icons/ss13/shuttle.dmi'

	space
		name = "space"
		icon = 'icons/goonstation/space.dmi'
		icon_state = "1"
		New()
			. = ..()
			icon_state = "[rand(1,25)]"

obj/begin/shuttle_wall
	name = "wall"
	icon = 'icons/ss13/shuttle.dmi'
	opacity = 1
	density = 1
	anchored = 1

world/New()
	default_unsimulated_gas.o2 = default_unsimulated_gas.partial_pressure_to_moles(O2_STANDARD)
	default_unsimulated_gas.n2 = default_unsimulated_gas.partial_pressure_to_moles(N2_STANDARD)
	default_unsimulated_gas.temperature = T20C
	default_unsimulated_gas.amt_changed()
	. = ..()

proc/reset_unsimulated()
	unsimulated_gas.copy_from(default_unsimulated_gas)


