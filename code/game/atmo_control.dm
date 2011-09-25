/obj/machinery/proc/process()
	return

/* /obj/machinery/proc/gas_flow()
	return

/obj/machinery/proc/orient_pipe(source as obj)
	return

/obj/machinery/proc/cut_pipes()
	return

/obj/machinery/proc/disc_pipe(target as obj)
	return

/obj/machinery/proc/buildnodes()
	return

/obj/machinery/proc/getline()
	if(p_dir)
		return src

/obj/machinery/proc/setline()
	return

/obj/machinery/proc/ispipe()
	return 0

/obj/machinery/proc/next()
	return null

/obj/machinery/proc/get_gas_val(from)
	return null

/obj/machinery/proc/get_gas(from)
	return null*/

/obj/machinery/meter/New()
	..()
	src.target = locate(/obj/machinery/atmospherics/pipes, src.loc)
	average = 0
	return

/obj/machinery/meter/process()
	if(!target)
		icon_state = "meterX"
		return
	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return

	use_power(PIPE_METER_POWER)

	if(!target.net)
		stat = BROKEN
		return

	average = 0.5 * average + 0.5 * target.gas.temperature

	var/val = min(18, round( 18.99 * ((abs(average) / (T0C + 100))**0.25)) )
	icon_state = "meter[val]"

/*
/obj/machinery/meter/examine()
	set src in oview(1)

	var/t = "A gas flow meter. "
	if (src.target)
		t += text("Results:\nMass flow []%\nPressure [] kPa", round(100*average/src.target.gas.maximum, 0.1), round(pressure(), 0.1) )
	else
		t += "It is not functioning."

	usr << t

*/

/obj/machinery/meter/Click()
	if(stat & (NOPOWER|BROKEN))
		return
	if (get_dist(usr, src) <= 3 || istype(usr, /mob/ai))
		if (src.target)
			usr << text("\blue <B>Results:</B>\nTemperature [] K", round(abs(target.gas.temperature), 0.1))
		else
			usr << "\blue <B>Results: Connection Error!</B>"
	else
		usr << "\blue <B>You are too far away.</B>"
	return

/*
/obj/machinery/meter/proc/pressure()

	if(src.target && src.target.gas)
		return (average * target.gas.temperature)/100000.0
	else
		return 0
*/

/obj/machinery/atmoalter/siphs/New()
	..()
	src.gas = new /obj/substance/gas( src )

/obj/machinery/atmoalter/siphs/proc/releaseall()
	src.t_status = 1
	src.t_per = max_valve
	return

/obj/machinery/atmoalter/siphs/proc/reset(valve, auto)
	if(c_status!=0)
		return

	if (valve < 0)
		src.t_per =  -valve
		src.t_status = 1
	else
		if (valve > 0)
			src.t_per = valve
			src.t_status = 2
		else
			src.t_status = 3
	if (auto)
		src.t_status = 4
	src.setstate()
	return

/obj/machinery/atmoalter/siphs/proc/release(amount, flag)

	var/turf/T = src.loc
	if (!( istype(T, /turf) ))
		return
	if (!( amount ))
		return
	if (!( flag ))
		amount = min(amount, max_valve)
	var/obj/substance/gas/delta = gas.get_frac(amount/gas.total_moles)
	T.gas.add_delta(delta)
	gas.sub_delta(delta)


/obj/machinery/atmoalter/siphs/proc/siphon(amount, flag)

	var/turf/T = src.loc
	if (!( istype(T, /turf) ))
		return
	if (!( amount ))
		return
	if (!( flag ))
		amount = min(amount, 900000.0)
	var/obj/substance/gas/delta = T.gas.get_frac(amount/T.gas.total_moles)
	T.gas.sub_delta(delta)
	gas.add_delta(delta)

/obj/machinery/atmoalter/siphs/proc/setstate()

	if(stat & NOPOWER)
		icon_state = "siphon:0"
		return

	if (src.holding)
		src.icon_state = "siphon:T"
	else
		if (src.t_status != 3)
			src.icon_state = "siphon:1"
		else
			src.icon_state = "siphon:0"
	return

