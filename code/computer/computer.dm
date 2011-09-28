obj/machinery/terminal/computer
	var/datum/os/os

	New()
		. = ..()
		os = new/datum/os/thinkdos
		os.term = src
		os.boot()

	command(cmd)
		os.command(cmd)

	power_change()
		. = ..()
		if(stat & NOPOWER)
			os.unboot()
		else
			os.boot()