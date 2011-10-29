/obj/item/tank
	name = "tank"
	var/maximum = null
	var/obj/substance/gas/gas = null
	var/i_used = 100
	flags = FPRINT | TABLEPASS | ONBACK
	weight = 1000000
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	//var/capacity

	proc/process(mob/M as mob, obj/substance/gas/G as obj)
		var/amount = src.i_used
		var/total = src.gas.total_moles
		if (amount > total)
			amount = total
		if (total > 0)
			G.transfer_from(src.gas, amount)
		return G

	attackby(obj/item/W as obj, mob/user as mob)
		var/obj/item/icon = src
		if (istype(src.loc, /obj/item/assembly))
			icon = src.loc
		if (istype(W, /obj/item/analyzer) && get_dist(user, src) <= 1)
			for (var/mob/O in viewers(user, null))
				O << "\red [user] has used the analyzer on \icon[icon]"
			var/total = src.gas.total_moles
			var/t1 = 0
			user << "\blue Results of analysis of \icon[icon]"
			if (total)
				user << "\blue Pressure: [round(gas.pressure/1000,0.1)] kPa"
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

	attack_self(mob/user as mob)
		user.machine = src
		var/dat = {"<TT><B>Tank</B><BR>
<FONT color = 'blue'><B>Pressure</B> [round(gas.pressure, 0.1)]</FONT><BR>
Internals Valve: <A href='?src=\ref[src];stat=1'>[(loc == user && user.internal == src) ? "Stop" : "Restore"]<BR>
<A href='?src=\ref[src];cp=-50'>-</A> <A href='?src=\ref[src];cp=-5'>-</A> <A href='?src=\ref[src];cp=-1'> [src.i_used] <A href='?src=\ref[src];cp=1'>+</A> <A href='?src=\ref[src];cp=5'>+</A> <A href='?src=\ref[src];cp=50'>+</A><BR>
<A href='?src=\ref[user];mach_close=tank'>Close</A></TT>"}
		user << browse(dat, "window=tank;size=600x300")

	Topic(href, href_list)
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

	New()
		. = ..()
		src.gas = new /obj/substance/gas( src )
		gas.volume = 0.1


	Del()
		var/turf/simulated/T = loc
		if(istype(T))
			T.gas.add_delta(src.gas)
		. = ..()

	anesthetic
		name = "anesthetic"
		icon_state = "an_tank"
		maximum = 3*ONE_ATMOSPHERE
		i_used = 250
		New()
			..()
			gas.n2o = gas.partial_pressure_to_moles(src.maximum*0.35)
			gas.o2 = gas.partial_pressure_to_moles(src.maximum*0.65)
			gas.amt_changed()

	jetpack
		name = "jetpack"
		icon_state = "jetpack0"
		var/on = 0
		maximum = 30*ONE_ATMOSPHERE
		w_class = 4
		s_istate = "jetpack"
		New()
			. = ..()
			gas.o2 = gas.partial_pressure_to_moles(src.maximum)
			gas.amt_changed()

		verb/toggle()
			src.on = !( src.on )
			src.icon_state = text("jetpack[]", src.on)

		proc/allow_thrust(num, mob/user as mob)
			if (!( src.on ))
				return 0
			if ((num < 0.1 || src.gas.total_moles < num))
				return 0
			var/obj/substance/gas/G = new
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


	oxygen
		name = "oxygentank"
		icon_state = "oxygen"
		maximum = 5*ONE_ATMOSPHERE
		New()
			. = ..()
			gas.o2 = gas.partial_pressure_to_moles(src.maximum)
			gas.amt_changed()

	plasma
		name = "plasmatank"
		icon_state = "plasma"
		maximum = 5*ONE_ATMOSPHERE
		New()
			. = ..()
			gas.plasma = gas.partial_pressure_to_moles(src.maximum)
			gas.amt_changed()

		proc/release()
			var/turf/T = get_turf(src.loc)
			T.gas.add_delta(gas)

			var/temp = src.gas.temperature
			spawn(10)
				T.firelevel = temp * 3600.0



		proc/ignite()
			// this makes the strength about 500 for a 500 degree bomb with default pressure.
			var/strength = ((src.gas.plasma + src.gas.o2/2.0) / 32.0) * src.gas.temperature
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
						if ((U.y <= (T.y + 2) && U.y >= (T.y - 2) && U.x <= (T.x + 2) && U.x >= (T.x - 2)) )
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

				del(src.master)
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
				U.ex_act(zone)
				U.buildlinks()

			defer_powernet_rebuild = 0
			makepowernets()

			del(src.master)
			del(src)
