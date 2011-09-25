turf/var/tmp/atmos_sleeping = 0

#ifdef USE_OBJ_MOVE

/obj/move/CheckPass(O as mob|obj)
	return !src.density

/obj/move/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/move/attack_hand(var/mob/user as mob)
	if (!user.canmove || user.restrained() || !user.pulling)
		return
	if (user.pulling.anchored)
		return
	if (user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1)
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/obj/move/proc/res_vars()
	oldoxy = oxygen
	tmpoxy = oxygen

	oldpoison = poison
	tmppoison = poison

	oldco2 = co2
	tmpco2 = co2

	osl_gas = sl_gas
	tsl_gas = sl_gas

	on2 = src.n2
	tn2 = src.n2

	otemp = temp
	ttemp = temp

	return

/obj/move/proc/relocate(T as turf, degree)
	if (degree)
		for(var/atom/movable/A as mob|obj in src.loc)
			A.dir = turn(A.dir, degree)
			//*****RM as 4.1beta
			A.loc = T
	else
		for(var/atom/movable/A as mob|obj in src.loc)
			A.loc = T
	return

/obj/move/proc/unburn()
	RemoveHotspot()
	src.icon_state = initial(src.icon_state)
	return


/obj/move/proc/Neighbors()
	var/list/L = cardinal.Copy()
	for(var/obj/machinery/door/window/D in src.loc)
		if(!( D.density ))
			continue

		//++++++
		//L -= D.dir

		if (D.dir & 12)
			L -= SOUTH
		else
			L -= EAST

	for(var/obj/window/D in src.loc)
		if(!( D.density ))
			continue
		L -= D.dir
		if (D.dir == SOUTHWEST)
			L.len = null
			return L

	return L

/obj/move/proc/FindTurfs()
	var/list/L = list(  )
	for(var/dir in src.Neighbors())
		var/turf/T = get_step(src.loc, dir)


		if(T)
			T.atmos_sleeping = 0
			L += T
			var/direct = turn(dir, 180)
			//*****RM as 4.1beta

			for(var/obj/machinery/door/window/D in T)
				if(!D.density)
					continue
				if(D.dir & 12)
					if(dir & 1)
						L -= T
				else
					if(dir & 8)
						L -= T

			for(var/obj/window/D in T)
				if(!D.density)
					continue
				if(D.dir == SOUTHWEST || D.dir == direct)
					L -= T
		if (locate(/obj/move, T) && T in L)
			L -= T
			var/obj/move/O = locate(/obj/move, T)
			if (O.updatecell)
				L += O
		else
			if ((isturf(T) && !( T.updatecell )))
				L -= T

	return L


/obj/move/proc/tot_gas()
	return co2 + oxygen + poison + sl_gas + n2

/obj/move/var/tmp/overlay_state = 0

