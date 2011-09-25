/obj/machinery/vent/filter
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