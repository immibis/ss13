/obj/machinery/atmospherics/binary/freezer
	// moves heat from gas1 to gas2

	// like the TEG, but in reverse

	icon = 'icons/immibis/atmos-freezer.dmi'
	icon_state = "0"

	process()
		if(gas1 && gas2 && gas1.temperature > 0)
			var/gc = gas1.heat_capacity
			var/gh = gas2.heat_capacity

			if(gc < 0.0001 || gh < 0.0001)
				return

			var/tc = gas1.temperature
			var/th = gas2.temperature

			var/power = 1000 // max power to consume
			var/mintemp = T0C

			if(tc < mintemp)
				world << "[tc] < [mintemp]"
				return

			// cop_h = heat output / electricity consumed
			// cop_c = cop_h - 1 = heat input / electricity consumed

			var/cop_h = (th/max(0.01, th-tc))*0.65		// efficiency 65% of Carnot

			cop_h = min(cop_h, 10) // maximum COP

			if(!powered(ENVIRON))
				return

			var/q = power // power consumed

			// ensure tcp >= mintemp
			q = min(q, (tc - mintemp) / (cop_h - 1) * gc)

			var/thp = th + q * cop_h / gh
			var/tcp = tc - q * (cop_h - 1) / gc

			if(q > 0)
				use_power(q, ENVIRON)

			gas1.set_temp(tcp)
			gas2.set_temp(thp)
