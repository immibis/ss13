/obj/machinery/atmospherics/unary/vent/filter
	name = "filter vent"
	icon = 'icons/ss13/pipes.dmi'
	icon_state = "vent_filter-0"
	desc = "A gas pipe outlet vent with a remote controlled filter on it."
	var/control = null
	var/f_mask = 0

	power_change()
		if(powered(ENVIRON))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		spawn(rand(1,15))
			updateicon()

	proc/updateicon()
		if(stat & NOPOWER)
			icon_state = "vent_filter-0"
			return
		if(src.gas.tot_gas() > src.gas.maximum/2)
			icon_state = "vent_filter-4"
		else if(src.gas.tot_gas() > src.gas.maximum/3)
			icon_state = "vent_filter-3"
		else if(src.gas.tot_gas() > src.gas.maximum/4)
			icon_state = "vent_filter-2"
		else if(src.gas.tot_gas() >= 1 || src.f_mask >= 1)
			icon_state = "vent_filter-1"
		else
			icon_state = "vent_filter-0"
		return