/obj/machinery/atmoalter/siphs/fullairsiphon/New()

	..()
	if(!empty)
		src.gas.volume = 2
		src.gas.o2 = gas.partial_pressure_to_moles(O2_STANDARD * 100)
		src.gas.n2 = gas.partial_pressure_to_moles(N2_STANDARD * 100)
	return

/obj/machinery/atmoalter/siphs/fullairsiphon/port/reset(valve, auto)

	if (valve < 0)
		src.t_per =  -valve
		src.t_status = 1
	else
		if (valve > 0)
			src.t_per = valve
			src.t_status = 2
		else
			src.t_status = 3
	if (auto)
		src.t_status = 4
	src.setstate()
	return

/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent/attackby(W as obj, user as mob)

	if (istype(W, /obj/item/weapon/screwdriver))
		if (src.c_status)
			src.anchored = 1
			src.c_status = 0
		else
			if (locate(/obj/machinery/atmospherics/unary/connector, src.loc))
				src.anchored = 1
				src.c_status = 3
	else
		if (istype(W, /obj/item/weapon/wrench))
			src.alterable = !( src.alterable )
	return

/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent/setstate()


	if(stat & NOPOWER)
		icon_state = "vent-p"
		return

	if (src.t_status == 4)
		src.icon_state = "vent2"
	else
		if (src.t_status == 3)
			src.icon_state = "vent0"
		else
			src.icon_state = "vent1"
	return

/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent/reset(valve, auto)

	if (auto)
		src.t_status = 4
	return

/obj/machinery/atmoalter/siphs/scrubbers/process()

	if(stat & NOPOWER) return

	if (src.t_status != 3)
		var/turf/T = src.loc
		if (istype(T, /turf))
			if (T.firelevel < 900000.0)
				T.gas.o2 += gas.o2
				gas.o2 = 0
				T.gas.amt_changed()
				gas.amt_changed()
		else
			T = null
		switch(src.t_status)
			if(1.0)
				if( !portable() ) use_power(SCRUBBER_POWER, ENVIRON)
				if (src.holding)
					var/t1 = src.gas.total_moles
					var/t2 = t1
					var/t = src.t_per
					if (src.t_per > t2)
						t = t2
					src.holding.gas.transfer_from(src.gas, t)
				else
					if (T)
						var/t1 = src.gas.total_moles
						var/t2 = t1
						var/t = src.t_per
						if (src.t_per > t2)
							t = t2
						var/obj/substance/gas/delta = gas.get_frac(t / gas.total_moles)
						gas.sub_delta(delta)
						T.gas.add_delta(delta)
			if(2.0)
				if( !portable() ) use_power(SCRUBBER_POWER, ENVIRON)
				if (src.holding)
					var/t1 = src.gas.total_moles
					var/t2 = src.maximum - t1
					var/t = src.t_per
					if (src.t_per > t2)
						t = t2
					src.gas.transfer_from(src.holding.gas, t)
				else
					if (T)
						var/t1 = src.gas.total_moles
						var/t2 = src.maximum - t1
						var/t = src.t_per
						if (t > t2)
							t = t2
						var/obj/substance/gas/delta = T.gas.get_frac(t / T.gas.total_moles)
						T.gas.sub_delta(delta)
						gas.add_delta(delta)
			if(4.0)
				if( !portable() ) use_power(SCRUBBER_POWER, ENVIRON)
				if (T)
					if (T.firelevel > 900000.0)
						src.f_time = world.time + 400
					else
						if(world.time > src.f_time)
							var/obj/substance/gas/delta = new
							delta.n2o = T.gas.n2o/2
							delta.plasma = T.gas.plasma/2
							delta.co2 = T.gas.co2/2
							delta.set_temp(T.gas.temperature)
							delta.amt_changed()
							T.gas.sub_delta(delta)
							gas.add_delta(delta)
							if(src.gas.pressure > 10 * ONE_ATMOSPHERE)
								equalize_gas(src.gas, T.gas)

	src.setstate()
	src.updateDialog()
	return