/obj/move/proc/process()
	if(locate(/obj/shuttle/door, src.loc))
		var/obj/shuttle/door/D = locate(/obj/shuttle/door, src.loc)
		src.updatecell = !(D.density)
	for(var/obj/machinery/door/D2 in src.loc)
		if(D2 && D2.density)
			src.updatecell = !(D2.density)
			break
	if (!src.updatecell)
		return
	src.checkfire = !src.checkfire

	var/divideby = 1
	var/total = src.oxygen
	var/tpoison = src.poison
	var/tco2 = src.co2
	var/tosl_gas = src.sl_gas
	var/ton2 = src.n2
	var/totemp = src.temp
	var/space = 0
	var/adiff
	var/burn = 0

	if(cellcontrol.var_swap)
		for(var/o in src.FindTurfs())
			var/turf/T = o
			if(T.type == /turf/space)
				space = 1
				break
			divideby++
			total += T.oldoxy
			tpoison += T.oldpoison
			tco2 += T.oldco2
			tosl_gas += T.osl_gas
			ton2 += T.on2
			totemp += T.otemp
			if(!checkfire)
				adiff = src.oldoxy + src.oldco2 + src.on2 - (T.oldoxy + T.oldco2 + T.on2)
				if (adiff > src.airforce)
					src.airforce = adiff
					src.airdir = get_dir(src, T)
			else if(T.firelevel >= 900000)
				burn = 1
	else
		for(var/o in src.FindTurfs())
			var/turf/T = o
			if(T.type == /turf/space)
				space = 1
				break
			divideby++
			total += T.tmpoxy
			tpoison += T.tmppoison
			tco2 += T.tmpco2
			tosl_gas += T.tsl_gas
			ton2 += T.tn2
			totemp += T.ttemp
			if(!checkfire)
				adiff = src.oldoxy + src.oldco2 + src.on2 - (T.oldoxy + T.oldco2 + T.on2)
				if (adiff > src.airforce)
					src.airforce = adiff
					src.airdir = get_dir(src, T)
			else if(T.firelevel >= 900000)
				burn = 1


	if (space)
		src.oxygen = 0
		src.poison = 0
		src.co2 = 0
		src.sl_gas = 0
		src.n2 = 0
		src.temp = 0
		if(overlay_state)
			overlays = null
			overlay_state = 0
		return
	else
		src.oxygen = total / divideby
		src.poison = tpoison / divideby
		src.co2 = tco2 / divideby
		src.sl_gas = tosl_gas / divideby
		src.n2 = ton2 / divideby
		src.temp = totemp / divideby
	if (src.poison > 100000.0)
		if(src.sl_gas > 101000.0)
			if(overlay_state != 3)
				overlays = list(plmaster, slmaster)
				overlay_state = 3
		else
			if(overlay_state != 2)
				overlays = list( plmaster )
				overlay_state = 2
	else
		if (src.sl_gas > 101000.0)
			if(overlay_state != 1)
				overlays = list( slmaster )
				overlay_state = 1
		else
			if(overlay_state)
				overlays = null
				overlay_state = 0
	if(checkfire)
		if (src.temp > T20C + 180 || burn)
			src.firelevel = src.oxygen + src.poison

		if (src.firelevel >= 900000.0 && src.poison > 100)
			src.AddHotspot()
			src.luminosity = 2
			if (src.oxygen > 400)
				src.co2 += 400
				src.oxygen -= 400
			else
				src.oxygen = 0
				src.firelevel = 0

			// heating from fire
			temp += (firelevel/FIREQUOT+FIREOFFSET - temp) / FIRERATE

			src.poison = max(0, src.poison - 2000)
			if(src.poison == 0)
				firelevel = 0
			else
				src.co2 += 2000
			if (locate(/obj/effects/water, src))
				src.firelevel = 0
			for(var/atom/movable/A in src)
				A.burn(src.firelevel)
		else
			src.firelevel = 0
			if (src.has_fire_icon)
				unburn()
	else
		if (src.airforce > 25000)
			for(var/atom/movable/AM in src)
				if (!AM.anchored && AM.weight <= src.airforce)
					step(AM, src.airdir)
	if(cellcontrol.var_swap)
		src.tmpoxy = src.oxygen
		src.tmppoison = src.poison
		src.tmpco2 = src.co2
		src.tsl_gas = src.sl_gas
		src.tn2 = src.n2
		src.ttemp = src.temp
	else
		src.oldoxy = src.oxygen
		src.oldpoison = src.poison
		src.oldco2 = src.co2
		src.osl_gas = src.sl_gas
		src.on2 = src.n2
		src.otemp = src.temp

	if ((locate(/obj/effects/water, src) || src.firelevel < 900000.0))
		src.firelevel = 0
		//cool due to water
		temp += (T20C - temp) / FIRERATE

/obj/move/wall/New()
	var/F = locate(/obj/move/floor, src.loc)
	if (F)
		del(F)

/obj/move/wall/process()
	src.updatecell = 0

