/obj/machinery/atmospherics/binary/oneway/pipepump
	name = "Pipe pump"
	desc = "A machine that pumps gas."
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

/obj/machinery/atmospherics/binary/oneway/pcpump
	name = "Pressure controlled pump"
	desc = "A machine that pumps gas up to a predefined pressure limit."
	icon = 'icons/ss13/pipes2.dmi'
	icon_state = "pcpump-run"
	var/rate = 1000000.0
	var/target_pressure = 101.3 // kPa in map, Pa in game
	var/running = 1

	New()
		target_pressure *= 1000
		. = ..()

	examine()
		. = ..()
		usr << "Target pressure: [round(target_pressure/1000,0.1)] kPa"

	process()
		if(!(stat & NOPOWER))
			var/amt = min(rate, gas2.total_moles/2)
			amt = min(amt, gas1.partial_pressure_to_moles(target_pressure) - gas1.total_moles)
			if(amt < 0.01)
				if(running)
					running = 0
					updateicon()
			else
				if(!running)
					running = 1
					updateicon()
				gas1.transfer_from(gas2, amt)
				use_power(PIPE_PUMP_POWER, ENVIRON)

	proc/updateicon()
		icon_state = "pcpump-[(stat & NOPOWER) || !running ? "stop" : "run"]"

	power_change()
		if(powered(ENVIRON))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		updateicon()