/obj/machinery/atmoalter/siphs/scrubbers/air_filter/setstate()

	if(stat & NOPOWER)
		icon_state = "vent-p"
		return

	if (src.t_status == 4)
		src.icon_state = "vent2"
	else
		if (src.t_status == 3)
			src.icon_state = "vent0"
		else
			src.icon_state = "vent1"
	return

/obj/machinery/atmoalter/siphs/scrubbers/air_filter/attackby(W as obj, user as mob)

	if (istype(W, /obj/item/weapon/screwdriver))
		if (src.c_status)
			src.anchored = 1
			src.c_status = 0
		else
			if (locate(/obj/machinery/atmospherics/unary/connector, src.loc))
				src.anchored = 1
				src.c_status = 3
	else
		if (istype(W, /obj/item/weapon/wrench))
			src.alterable = !( src.alterable )
	return

/obj/machinery/atmoalter/siphs/scrubbers/air_filter/reset(valve, auto)

	if (auto)
		src.t_status = 4
	src.setstate()
	return

/obj/machinery/atmoalter/siphs/scrubbers/port/setstate()

	if(stat & NOPOWER)
		icon_state = "scrubber:0"
		return

	if (src.holding)
		src.icon_state = "scrubber:T"
	else
		if (src.t_status != 3)
			src.icon_state = "scrubber:1"
		else
			src.icon_state = "scrubber:0"
	return

/obj/machinery/atmoalter/siphs/scrubbers/port/reset(valve, auto)

	if (valve < 0)
		src.t_per =  -valve
		src.t_status = 1
	else
		if (valve > 0)
			src.t_per = valve
			src.t_status = 2
		else
			src.t_status = 3
	if (auto)
		src.t_status = 4
	src.setstate()
	return

//true if the siphon is portable (therfore no power needed)

/obj/machinery/proc/portable()
	return istype(src, /obj/machinery/atmoalter/siphs/fullairsiphon/port) || istype(src, /obj/machinery/atmoalter/siphs/scrubbers/port)

/obj/machinery/atmoalter/siphs/power_change()

	if( portable() )
		return

	if(!powered(ENVIRON))
		spawn(rand(0,15))
			stat |= NOPOWER
			setstate()
	else
		stat &= ~NOPOWER
		setstate()


/obj/machinery/atmoalter/siphs/process()

//	var/dbg = (suffix=="d") && Debug

	if(stat & NOPOWER) return

	if (src.t_status != 3)
		var/turf/T = src.loc
		if (istype(T, /turf))
		else
			T = null
		switch(src.t_status)
			if(1.0)
				if( !portable() ) use_power(SIPHON_POWER, ENVIRON)
				if (src.holding)
					var/t1 = src.gas.total_moles
					var/t2 = t1
					var/t = src.t_per
					if (src.t_per > t2)
						t = t2
					src.holding.gas.transfer_from(src.gas, t)
				else
					if (T)
						var/t1 = src.gas.total_moles
						var/t2 = t1
						var/t = src.t_per
						if (src.t_per > t2)
							t = t2
						var/obj/substance/gas/delta = gas.get_frac(t / gas.total_moles)
						gas.sub_delta(delta)
						T.gas.add_delta(delta)
			if(2.0)
				if( !portable() ) use_power(SIPHON_POWER, ENVIRON)
				if (src.holding)
					var/t1 = src.gas.total_moles
					var/t2 = src.maximum - t1
					var/t = src.t_per
					if (src.t_per > t2)
						t = t2
					src.gas.transfer_from(src.holding.gas, t)
				else
					if (T)
						var/t1 = src.gas.total_moles
						var/t2 = src.maximum - t1
						var/t = src.t_per
						if (t > t2)
							t = t2
						//var/g = gas.tot_gas()
						//if(dbg) world.log << "VP0 : [t] from turf: [gas.tot_gas()]"
						//if(dbg) Air()

						var/obj/substance/gas/delta = T.gas.get_frac(t / T.gas.total_moles)
						T.gas.sub_delta(delta)
						gas.add_delta(delta)
						//if(dbg) world.log << "VP1 : now [gas.tot_gas()]"

						//if(dbg) world.log << "[gas.tot_gas()-g] ([t]) from turf to siph"

						//if(dbg) Air()
			if(4.0)
				if( !portable() )
					use_power(SIPHON_POWER, ENVIRON)

				if (T)
					if (T.firelevel > 900000.0)
						src.f_time = world.time + 300
					else
						if (world.time > src.f_time)
							var/difference = T.gas.partial_pressure_to_moles(1000000) - T.gas.total_moles
							if (difference > 0)
								var/t1 = src.gas.total_moles
								if (difference > t1)
									difference = t1

								var/delta = gas.get_frac(difference / gas.total_moles)
								gas.sub_delta(delta)
								gas.add_delta(delta)

	src.updateDialog()

	src.setstate()
	return

