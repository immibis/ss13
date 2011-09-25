obj/machinery/atmospherics/unary/vent
	name = "vent"
	icon = 'icons/ss13/pipes.dmi'
	icon_state = "vent"
	desc = "A gas pipe outlet vent."
	anchored = 1
	p_dir = 2
	var/capacity = 6000000
	capmult = 2

	process()
		var/turf/T = src.loc
		equalize_gas(T.gas, gas)

