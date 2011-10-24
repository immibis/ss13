/obj/machinery/atmospherics/unary/inlet/filter
	name = "filter inlet"
	icon = 'icons/ss13/pipes.dmi'
	icon_state = "inlet_filter-0"
	desc = "A gas pipe inlet with a remote controlled filter on it."
	var/control = null
	var/f_mask = 0

	process()
		src.updateicon()
		if(!(stat & NOPOWER))
			var/turf/T = src.loc
			if(!T || T.density)	return

			var/obj/substance/gas/exterior = T.gas
			var/obj/substance/gas/interior = gas

			var/flow_rate = (exterior.pressure - interior.pressure)*FLOWFRAC
			if(flow_rate <= 0)
				return
			var/obj/substance/gas/flowing = exterior.get_frac(flow_rate / exterior.pressure)
			if(!(src.f_mask & GAS_O2))	flowing.o2		= 0
			if(!(src.f_mask & GAS_N2))	flowing.n2		= 0
			if(!(src.f_mask & GAS_PL))	flowing.plasma	= 0
			if(!(src.f_mask & GAS_CO2))	flowing.co2		= 0
			if(!(src.f_mask & GAS_N2O))	flowing.n2o		= 0
			use_power(FILTER_INLET_POWER,ENVIRON)
			exterior.sub_delta(flowing)
			interior.add_delta(flowing)
		else
			..()
		return


	power_change()
		if(powered(ENVIRON))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		spawn(rand(1,15))
			updateicon()
		return

	proc/updateicon()
		if(stat & NOPOWER)
			icon_state = "inlet_filter-0"
			return
		if(!gas)
			icon_state = "inlet_filter-0"
			return
		if(src.gas.total_moles >= 4)
			icon_state = "inlet_filter-4"
		else if(src.gas.total_moles >= 3)
			icon_state = "inlet_filter-3"
		else if(src.gas.total_moles >= 2)
			icon_state = "inlet_filter-2"
		else if(src.gas.total_moles >= 1 || src.f_mask >= 1)
			icon_state = "inlet_filter-1"
		else
			icon_state = "inlet_filter-0"
		return
