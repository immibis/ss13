obj/machinery/terminal/computer
	var/datum/os/os

	New()
		. = ..()
		os = new/datum/os/thinkdos
		os.term = src

	command(cmd, user)
		os.command(cmd, user)

	var/prev_power = 0

	power_change()
		. = ..()
		if(stat & NOPOWER)
			if(prev_power)
				os.unboot()
				prev_power = 0
		else
			if(!prev_power)
				os.boot()
				prev_power = 1