/obj/machinery/atmoalter/siphs/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/atmoalter/siphs/attack_paw(user as mob)

	return src.attack_hand(user)
	return

/obj/machinery/atmoalter/siphs/attack_hand(var/mob/user as mob)

	if(stat & NOPOWER) return

	if(src.portable() && istype(user, /mob/ai)) //AI can't use portable siphons
		return

	user.machine = src
	var/tt
	switch(src.t_status)
		if(1.0)
			tt = text("Releasing <A href='?src=\ref[];t=2'>Siphon</A> <A href='?src=\ref[];t=3'>Stop</A>", src, src)
		if(2.0)
			tt = text("<A href='?src=\ref[];t=1'>Release</A> Siphoning <A href='?src=\ref[];t=3'>Stop</A>", src, src)
		if(3.0)
			tt = text("<A href='?src=\ref[];t=1'>Release</A> <A href='?src=\ref[];t=2'>Siphon</A> Stopped <A href='?src=\ref[];t=4'>Automatic</A>", src, src, src)
		else
			tt = "Automatic equalizers are on!"
	var/ct = null
	switch(src.c_status)
		if(1.0)
			ct = text("Releasing <A href='?src=\ref[];c=2'>Accept</A> <A href='?src=\ref[];c=3'>Stop</A>", src, src)
		if(2.0)
			ct = text("<A href='?src=\ref[];c=1'>Release</A> Accepting <A href='?src=\ref[];c=3'>Stop</A>", src, src)
		if(3.0)
			ct = text("<A href='?src=\ref[];c=1'>Release</A> <A href='?src=\ref[];c=2'>Accept</A> Stopped", src, src)
		else
			ct = "Disconnected"
	var/at = null
	if (src.t_status == 4)
		at = text("Automatic On <A href='?src=\ref[];t=3'>Stop</A>", src)
	var/dat = text("<TT><B>Canister Valves</B> []<BR>\n\t<FONT color = 'blue'><B>Pressure</B> [] kPa</FONT><BR>\n\tUpper Valve Status: [] []<BR>\n\t\t<A href='?src=\ref[];tp=-[]'>M</A> <A href='?src=\ref[];tp=-10000'>-</A> <A href='?src=\ref[];tp=-1000'>-</A> <A href='?src=\ref[];tp=-100'>-</A> <A href='?src=\ref[];tp=-1'>-</A> [] <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=100'>+</A> <A href='?src=\ref[];tp=1000'>+</A> <A href='?src=\ref[];tp=10000'>+</A> <A href='?src=\ref[];tp=[]'>M</A><BR>\n\tPipe Valve Status: []<BR>\n\t\t<A href='?src=\ref[];cp=-[]'>M</A> <A href='?src=\ref[];cp=-10000'>-</A> <A href='?src=\ref[];cp=-1000'>-</A> <A href='?src=\ref[];cp=-100'>-</A> <A href='?src=\ref[];cp=-1'>-</A> [] <A href='?src=\ref[];cp=1'>+</A> <A href='?src=\ref[];cp=100'>+</A> <A href='?src=\ref[];cp=1000'>+</A> <A href='?src=\ref[];cp=10000'>+</A> <A href='?src=\ref[];cp=[]'>M</A><BR>\n<BR>\n\n<A href='?src=\ref[];mach_close=siphon'>Close</A><BR>\n\t</TT>", (!( src.alterable ) ? "<B>Valves are locked. Unlock with wrench!</B>" : "You can lock this interface with a wrench."), num2text(src.gas.pressure, 10), (src.t_status == 4 ? text("[]", at) : text("[]", tt)), (src.holding ? text("<BR>(<A href='?src=\ref[];tank=1'>Tank ([]</A>)", src, src.holding.gas.pressure) : null), src, num2text(max_valve, 7), src, src, src, src, src.t_per, src, src, src, src, src, num2text(max_valve, 7), ct, src, num2text(max_valve, 7), src, src, src, src, src.c_per, src, src, src, src, src, num2text(max_valve, 7), user)
	user << browse(dat, "window=siphon;size=600x300")
	return

