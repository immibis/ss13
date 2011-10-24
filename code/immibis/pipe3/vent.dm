obj/machinery/atmospherics/unary/vent
	name = "vent"
	icon = 'icons/ss13/pipes.dmi'
	icon_state = "vent"
	desc = "A gas pipe outlet vent."
	anchored = 1
	p_dir = 2
	var/capacity = 6000000
	capmult = 2

	New()
		. = ..()
		spawn
			while(!net)
				sleep(1)
			net.leaks += loc

	Del()
		. = ..()
		if(net)
			net.leaks -= loc

	Move()
		if(net)
			net.leaks -= loc
		. = ..()
		if(net)
			net.leaks += loc

/*	process()
		var/turf/T = src.loc
		equalize_gas(T.gas, gas)

*/