/obj/item/weapon/tank/blob_act()
	if(prob(25))
		var/turf/T = src.loc
		if (!( istype(T, /turf) ))
			return
		if(src.gas)
			T.gas.add_delta(src.gas)
		del(src)

/obj/item/weapon/tank/attack_self(mob/user as mob)
	user.machine = src
	if (!( src.gas ))
		return
	var/dat = text("<TT><B>Tank</B><BR>\n<FONT color = 'blue'><B>Pressure</B> [] kPa</FONT><BR>\nInterals Valve: <A href='?src=\ref[];stat=1'>[] Gas Flow</A><BR>\n\t<A href='?src=\ref[];cp=-50'>-</A> <A href='?src=\ref[];cp=-5'>-</A> <A href='?src=\ref[];cp=-1'>-</A> [] <A href='?src=\ref[];cp=1'>+</A> <A href='?src=\ref[];cp=5'>+</A> <A href='?src=\ref[];cp=50'>+</A><BR>\n<BR>\n<A href='?src=\ref[];mach_close=tank'>Close</A>\n</TT>", round(gas.pressure, 0.1), src, ((src.loc == user && user.internal == src) ? "Stop" : "Restore"), src, src, src, src.i_used, src, src, src, user)
	user << browse(dat, "window=tank;size=600x300")
	return

/obj/item/weapon/tank/Topic(href, href_list)
	..()
	if (usr.stat|| usr.restrained())
		return
	if (src.loc == usr)
		usr.machine = src
		if (href_list["cp"])
			var/cp = text2num(href_list["cp"])
			src.i_used += cp
			src.i_used = min(max(round(src.i_used), 0), 10000)
		if ((href_list["stat"] && src.loc == usr))
			if (usr.internal != src && usr.wear_mask && (usr.wear_mask.flags & MASKINTERNALS))
				usr.internal = src
				usr << "\blue Now running on internals!"
			else
				if(usr.internal)
					usr << "\blue No longer running on internals!"
				usr.internal = null
		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src.loc))
			if ((M.client && M.machine == src))
				src.attack_self(M)
	else
		usr << browse(null, "window=tank")
		return
	return

/obj/item/weapon/tank/proc/process(mob/M as mob, obj/substance/gas/G as obj)
	var/amount = src.i_used
	var/total = src.gas.total_moles
	if (amount > total)
		amount = total
	if (total > 0)
		G.transfer_from(src.gas, amount)
	return G

/obj/item/weapon/tank/attack(mob/M as mob, mob/user as mob)
	..()
	if ((prob(30) && M.stat < 2))
		var/mob/human/H = M

// ******* Check

		if ((istype(H, /mob/human) && istype(H, /obj/item/weapon/clothing/head) && H.flags & 8 && prob(80)))
			M << "\red The helmet protects you from being hit hard in the head!"
			return
		var/time = rand(10, 120)
		if (prob(90))
			if (M.paralysis < time)
				M.paralysis = time
		else
			if (M.stunned < time)
				M.stunned = time
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			if ((O.client && !( O.blinded )))
				O << text("\red <B>[] has been knocked unconscious!</B>", M)
		M << text("\red <B>This was a []% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>", time * 100 / 120)
	return

/obj/item/weapon/tank/var/capacity

/obj/item/weapon/tank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/obj/item/weapon/icon = src
	if (istype(src.loc, /obj/item/weapon/assembly))
		icon = src.loc
	if (istype(W, /obj/item/weapon/analyzer) && get_dist(user, src) <= 1)
		for (var/mob/O in viewers(user, null))
			O << "\red [user] has used the analyzer on \icon[icon]"
			var/total = src.gas.total_moles
			var/t1 = 0
			user << "\blue Results of analysis of \icon[icon]"
			if (total)
				user << "\blue Overall: [total] / [src.capacity]"
				t1 = round( src.gas.n2 / total * 100 , 0.0010)
				user << "\blue Nitrogen: [t1]%"
				t1 = round( src.gas.o2 / total * 100 , 0.0010)
				user << "\blue Oxygen: [t1]%"
				t1 = round( src.gas.plasma / total * 100 , 0.0010)
				user << "\blue Plasma: [t1]%"
				t1 = round( src.gas.co2 / total * 100 , 0.0010)
				user << "\blue CO2: [t1]%"
				t1 = round( src.gas.n2o / total * 100 , 0.0010)
				user << "\blue N2O: [t1]%"
				user << text("\blue Temperature: []&deg;C", src.gas.temperature-T0C)
			else
				user << "\blue Tank is empty!"
		src.add_fingerprint(user)
	return

/obj/item/weapon/tank/New()
	. = ..()
	src.gas = new /obj/substance/gas( src )
	gas.volume = 0.1

/obj/item/weapon/tank/Del()
	//src.gas = null
	del(src.gas)
	. = ..()