/obj/machinery/atmoalter/siphs/Topic(href, href_list)
	..()

	if (usr.stat || usr.restrained())
		return
	if ((!( src.alterable )) && (!istype(usr, /mob/ai)))
		return
	if ((get_dist(src, usr) <= 1 && istype(src.loc, /turf)) || (istype(usr, /mob/ai)))
		usr.machine = src
		if (href_list["c"])
			var/c = text2num(href_list["c"])
			switch(c)
				if(1.0)
					src.c_status = 1
				if(2.0)
					src.c_status = 2
				if(3.0)
					src.c_status = 3
				else
		else
			if (href_list["t"])
				var/t = text2num(href_list["t"])
				if (src.t_status == 0)
					return
				switch(t)
					if(1.0)
						src.t_status = 1
					if(2.0)
						src.t_status = 2
					if(3.0)
						src.t_status = 3
					if(4.0)
						src.t_status = 4
						src.f_time = 1
					else
			else
				if (href_list["tp"])
					var/tp = text2num(href_list["tp"])
					src.t_per += tp
					src.t_per = min(max(round(src.t_per), 0), max_valve)
				else
					if (href_list["cp"])
						var/cp = text2num(href_list["cp"])
						src.c_per += cp
						src.c_per = min(max(round(src.c_per), 0), max_valve)
					else
						if (href_list["tank"])
							var/cp = text2num(href_list["tank"])
							if (cp == 1)
								src.holding.loc = src.loc
								src.holding = null
								if (src.t_status == 2)
									src.t_status = 3
		src.updateUsrDialog()

		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=canister")
		return
	return

/obj/machinery/atmoalter/siphs/attackby(var/obj/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/tank))
		if (src.holding)
			return
		var/obj/item/weapon/tank/T = W
		user.drop_item()
		T.loc = src
		src.holding = T
	else
		if (istype(W, /obj/item/weapon/screwdriver))
			var/obj/machinery/atmospherics/unary/connector/con = locate() in loc
			if (src.c_status)
				src.anchored = 0
				src.c_status = 0
				user.show_message("\blue You have disconnected the siphon.")
				if(con)
					con.connected = null
			else
				if (con && !con.connected)
					src.anchored = 1
					src.c_status = 3
					user.show_message("\blue You have connected the siphon.")
					con.connected = src
				else
					user.show_message("\blue There is nothing here to connect to the siphon.")


		else
			if (istype(W, /obj/item/weapon/wrench))
				src.alterable = !( src.alterable )
				if (src.alterable)
					user << "\blue You unlock the interface!"
				else
					user << "\blue You lock the interface!"
	return