/obj/move/wall/blob_act()
	del(src)

/obj/move/New()
	if((src.x & 1) == (src.y & 1))
		src.checkfire = 0
	src.tmpoxy = src.oxygen
	src.oldoxy = src.oxygen
	src.tmppoison = src.poison
	src.oldpoison = src.poison
	src.tmpco2 = src.co2
	src.oldco2 = src.co2
	src.tn2 = src.n2
	src.on2 = src.n2

	otemp = temp
	ttemp = temp
	..()

#endif

/turf/proc/res_vars()

	src.oldoxy = src.oxygen
	src.tmpoxy = src.oxygen
	src.oldpoison = src.poison
	src.tmppoison = src.poison
	src.oldco2 = src.co2
	src.tmpco2 = src.co2
	src.osl_gas = src.sl_gas
	src.tsl_gas = src.sl_gas
	src.on2 = src.n2
	src.tn2 = src.n2
	otemp = temp
	ttemp = temp
	return

/turf/var/tmp/obj/hotspot/hotspot = null

/turf/proc/AddHotspot()
	if(hotspot) return
	hotspot = new/obj/hotspot(src)

/turf/proc/RemoveHotspot()
	if(!hotspot) return
	del(hotspot)

/turf/proc/unburn()
	src.RemoveHotspot()
	src.icon_state = initial(src.icon_state)
	return


//*****


// returns 0 if turf is dense or contains a dense object
// returns 1 otherwise
/turf/proc/isempty()
	if(src.density)
		return 0
	for(var/atom/A in src)
		if(A.density)
			return 0
	return 1


/turf/proc/Neighbors()

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
			L.len = null
			return L
	return L

/turf/proc/FindTurfs()

	var/list/L = list(  )
	if (locate(/obj/move, src))
		return list(  )
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


	for(var/turf/T in L)
		if (locate(/obj/move, T))
			L -= T
			var/obj/move/O = locate(/obj/move, T)
			if (O.updatecell)
				L += O
	return L

/turf/New()

	if ((src.x & 1) == (src.y & 1))
		src.checkfire = 0
	src.tmpoxy = src.oxygen
	src.oldoxy = src.oxygen
	src.tmppoison = src.poison
	src.oldpoison = src.poison
	src.tmpco2 = src.co2
	src.oldco2 = src.co2
	src.osl_gas = src.sl_gas
	src.tsl_gas = src.sl_gas
	src.on2 = src.n2
	src.tn2 = src.n2

	otemp = temp
	ttemp = temp

	..()
	return


/turf/proc/setlink(dir, var/turf/T)

	switch(dir)
		if(1)
			linkN = T
		if(2)
			linkS = T
		if(4)
			linkE = T
		if(8)
			linkW = T

/turf/proc/setairlink(dir, val)

	switch(dir)
		if(1)
			airN = val
		if(2)
			airS = val
		if(4)
			airE = val
		if(8)
			airW = val

/turf/proc/setcondlink(dir, val)

	switch(dir)
		if(1)
			condN += val
		if(2)
			condS += val
		if(4)
			condE += val
		if(8)
			condW += val

/turf/buildlinks()				// call this one to update a cell and neighbours (on cell state change)
	updatelinks()

	for(var/dir in cardinal)
		var/turf/T = get_step(src,dir)
		if(T)
			T.updatelinks()

/turf/proc/updatelinks()			// this does updating for a single cell

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


		var/obj/move/O = locate(/obj/move, T)
		if(O)
			setlink(dir, O)
			if(!O.updatecell)
				continue

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

/turf/proc/FindLinkedTurfs()
	var/list/L = list(  )
	if(airN)
		L += linkN
	if(airS)
		L += linkS
	if(airE)
		L += linkE
	if(airW)
		L += linkW

	return L


/turf/proc/report()
	return "[src.type] [x] [y] [z]"


// return the total gas contents of a turf

