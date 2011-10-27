// *** pipefilter

/obj/machinery/atmospherics/pipefilter
	name = "pipe filter"
	icon = 'icons/ss13/pipes2.dmi'
	icon_state = "filter"
	desc = "A three-port gas filter."
	anchored = 1
	capmult = 3
	req_access = list()
	var/capacity = 6000000.0

	var/maxrate = 1000000.0

	var/f_mask = 0
	var/f_per = 10

	var/emagged = 0 //controls emagged sprite (1 = emag has been used)
	var/locked = 1 //controls no sprite but must be 0 if you want to bypass
	var/bypassed = 0 //controls the bypass wire sprite (1 = bypassed)

	var/datum/pipe_network
		m_net
		f_net
	var/obj/substance/gas
		m_gas
		f_gas

	get_network(dir)
		return (dir == src.dir ? f_net : m_net)
	set_gas(dir, gas)
		if(dir == src.dir)
			f_gas = gas
		else
			m_gas = gas
	set_network(dir, net)
		if(dir == src.dir)
			f_net = net
		else
			m_net = net

	New()
		. = ..()
		p_dir = dir | turn(dir, 90) | turn(dir, -90)

	process()
		// Currently disabled. They horribly break and heat stuff up to tens of thousands of degrees.
		//return
		// transfer gas from ngas->f_ngas according to extraction rate, but only if we have power
		if(! (stat & NOPOWER) )
			use_power(min(src.f_per*PIPEFILTER_POWER_MULT, PIPEFILTER_POWER_MAX),ENVIRON)
			var/obj/substance/gas/ndelta = src.get_extract()
			if(ndelta)
				m_gas.sub_delta(ndelta)
				f_gas.add_delta(ndelta)
		AutoUpdateAI(src)
		src.updateUsrDialog()

	proc/get_extract()
		var/obj/substance/gas
			gas1 = m_gas
			gas2 = f_gas

		var/delta_gt = (gas1.pressure - gas2.pressure)

		if(delta_gt > 0)
			var/obj/substance/gas/ndelta = gas1.get_frac(delta_gt / gas1.pressure)
			if(!(src.f_mask & GAS_O2))
				ndelta.o2 = 0
			if(!(src.f_mask & GAS_N2))
				ndelta.n2 = 0
			if(!(src.f_mask & GAS_PL))
				ndelta.plasma = 0
			if(!(src.f_mask & GAS_CO2))
				ndelta.co2 = 0
			if(!(src.f_mask & GAS_N2O))
				ndelta.n2o = 0
			ndelta.amt_changed()
			if(ndelta.pressure < 1000)
				return null
			return ndelta
		else
			return null

	attackby(obj/item/W, mob/user as mob)
		if(istype(W, /obj/item/f_print_scanner))
			return ..()
		if(istype(W, /obj/item/screwdriver))
			if(bypassed)
				user.show_message("\red Remove the foreign wires first!", 1)
				return
			src.add_fingerprint(user)
			user.show_message("\red Now [locked ? "un" : "re"]securing the access system panel...", 1)
			sleep(30)
			locked = !locked
			user.show_message("\red Done!",1)
			src.updateicon()
			return
		if(istype(W, /obj/item/cable_coil) && !bypassed)
			if(src.locked)
				user.show_message("\red You must remove the panel first!",1)
				return
			var/obj/item/cable_coil/C = W
			if(C.use(4))
				user.show_message("\red You unravel some cable...",1)
			else
				user.show_message("\red Not enough cable! (Requires four pieces)",1)
				return
			src.add_fingerprint(user)
			user.show_message("\red Now bypassing the access system... <I>(This may take a while)</I>", 1)
			sleep(100)
			bypassed = 1
			src.updateicon()
			return
		if(istype(W, /obj/item/wirecutters) && bypassed)
			src.add_fingerprint(user)
			user.show_message("\red Now removing the bypass wires... <I>(This may take a while)</I>", 1)
			sleep(50)
			bypassed = 0
			src.updateicon()
			return
		if(istype(W, /obj/item/card/emag) && (!emagged))
			emagged++
			src.add_fingerprint(user)
			for(var/mob/O in viewers(user, null))
				O.show_message("\red [user] has shorted out the [src] with \the [W]!", 1)
			src.overlays += image('icons/ss13/pipes2.dmi', "filter-spark")
			sleep(6)
			src.updateicon()
			return src.attack_hand(user)
		return src.attack_hand(user)

	// pipefilter interact/topic
	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(stat & NOPOWER)
			user << browse(null, "window=pipefilter")
			user.machine = null
			return

		var/list/gases = list("O2", "N2", "Plasma", "CO2", "N2O")
		user.machine = src
		var/dat = "Filter Release Rate:<BR>\n<A href='?src=\ref[src];fp=-[num2text(src.maxrate, 9)]'>M</A> <A href='?src=\ref[src];fp=-100000'>-</A> <A href='?src=\ref[src];fp=-10000'>-</A> <A href='?src=\ref[src];fp=-1000'>-</A> <A href='?src=\ref[src];fp=-100'>-</A> <A href='?src=\ref[src];fp=-1'>-</A> [src.f_per] <A href='?src=\ref[src];fp=1'>+</A> <A href='?src=\ref[src];fp=100'>+</A> <A href='?src=\ref[src];fp=1000'>+</A> <A href='?src=\ref[src];fp=10000'>+</A> <A href='?src=\ref[src];fp=100000'>+</A> <A href='?src=\ref[src];fp=[num2text(src.maxrate, 9)]'>M</A><BR>\n"
		for (var/i = 1; i <= gases.len; i++)
			dat += "[gases[i]]: <A HREF='?src=\ref[src];tg=[1 << (i - 1)]'>[(src.f_mask & 1 << (i - 1)) ? "Releasing" : "Passing"]</A><BR>\n"
		if(m_gas.total_moles)
			var/totalgas = m_gas.total_moles
			var/pressure = m_gas.pressure
			var/nitrogen = m_gas.n2 / totalgas * 100
			var/oxygen = m_gas.o2 / totalgas * 100
			var/plasma = m_gas.plasma / totalgas * 100
			var/co2 = m_gas.co2 / totalgas * 100
			var/no2 = m_gas.n2o / totalgas * 100

			dat += "<BR>Gas Levels: <BR>\nPressure: [round(pressure/1000,0.1)] kPa<BR>\nNitrogen: [nitrogen]%<BR>\nOxygen: [oxygen]%<BR>\nPlasma: [plasma]%<BR>\nCO2: [co2]%<BR>\nN2O: [no2]%<BR>\n"
		else
			dat += "<BR>Gas Levels: <BR>\nPressure: 0 kPa<BR>\nNitrogen: 0%<BR>\nOxygen: 0%<BR>\nPlasma: 0%<BR>\nCO2: 0%<BR>\nN2O: 0%<BR>\n"
		dat += "<BR>\n<A href='?src=\ref[src];close=1'>Close</A><BR>\n"

		user << browse(dat, "window=pipefilter;size=300x365")

	Topic(href, href_list)
		..()
		if(usr.restrained() || usr.lying)
			return
		if (((get_dist(src, usr) <= 1 || istype(usr, /mob/ai)) && istype(src.loc, /turf)))
			usr.machine = src
			if (href_list["close"])
				usr << browse(null, "window=pipefilter;")
				usr.machine = null
				return
			if (src.allowed(usr) || src.emagged || src.bypassed)
				if (href_list["fp"])
					src.f_per = min(max(round(src.f_per + text2num(href_list["fp"])), 0), src.maxrate)
				else if (href_list["tg"])
					// toggle gas
					src.f_mask ^= text2num(href_list["tg"])
					src.updateicon()
			else
				usr.see("\red Access Denied ([src.name] operation restricted to authorized atmospheric technicians.)")
			AutoUpdateAI(src)
			src.updateUsrDialog()
			src.add_fingerprint(usr)
		else
			if(get_dist(src, usr) > 1)
				world << "dist too large, [get_dist(src, usr)] between [src] ([x],[y],[z]) and [usr] ([usr.x],[usr.y],[usr.z])"
			if(!istype(src.loc, /turf))
				world << "loc not a turf but a [loc]"
			usr << browse(null, "window=pipefilter")
			usr.machine = null
			return

	power_change()
		if(powered(ENVIRON))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		updateicon()

	proc/updateicon()
		src.overlays = null
		if(stat & NOPOWER)
			icon_state = "filter-off"
		else
			icon_state = "filter"
			if(emagged)	//only show if powered because presumeably its the interface that has been fried
				src.overlays += image('icons/ss13/pipes2.dmi', "filter-emag")
			if (src.f_mask & (GAS_N2O|GAS_PL))
				src.overlays += image('icons/ss13/pipes2.dmi', "filter-tox")
			if (src.f_mask & GAS_O2)
				src.overlays += image('icons/ss13/pipes2.dmi', "filter-o2")
			if (src.f_mask & GAS_N2)
				src.overlays += image('icons/ss13/pipes2.dmi', "filter-n2")
			if (src.f_mask & GAS_CO2)
				src.overlays += image('icons/ss13/pipes2.dmi', "filter-co2")
		if(!locked)
			src.overlays += image('icons/ss13/pipes2.dmi', "filter-open")
			if(bypassed)	//should only be bypassed if unlocked
				src.overlays += image('icons/ss13/pipes2.dmi', "filter-bypass")
