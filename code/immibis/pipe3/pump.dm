/obj/machinery/atmospherics/binary/oneway/pipepump
	name = "Pipe pump"
	desc = "A machine that pushes gas as hard as it can from one side to the other."
	icon = 'icons/ss13/pipes2.dmi'
	icon_state = "pipepump-run"
	var/rate = 1000000.0

	process()
		if(!(stat & NOPOWER))
			gas1.transfer_from(gas2, min(rate, gas2.total_moles/2))
			use_power(PIPE_PUMP_POWER, ENVIRON)

	proc/updateicon()
		icon_state = "pipepump-[(stat & NOPOWER) ? "stop" : "run"]"

	power_change()
		if(powered(ENVIRON))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		updateicon()
