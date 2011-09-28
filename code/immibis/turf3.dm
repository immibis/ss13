
turf
	var/obj/substance/gas
		gas
		ngas

	var/updatecell = null
	var/ignite = 0

	proc/isempty()
		if(density)
			return 0
		for(var/atom/A in src)
			if(A.density)
				return 0
		return 1

	proc/AddHotspot()
	proc/RemoveHotspot()

turf/simulated
	var/airdir = null
	var/airforce = null
	var/checkfire = 1.0
	var/atmoalt = null

	var/tmp/atmos_sleeping = null

	level = 1.0

	// the turfs to the N,S,E & W
	var/tmp/turf/linkN
	var/tmp/turf/linkS
	var/tmp/turf/linkE
	var/tmp/turf/linkW

	// whether those turfs are air-connected
	var/tmp/airN
	var/tmp/airS
	var/tmp/airE
	var/tmp/airW

	// whether to use special conduction heat transfer (through windows only)

	var/tmp/condN
	var/tmp/condS
	var/tmp/condE
	var/tmp/condW

	var/overlay_state = 0

	var/obj/hotspot/hotspot = null

	AddHotspot()
		if(!hotspot)
			hotspot = new(src)

	RemoveHotspot()
		if(hotspot)
			del(hotspot)

	proc/Neighbors()
		var/list/L = cardinal.Copy()
		for(var/obj/machinery/door/window/D in src)
			if(!D.density)
				continue

			if (D.dir & 12)
				L -= SOUTH
			else
				L -= EAST

		for(var/obj/window/D in src)
			if(!D.density)
				continue
			L -= D.dir
			if (D.dir == SOUTHWEST)
				L.len = 0
				return L
		return L

	proc/FindTurfs()
		var/list/L = list()
		for(var/dir in src.Neighbors())
			var/turf/T = get_step(src, dir)

			if(!T || !T.updatecell)
				continue

			L += T
			var/direct = turn(dir, 180)

			for(var/obj/machinery/door/window/D in T)
				if(!D.density)
					continue
				if (D.dir & 12)
					if(dir & 1)
						L -= T
				else if(dir & 8)
					L -= T

			for(var/obj/window/D in T)
				if(!D.density)
					continue
				if (D.dir == SOUTHWEST || D.dir == direct)
					L -= T

		return L

	New()
		. = ..()
		checkfire = ((src.x & 1) == (src.y & 1))
		gas = new
		gas.volume = 2
		gas.add_o2(gas.partial_pressure_to_moles(O2_STANDARD))
		gas.add_n2(gas.partial_pressure_to_moles(N2_STANDARD))
		ngas = new
		ngas.copy_from(gas)



	proc/setlink(dir, var/turf/T)

		switch(dir)
			if(1)
				linkN = T
			if(2)
				linkS = T
			if(4)
				linkE = T
			if(8)
				linkW = T

	proc/setairlink(dir, val)

		switch(dir)
			if(1)
				airN = val
			if(2)
				airS = val
			if(4)
				airE = val
			if(8)
				airW = val

	proc/setcondlink(dir, val)

		switch(dir)
			if(1)
				condN += val
			if(2)
				condS += val
			if(4)
				condE += val
			if(8)
				condW += val

	buildlinks()				// call this one to update a cell and neighbours (on cell state change)
		updatelinks()

		for(var/dir in cardinal)
			var/turf/simulated/T = get_step(src,dir)
			if(T && istype(T))
				T.updatelinks()

	proc/updatelinks()			// this does updating for a single cell

		airN = null
		airS = null
		airE = null
		airW = null

		condN = 0
		condS = 0
		condE = 0
		condW = 0

		// originally in turf/Neighbors()

		var/list/NL = cardinal.Copy()

		for(var/obj/machinery/door/window/D in src)
			if(!D.density)
				continue

			if (D.dir & 12)
				NL -= SOUTH
				condS = 1
			else
				NL -= EAST
				condE = 1


		for(var/obj/window/D in src)
			if(!D.density)
				continue
			NL -= D.dir
			setcondlink(D.dir, 1+D.reinf)

			if (D.dir == SOUTHWEST)
				NL.len = null
				break



		for(var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			setlink(dir,T)

			if(!T || !T.updatecell || !(dir in NL))
				continue

			setairlink(dir, 1)

			var/direct = turn(dir, 180)

			for(var/obj/machinery/door/window/D in T)
				if(!D.density)
					continue

				if (D.dir & 12)
					if((dir & 1))
						setairlink(dir, null)
						setcondlink(dir, 1)
				else if(dir & 8)
					setairlink(dir, null)
					setcondlink(dir, 1)

			for(var/obj/window/D in T)
				if(!D.density)
					continue
				if(D.dir == SOUTHWEST || D.dir == direct)
					setairlink(dir, null)
					setcondlink(dir, 1+D.reinf)

	proc/FindLinkedTurfs()
		var/list/L = list()
		if(airN)
			L += linkN
		if(airS)
			L += linkS
		if(airE)
			L += linkE
		if(airW)
			L += linkW
		return L


	proc/report()
		return "[src.type] [x] [y] [z]"


	updatecell()
		if(atmos_sleeping)
			return

		checkfire = !checkfire

		var/divideby = 1
		var/space = 0
		var/adiff
		var/burn = 0

		ngas.copy_from(gas)

		var/obj/substance/gas/total = new
		total.copy_from(gas)
		var/total_temp = gas.temperature
		var/total_shc = gas.specific_heat_capacity()

		var/list/air = list(airN, airS, airE, airW)
		var/list/link = list(linkN, linkS, linkE, linkW)
		var/list/dir = list(NORTH, SOUTH, EAST, WEST)

		for(var/k in 1 to 4)
			if(air[k])
				var/turf/simulated/T = link[k]
				if(T.type == /turf/space)
					space = 1
					break
				if(!istype(T))
					continue
				total.add_delta(T.gas)
				total_temp += T.gas.temperature
				total_shc += T.gas.specific_heat_capacity()
				divideby++
				if(!checkfire)
					adiff = gas.pressure - T.gas.pressure
					if (adiff > src.airforce)
						src.airforce = adiff
						src.airdir = dir[k]
				else if(T.hotspot)
					burn = 1

		if(total_shc == 0)
			return

		if (space)
			ngas.set_temp(2.7)
			ngas.remove_all_gas()
			if(overlay_state)
				overlays = null
				overlay_state = 0
			return
		else
			total.divide_scalar(divideby)
			total.set_temp(total_temp / divideby)
			total.amt_changed()
			ngas.copy_from(total)

			var/total_movement = abs(ngas.pressure - gas.pressure)

			if(total_movement < GAS_SLEEP_FLOW && !(locate(/obj/machinery) in src))
				atmos_sleeping = 1
			else if(total_movement > GAS_WAKE_FLOW)
				for(var/turf/simulated/T in list(linkN, linkS, linkE, linkW))
					if(T && isturf(T))
						T.atmos_sleeping = 0

		if(ngas.plasma > 8) // about 10% of one atmosphere at 20 degrees C
			if(ngas.n2o > 1)
				if(overlay_state != 3)
					overlays = list(plmaster, slmaster)
					overlay_state = 3
			else
				if(overlay_state != 2)
					overlays = list( plmaster )
					overlay_state = 2
		else
			if (ngas.n2o > 1)
				if(overlay_state != 1)
					overlays = list( slmaster )
					overlay_state = 1
			else
				if(overlay_state)
					overlays = null
					overlay_state = 0

		if(checkfire)
			if(ngas.temperature > T20C + 80 || burn || src.ignite || src.firelevel >= 900000)
				src.firelevel = (ngas.plasma + ngas.o2 - ngas.co2) * 100000
			if(src.firelevel >= 900000.0 && ngas.plasma > FIRE_PL_USE && ngas.o2 > FIRE_O2_USE)
				if(!hotspot)
					src.AddHotspot()

//				var/shc = ngas.specific_heat_capacity()
				// rate is minimum of the partial pressures of plasma (divided by FIRE_PL_USE) and oxygen (divided by FIRE_O2_USE)
				var/rate = min(ngas.plasma/ngas.total_moles*ngas.pressure/FIRE_PL_USE, ngas.o2/ngas.total_moles*ngas.pressure/FIRE_O2_USE)

				rate /= FIRERATE

				if(rate * FIRE_O2_USE > FIRE_O2_MAX)
					rate = FIRE_O2_MAX / FIRE_O2_USE
				if(rate * FIRE_PL_USE > FIRE_PL_MAX)
					rate = FIRE_PL_MAX / FIRE_PL_USE

				var/o2use = rate * FIRE_O2_USE
				var/pluse = rate * FIRE_PL_USE

				if(ngas.o2 < o2use)
					pluse *= (ngas.o2 / o2use)
					o2use = ngas.o2
				if(ngas.plasma < pluse)
					o2use *= (ngas.plasma / pluse)
					pluse = ngas.plasma

				if(o2use == 0 || pluse == 0)
					src.firelevel = 0

				// this should really add heat instead of temperature,
				// but a lot of stuff works better this way, even though
				// it's different from real life
				var/target_temp = (src.firelevel + FIREOFFSET) / FIREQUOT + T20C
				if(target_temp > ngas.temperature)
					ngas.set_temp(ngas.temperature*0.9 + target_temp*0.1)

				ngas.plasma -= pluse
				ngas.o2 -= o2use
				ngas.co2 += pluse + o2use
				ngas.amt_changed()

				if (locate(/obj/effects/water, src))
					src.firelevel = 0
				for(var/atom/movable/A in src)
					A.burn(src.firelevel)
			else
				src.firelevel = 0
				if(hotspot)
					RemoveHotspot()
			src.ignite = 0
		else
			if (src.airforce > 25000)
				for(var/atom/movable/AM in src)
					if (!AM.anchored && AM.weight <= src.airforce)
						step(AM, src.airdir)

		if(locate(/obj/effects/water, src))
			src.firelevel = 0
			//cool due to water
			ngas.temperature += (T20C - ngas.temperature) / FIRERATE

		if(src.firelevel < 900000)
			src.firelevel = 0



	proc/replace_gas()
		gas.copy_from(ngas)

	conduction()

		var/difftemp = 0
		for(var/turf/T in FindCondTurfs())
			var/cond = getCond(get_dir(src, T))
			difftemp += (T.gas.temperature-ngas.temperature)/(10*cond)

		ngas.temperature += difftemp


	proc/FindCondTurfs()
		var/list/L = list()
		if(condN)
			L += linkN
		if(condS)
			L += linkS
		if(condE)
			L += linkE
		if(condW)
			L += linkW
		return L

	proc/getCond(dir)
		switch(dir)
			if(NORTH)
				return condN
			if(SOUTH)
				return condS
			if(EAST)
				return condE
			if(WEST)
				return condW
		return null