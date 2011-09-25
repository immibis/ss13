/obj/machinery/atmospherics/unary/inlet
	name = "inlet"
	icon = 'icons/ss13/pipes.dmi'
	icon_state = "inlet"
	desc = "A gas pipe inlet."
	anchored = 1
	p_dir = 2
	var/capacity = 6000000
	capmult = 2

	// inlet - equilibrates between pipe contents and turf
	// very similar to vent, except that a vent always dumps pipe gas into turf

	process()

		var/turf/T = src.loc

		// this is the difference between vent and inlet

		if(T && !T.density)
			net.flow_to_turf(T) // act as gas leak