/turf/proc/tot_gas()
	return co2 + oxygen + poison + sl_gas + n2

turf/proc/tot_old_gas()
	return oldco2 + oldoxy + oldpoison + osl_gas + on2

/turf/proc/tot_tmp_gas()
	return tmpco2 + tmpoxy + tmppoison + tsl_gas + tn2


// return the gas contents of a turf as a gas obj

/turf/proc/get_gas()

	var/obj/substance/gas/tgas = new()

	tgas.oxygen = src.oxygen
	tgas.n2 = src.n2
	tgas.plasma = src.poison
	tgas.co2 = src.co2
	tgas.sl_gas = src.sl_gas
	tgas.temperature = src.temp
	tgas.maximum = CELLSTANDARD		// not actually a maximum

	return tgas

turf/var/tmp/overlay_state = 0

turf/updatecell()

	if(atmos_sleeping)
		return

	src.checkfire = !src.checkfire

	var/divideby = 1
	var/total = src.oxygen
	var/tpoison = src.poison
	var/tco2 = src.co2
	var/tosl_gas = src.sl_gas
	var/ton2 = src.n2
	var/totemp = src.temp
	var/space = 0
	var/adiff
	var/burn = 0

	var/list/air = list(airN, airS, airE, airW)
	var/list/link = list(linkN, linkS, linkE, linkW)
	var/list/dir = list(NORTH, SOUTH, EAST, WEST)
	if(cellcontrol.var_swap)
		for(var/k in 1 to 4)
			if(air[k])
				var/turf/T = link[k]
				if(T.type == /turf/space)
					space = 1
					break
				divideby++
				total += T.oldoxy
				tpoison += T.oldpoison
				tco2 += T.oldco2
				tosl_gas += T.osl_gas
				ton2 += T.on2
				totemp += T.otemp
				//if(checkfire)
				//	if(T.firelevel >= 900000.0)
				//		burn = 1
				//else
				if(!checkfire)
					adiff = src.oldoxy + src.oldco2 + src.on2 + src.oldpoison + src.osl_gas - (T.oldoxy + T.oldco2 + T.on2 + T.oldpoison + T.osl_gas)
					if (adiff > src.airforce)
						src.airforce = adiff
						src.airdir = dir[k]
				else if(T.firelevel >= 900000)
					burn = 1
	else
		for(var/k in 1 to 4)
			if(air[k])
				var/turf/T = link[k]
				if(T.type == /turf/space)
					space = 1
					break
				divideby++
				total += T.tmpoxy
				tpoison += T.tmppoison
				tco2 += T.tmpco2
				tosl_gas += T.tsl_gas
				ton2 += T.tn2
				totemp += T.ttemp
				//if(checkfire)
				//	if(T.firelevel >= 900000.0)
				//		burn = 1
				//else
				if(!checkfire)
					adiff = src.tmpoxy + src.tmpco2 + src.tn2 + src.tmppoison + src.tsl_gas - (T.tmpoxy + T.tmpco2 + T.tn2 + T.tmppoison + T.tsl_gas)
					if (adiff > src.airforce)
						src.airforce = adiff
						src.airdir = dir[k]
				else if(T.firelevel >= 900000)
					burn = 1


	if (space)
		src.oxygen = 0
		src.poison = 0
		src.co2 = 0
		src.sl_gas = 0
		src.n2 = 0
		src.temp = 0
		if(overlay_state)
			overlays = null
			overlay_state = 0
		return
	else
		src.oxygen = total / divideby
		src.poison = tpoison / divideby
		src.co2 = tco2 / divideby
		src.sl_gas = tosl_gas / divideby
		src.n2 = ton2 / divideby
		src.temp = totemp / divideby
		var/total_movement = 0
		if(cellcontrol.var_swap)
			total_movement = abs(src.oxygen - src.oldoxy)
			total_movement += abs(src.poison - src.oldpoison)
			total_movement += abs(src.co2 - src.oldco2)
			total_movement += abs(src.sl_gas - src.osl_gas)
			total_movement += abs(src.n2 - src.on2)
			total_movement += abs(src.temp - src.otemp)*100
		else
			total_movement = abs(src.oxygen - src.tmpoxy)
			total_movement += abs(src.poison - src.tmppoison)
			total_movement += abs(src.co2 - src.tmpco2)
			total_movement += abs(src.sl_gas - src.tsl_gas)
			total_movement += abs(src.n2 - src.tn2)
			total_movement += abs(src.temp - src.ttemp)*100
		if(total_movement < GAS_SLEEP_FLOW && !(locate(/obj/machinery) in src))
			atmos_sleeping = 1
		else if(total_movement > GAS_WAKE_FLOW)
			for(var/turf/T in list(linkN, linkS, linkE, linkW))
				if(T && isturf(T))
					T.atmos_sleeping = 0
	if (src.poison > 100000.0)
		if(src.sl_gas > 101000.0)
			if(overlay_state != 3)
				overlays = list(plmaster, slmaster)
				overlay_state = 3
		else
			if(overlay_state != 2)
				overlays = list( plmaster )
				overlay_state = 2
	else
		if (src.sl_gas > 101000.0)
			if(overlay_state != 1)
				overlays = list( slmaster )
				overlay_state = 1
		else
			if(overlay_state)
				overlays = null
				overlay_state = 0

	if(checkfire)
		if (src.temp > T20C + 180 || burn)
			src.firelevel = src.oxygen + src.poison
		if (src.firelevel >= 900000.0 && src.poison > 2000 && src.oxygen > 400)
			src.AddHotspot()
			if (src.oxygen > 400)
				src.co2 += 400
				src.oxygen -= 400
			else
				src.oxygen = 0
				src.firelevel = 0

			// heating from fire
			temp += (firelevel/FIREQUOT+FIREOFFSET - temp) / (FIRERATE * (temp > FIREMAXTEMP ? 1000 : 1))

			src.poison = max(0, src.poison - 2000)
			if(src.poison == 0)
				firelevel = 0
			else
				src.co2 += 2000
			if (locate(/obj/effects/water, src))
				src.firelevel = 0
			for(var/atom/movable/A in src)
				A.burn(src.firelevel)
		else
			src.firelevel = 0
			if (hotspot)
				unburn()
	else
		if (src.airforce > 25000)
			for(var/atom/movable/AM in src)
				if (!AM.anchored && AM.weight <= src.airforce)
					step(AM, src.airdir)
	if(cellcontrol.var_swap)
		src.tmpoxy = src.oxygen
		src.tmppoison = src.poison
		src.tmpco2 = src.co2
		src.tsl_gas = src.sl_gas
		src.tn2 = src.n2
		src.ttemp = src.temp
	else
		src.oldoxy = src.oxygen
		src.oldpoison = src.poison
		src.oldco2 = src.co2
		src.osl_gas = src.sl_gas
		src.on2 = src.n2
		src.otemp = src.temp

	if(locate(/obj/effects/water, src))
		src.firelevel = 0
		//cool due to water
		temp += (T20C - temp) / FIRERATE

	if(src.firelevel < 900000)
		src.firelevel = 0

/turf/conduction()

	var/difftemp = 0
	for(var/turf/T in FindCondTurfs())
		var/cond = getCond(get_dir(src, T))
		difftemp += (T.otemp-src.temp)/(10*cond)

	temp += difftemp


/turf/proc/FindCondTurfs()

	var/list/L = list(  )
	if(condN)
		L += linkN
	if(condS)
		L += linkS
	if(condE)
		L += linkE
	if(condW)
		L += linkW

	return L

/turf/proc/getCond(dir)
	switch(dir)
		if(1)
			return condN
		if(2)
			return condS
		if(4)
			return condE
		if(8)
			return condW
	return 0