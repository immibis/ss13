/obj/machinery/atmospherics/binary/freezer
	// moves heat from gas1 to gas2

	// like the TEG, but in reverse

	icon = 'icons/immibis/atmos-freezer.dmi'
	icon_state = "0"

	process()
		if(gas1 && gas2 && gas1.temperature > 0)
			var/gc = gas1.heat_capacity
			var/gh = gas2.heat_capacity

			var/tc = gas1.temperature
			var/th = gas2.temperature
			var/deltat = th-tc

			var/eta = (1-tc/th)*0.65		// efficiency 65% of Carnot

			if(gc > 0 && deltat >0)		// require some cold gas (for sink) and a positive temp gradient
				var/ghoc = gh/gc

				//var/qc = gc*tc
				//var/qh = gh*th

				var/fdt = 1/( (1-eta)*ghoc + 1)	// min timestep

				fdt = min(fdt, 0.1)	// max timestep

				var/q = fdt*(eta)*gh*(deltat)	// heat generated

				// This makes it actually work at high temperatures.
				// It probably makes the formula wrong.
				// In this case I've favoured playability over correctness
				q *= 0.1 / fdt

				var/thp = th - fdt * deltat
				var/tcp = tc + fdt * (1 - eta) * (ghoc) * deltat

				//lastgen = q * GENRATE
				//add_avail(lastgen)

				gas1.set_temp(tcp)
				gas2.set_temp(thp)

			else
				lastgen = 0





			// update icon overlays only if displayed level has changed

			var/genlev = max(0, min( round(11*lastgen / 100000), 11))
			if(genlev != lastgenlev)
				lastgenlev = genlev
				updateicon()

			src.updateDialog()