/obj/item/weapon/tank/burn(fi_amount)
	if(src.gas)
		if ( (fi_amount * src.gas.total_moles) > (src.maximum * 3.75E5) )
			var/turf/T = get_turf(src.loc)
			T.gas.add_delta(gas)
			del(src)

/obj/item/weapon/tank/examine()
	var/obj/item/weapon/icon = src
	if (istype(src.loc, /obj/item/weapon/assembly))
		icon = src.loc
		if (get_dist(src, usr) > 1)
			if (icon == src) usr << "\blue It's a \icon[icon]! If you want any more information you'll need to get closer."
			return
		var/foo = src.gas.temperature-T0C
		if (foo < 20)
			foo = "cold"
		else if (foo == 20)
			foo = "room temperature"
		else if (foo > 20 && foo < 300)
			foo = "lukewarm"
		else if (foo >= 300 && foo < 450)
			foo = "warm"
		else if (foo >= 450 && foo < 500)
			foo = "hot"
		else
			foo = "dangerously hot"
		usr << text("\blue The \icon[] feels []", icon, foo)
	return

/obj/item/weapon/tank/oxygentank/New()
	..()
	gas.o2 = gas.partial_pressure_to_moles(src.maximum)
	gas.amt_changed()

/obj/item/weapon/tank/jetpack/New()
	..()
	gas.o2 = gas.partial_pressure_to_moles(src.maximum)
	src.gas.amt_changed()

/obj/item/weapon/tank/jetpack/verb/toggle()
	src.on = !( src.on )
	src.icon_state = text("jetpack[]", src.on)
	return

/obj/item/weapon/tank/jetpack/proc/allow_thrust(num, mob/user as mob)
	if (!( src.on ))
		return 0
	if ((num < 0.1 || src.gas.total_moles < num))
		return 0
	var/obj/substance/gas/G = new /obj/substance/gas()
	G.transfer_from(src.gas, num)
	if (G.o2 >= 10)
		return 1
	if (G.plasma > 1)
		if (user)
			var/d = G.plasma * 5
			d = min(abs(user.health + 100), d, 25)
			user.fireloss += d
			user.updatehealth()
		return (G.o2 >= 7.5 ? 0.5 : 0)
	else
		if (G.o2 >= 7.5)
			return 0.5
		else
			return 0
	//G = null
	del(G)
	return

/obj/item/weapon/tank/anesthetic/New()
	..()
	gas.n2o = gas.partial_pressure_to_moles(src.maximum*0.35)
	gas.o2 = gas.partial_pressure_to_moles(src.maximum*0.65)
	gas.amt_changed()
	return

/obj/item/weapon/tank/plasmatank/proc/release()
	var/turf/T = get_turf(src.loc)
	T.gas.add_delta(gas)

	var/temp = src.gas.temperature
	spawn(10)
		T.firelevel = temp * 3600.0



