/turf
	icon = 'icons/ss13/turfs.dmi'
	var/intact = 0
	var/firelevel = null

/turf/space
	name = "space"
	var/previousArea = null
	updatecell = 1.0

/turf/simulated
	intact = 1

/turf/simulated/command
	name = "command"

/turf/simulated/command/floor
	name = "floor"
	icon = 'icons/ss13/Icons.dmi'
	icon_state = "Floor3"

/turf/simulated/command/floor/other
	icon_state = "Floor"

/turf/simulated/command/wall
	name = "wall"
	icon = 'icons/ss13/wall.dmi'
	icon_state = "CCWall"
	opacity = 1
	density = 1
	updatecell = 0.0

/turf/simulated/command/wall/other
	icon_state = "r_wall"

/turf/simulated/engine
	name = "engine"
	icon = 'icons/ss13/engine.dmi'

/turf/simulated/engine/floor
	name = "floor"
	icon_state = "floor"
	updatecell = 1

	n2/name = "N2 storage"
	co2/name = "CO2 storage"
	n2o/name = "N2O storage"
	o2/name = "O2 storage"
	plasma/name = "Plasma storage"

	vacuum/New()
		. = ..()
		gas.remove_all_gas()
	n2/New()
		. = ..()
		gas.remove_all_gas()
		gas.add_n2(gas.partial_pressure_to_moles(1000000))
	co2/New()
		. = ..()
		gas.remove_all_gas()
		gas.add_co2(gas.partial_pressure_to_moles(1000000))
	n2o/New()
		. = ..()
		gas.remove_all_gas()
		gas.add_n2o(gas.partial_pressure_to_moles(1000000))
	o2/New()
		. = ..()
		gas.remove_all_gas()
		gas.add_o2(gas.partial_pressure_to_moles(1000000))
	plasma/New()
		. = ..()
		gas.remove_all_gas()
		gas.add_plasma(gas.partial_pressure_to_moles(1000000))

/turf/simulated/floor
	name = "floor"
	icon = 'icons/goonstation/floor.dmi'
	icon_state = "Floor"
	var/health = 150.0
	var/burnt = null
	updatecell = 1

	grid
		icon = 'icons/goonstation/floor.dmi'
		icon_state = "circuit"

	plating
		intact = 0
		name = "plating"
		health = 100
		icon_state = "Floor1"

/turf/simulated/r_wall
	name = "r wall"
	icon = 'icons/ss13/wall.dmi'
	icon_state = "r_wall"
	var/previousArea = null
	opacity = 1
	density = 1
	var/state = 2
	var/d_state = 0
	updatecell = 0

/turf/simulated/shuttle
	name = "shuttle"
	icon = 'icons/ss13/shuttle.dmi'

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"
	updatecell = 1
	floor2/icon_state = "floor2"
	floor3/icon_state = "floor3"
	floor4/icon_state = "floor4"
	floor5/icon_state = "floor5"

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "wall"
	opacity = 1
	density = 1
	updatecell = 0

/turf/simulated/wall
	name = "wall"
	icon = 'icons/ss13/wall.dmi'
	var/previousArea = null
	opacity = 1
	density = 1
	var/state = 2
	updatecell = 0

/turf/DblClick()
	if(istype(usr, /mob/ai))
		return move_camera_by_click()
	if(usr.stat || usr.restrained() || usr.lying)
		return ..()
	if(usr.hand && istype(usr.l_hand, /obj/item/weapon/flamethrower))
		var/turflist = getline(usr,src)
		var/obj/item/weapon/flamethrower/F = usr.l_hand
		F.flame_turf(turflist)
		..()
	else if(!usr.hand && istype(usr.r_hand, /obj/item/weapon/flamethrower))
		var/turflist = getline(usr,src)
		var/obj/item/weapon/flamethrower/F = usr.r_hand
		F.flame_turf(turflist)
		..()
	else return ..()