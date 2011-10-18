obj/machinery/atmospherics/manifold
	name = "manifold"
	icon = 'icons/ss13/pipes.dmi'
	icon_state = "manifold"
	desc = "A three-port gas manifold."
	anchored = 1
	dir = 2
	p_dir = 14
	var/n1dir
	var/n2dir

	var/obj

	var/plnum = 0
	var/obj/machinery/pipeline/pl

	capmult = 3

	New()
		. = ..()
		p_dir = dir | turn(dir, 90) | turn(dir, -90)

	var/datum/pipe_network/net
	var/obj/substance/gas/gas

	get_network(dir)
		return net
	set_network(dir, net)
		src.net = net
	set_gas(dir, gas)
		src.gas = gas

	process()
		if(stat & BROKEN)
			return
		/*if(gas.pressure > 5000000)
			stat = BROKEN
			icon_state = "[icon_state]-b"
			var/turf/T = loc
			if(isturf(T) && !T.density)
				net.leaks += loc*/

obj/machinery/atmospherics/pipes
	parent_type = /obj/machinery/atmospherics

	New()
		. = ..()
		dir = text2num(icon_state)
		p_dir = dir
		if(p_dir in list(NORTH,SOUTH,EAST,WEST))
			p_dir |= turn(p_dir, 180)

	var/datum/pipe_network/net
	var/obj/substance/gas/gas

	get_network(dir)
		return net
	set_network(dir, net)
		src.net = net
	set_gas(dir, gas)
		src.gas = gas

	process()
		if(stat & BROKEN)
			return
		/*if(gas.pressure > 10000000)
			stat = BROKEN
			icon_state = "[icon_state]-b"
			var/turf/T = loc
			if(isturf(T) && !T.density)
				net.leaks += loc*/

	desc = "A stretch of pipe."
	name = "pipe"

	heat_exch
		icon = 'icons/ss13/heat_pipe.dmi'
		name = "heat exchange pipe"
		desc = "A bundle of small pipes designed for maximum heat transfer."
		insulation = HEATPIPERATE
		p_type = PIPE_HEAT_EXCH