/obj/item/weapon/tank/plasmatank/proc/ignite()
	var/strength = ((src.gas.plasma + src.gas.o2/2.0) / 1600000.0) * src.gas.temperature
	//if ((src.gas.plasma < 1600000.0 || src.gas.temperature < 773))		//500degC
	if (strength < 773.0)
		var/turf/T = get_turf(src.loc)
		T.gas.add_delta(gas)
		T.firelevel = T.gas.plasma + T.gas.o2

		if(src.master)
			src.master.loc = null

		//if ((src.gas.temperature > (450+T0C) && src.gas.plasma == 1600000.0))
		if (strength > (450+T0C))
			var/turf/sw = locate(max(T.x - 4, 1), max(T.y - 4, 1), T.z)
			var/turf/ne = locate(min(T.x + 4, world.maxx), min(T.y + 4, world.maxy), T.z)
			defer_powernet_rebuild = 1

			for(var/turf/U in block(sw, ne))
				var/zone = 4
				if ((U.y <= (T.y + 1) && U.y >= (T.y - 1) && U.x <= (T.x + 2) && U.x >= (T.x - 2)) )
					zone = 3
				if ((U.y <= (T.y + 1) && U.y >= (T.y - 1) && U.x <= (T.x + 1) && U.x >= (T.x - 1) ))
					zone = 2
				for(var/atom/A in U)
					A.ex_act(zone)
					//Foreach goto(342)
				U.ex_act(zone)
				U.buildlinks()
				//Foreach goto(170)
			defer_powernet_rebuild = 0
			makepowernets()

		else
			//if ((src.gas.temperature > (300+T0C) && src.gas.plasma == 1600000.0))
			if (strength > (300+T0C))
				var/turf/sw = locate(max(T.x - 4, 1), max(T.y - 4, 1), T.z)
				var/turf/ne = locate(min(T.x + 4, world.maxx), min(T.y + 4, world.maxy), T.z)
				defer_powernet_rebuild = 1

				for(var/turf/U in block(sw, ne))
					var/zone = 4
					if ((U.y <= (T.y + 2) && U.y >= (T.y - 2) && U.x <= (T.x + 2) && U.x >= (T.x - 2)) )
						zone = 3
					for(var/atom/A in U)
						A.ex_act(zone)
						//Foreach goto(598)
					U.ex_act(zone)
					U.buildlinks()
					//Foreach goto(498)
				defer_powernet_rebuild = 0
				makepowernets()

		//src.master = null
		del(src.master)
		//SN src = null
		del(src)
		return

	var/turf/T = src.loc
	while(!( istype(T, /turf) ))
		T = T.loc

	if(src.master)
		src.master.loc = null

	for(var/mob/M in range(T))
		flick("flash", M.flash)
		//Foreach goto(732)
	//var/m_range = 2
	var/m_range = round(strength / 387)
	for(var/obj/machinery/atmoalter/canister/C in range(2, T))
		if (!( C.destroyed ))
			if (C.gas.plasma >= 35000)
				C.destroyed = 1
				m_range++
		//Foreach goto(776)
	var/min = m_range
	var/med = m_range * 2
	var/max = m_range * 3
	var/u_max = m_range * 4

	var/turf/sw = locate(max(T.x - u_max, 1), max(T.y - u_max, 1), T.z)
	var/turf/ne = locate(min(T.x + u_max, world.maxx), min(T.y + u_max, world.maxy), T.z)

	defer_powernet_rebuild = 1

	for(var/turf/U in block(sw, ne))


		var/zone = 4
		if ((U.y <= (T.y + max) && U.y >= (T.y - max) && U.x <= (T.x + max) && U.x >= (T.x - max) ))
			zone = 3
		if ((U.y <= (T.y + med) && U.y >= (T.y - med) && U.x <= (T.x + med) && U.x >= (T.x - med) ))
			zone = 2
		if ((U.y <= (T.y + min) && U.y >= (T.y - min) && U.x <= (T.x + min) && U.x >= (T.x - min) ))
			zone = 1
		for(var/atom/A in U)
			A.ex_act(zone)
			//Foreach goto(1217)
		U.ex_act(zone)
		U.buildlinks()
		//U.mark(zone)

		//Foreach goto(961)
	//src.master = null
	defer_powernet_rebuild = 0
	makepowernets()

	del(src.master)
	del(src)

/obj/item/weapon/tank/plasmatank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/assembly/rad_ignite))
		var/obj/item/weapon/assembly/rad_ignite/S = W
		if (!( S.status ))
			return
		var/obj/item/weapon/assembly/r_i_ptank/R = new /obj/item/weapon/assembly/r_i_ptank( user )
		R.part1 = S.part1
		S.part1.loc = R
		S.part1.master = R
		R.part2 = S.part2
		S.part2.loc = R
		S.part2.master = R
		S.layer = initial(S.layer)
		if (user.client)
			user.client.screen -= S
		if (user.r_hand == S)
			user.u_equip(S)
			user.r_hand = R
		else
			user.u_equip(S)
			user.l_hand = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part3 = src
		R.layer = 20
		R.loc = user
		S.part1 = null
		S.part2 = null
		//S = null
		del(S)
	if (istype(W, /obj/item/weapon/assembly/prox_ignite))
		var/obj/item/weapon/assembly/prox_ignite/S = W
		if (!( S.status ))
			return
		var/obj/item/weapon/assembly/m_i_ptank/R = new /obj/item/weapon/assembly/m_i_ptank( user )
		R.part1 = S.part1
		S.part1.loc = R
		S.part1.master = R
		R.part2 = S.part2
		S.part2.loc = R
		S.part2.master = R
		S.layer = initial(S.layer)
		if (user.client)
			user.client.screen -= S
		if (user.r_hand == S)
			user.u_equip(S)
			user.r_hand = R
		else
			user.u_equip(S)
			user.l_hand = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part3 = src
		R.layer = 20
		R.loc = user
		S.part1 = null
		S.part2 = null
		//S = null
		del(S)

	if (istype(W, /obj/item/weapon/assembly/time_ignite))
		var/obj/item/weapon/assembly/time_ignite/S = W
		if (!( S.status ))
			return
		var/obj/item/weapon/assembly/t_i_ptank/R = new /obj/item/weapon/assembly/t_i_ptank( user )
		R.part1 = S.part1
		S.part1.loc = R
		S.part1.master = R
		R.part2 = S.part2
		S.part2.loc = R
		S.part2.master = R
		S.layer = initial(S.layer)
		if (user.client)
			user.client.screen -= S
		if (user.r_hand == S)
			user.u_equip(S)
			user.r_hand = R
		else
			user.u_equip(S)
			user.l_hand = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part3 = src
		R.layer = 20
		R.loc = user
		S.part1 = null
		S.part2 = null
		//S = null
		del(S)

/obj/item/weapon/tank/plasmatank/New()
	..()
	gas.plasma = gas.partial_pressure_to_moles(src.maximum)
	src.gas.amt_changed()

