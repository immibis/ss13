// the inlet stage of the gas turbine electricity generator

/obj/machinery/compressor/New()
	..()

	gas = new/obj/substance/gas(src)
	inturf = get_step(src, WEST)

	spawn(5)
		turbine = locate() in get_step(src, EAST)
		if(!turbine)
			stat |= BROKEN


/obj/machinery/compressor/process()

	overlays = null
	if(stat & BROKEN)
		return
	if(!turbine)
		stat |= BROKEN
		return
	rpm = 0.9* rpm + 0.1 * rpmtarget


	var/obj/substance/gas/delta = inturf.gas.get_frac((rpm/30000*capacity) / inturf.gas.total_moles)
	inturf.gas.sub_delta(delta)
	gas.add_delta(delta)

	var/shc = gas.specific_heat_capacity()
	if(shc)
		gas.temperature += min(shc, (gas.plasma + gas.o2)*2/shc)

	rpm = max(0, rpm - (rpm*rpm)/COMPFRICTION)

	if(starter && !(stat & NOPOWER))
		use_power(COMPSTARTERLOAD)
		if(rpm<1000)
			rpmtarget = 1000
		else
			starter = 0
	else
		if(rpm<1000)
			rpmtarget = 0

	if(rpm>50000)
		overlays += image('icons/ss13/pipes.dmi', "comp-o4", FLY_LAYER)
	else if(rpm>10000)
		overlays += image('icons/ss13/pipes.dmi', "comp-o3", FLY_LAYER)
	else if(rpm>2000)
		overlays += image('icons/ss13/pipes.dmi', "comp-o2", FLY_LAYER)
	else if(rpm>500)
		overlays += image('icons/ss13/pipes.dmi', "comp-o1", FLY_LAYER)


/obj/machinery/power/turbine/New()
	..()

	outturf = get_step(src, EAST)

	spawn(5)

		compressor = locate() in get_step(src, WEST)
		if(!compressor)
			stat |= BROKEN


#define TURBPRES 90000000
#define TURBGENQ 20000
#define TURBGENG 0.8

obj/machinery/power/turbine/var/tmp/overlay_state = 0

/obj/machinery/power/turbine/process()
	if(stat & BROKEN)
		if(overlay_state)
			overlay_state = 0
			overlays = null
		return
	if(!compressor)
		stat |= BROKEN
		return
	lastgen = ((compressor.rpm / TURBGENQ)**TURBGENG) *TURBGENQ - (compressor.starter * COMPSTARTERLOAD)

	if(lastgen < 0 && (!powernet || surplus() < -lastgen))
		compressor.starter = 0
		return

	if(lastgen > 0)
		add_avail(lastgen)
	else
		add_load(-lastgen)

	//if(compressor.gas.temperature > (T20C+50))
	var/newrpm = ((compressor.gas.temperature-T20C-50) * compressor.gas.pressure / TURBPRES)*30000
	newrpm = max(0, newrpm)

	if(!compressor.starter || newrpm > 1000)
		compressor.rpmtarget = newrpm
	//endif was here

	if(compressor.gas.total_moles>0)
		var/oamount = min(compressor.gas.total_moles, (compressor.rpm+100)/350000*compressor.capacity)
		var/obj/substance/gas/delta = compressor.gas.get_frac(oamount / compressor.gas.total_moles)
		compressor.gas.sub_delta(delta)
		outturf.gas.add_delta(delta)
		outturf.firelevel = outturf.gas.plasma + outturf.gas.o2

	if(lastgen > 100)
		if(!overlay_state)
			overlays += image('icons/ss13/pipes.dmi', "turb-o", FLY_LAYER)
			overlay_state = 1
	else if(overlay_state)
		overlays -= image('icons/ss13/pipes.dmi', "turb-o", FLY_LAYER)
		overlay_state = 0


	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.interact(M)
	AutoUpdateAI(src)

/obj/machinery/power/turbine/attack_ai(mob/user)

	if(stat & (BROKEN|NOPOWER))
		return

	interact(user)

/obj/machinery/power/turbine/attack_hand(mob/user)

	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	interact(user)

/obj/machinery/power/turbine/proc/interact(mob/user)

	if ( (get_dist(src, user) > 1 ) || (stat & (NOPOWER|BROKEN)) && (!istype(user, /mob/ai)) )
		user.machine = null
		user << browse(null, "window=turbine")
		return

	user.machine = src

	var/t = "<TT><B>Gas Turbine Generator</B><HR><PRE>"

	var/gen = lastgen - (compressor.starter * COMPSTARTERLOAD)
	t += "Generated power : [round(gen)] W<BR><BR>"

	t += "Turbine: [round(compressor.rpm)] RPM<BR>"

	t += "Starter: [ compressor.starter ? "<A href='?src=\ref[src];str=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];str=1'>On</A>"]"

	t += "</PRE><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</TT>"
	user << browse(t, "window=turbine")

	return

/obj/machinery/power/turbine/Topic(href, href_list)
	..()
	if(stat & BROKEN)
		return
	if (usr.stat || usr.restrained() )
		return
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		if(!istype(usr, /mob/ai))
			usr << "\red You don't have the dexterity to do this!"
			return

	if (( usr.machine==src && (get_dist(src, usr) <= 1 && istype(src.loc, /turf))) || (istype(usr, /mob/ai)))


		if( href_list["close"] )
			usr << browse(null, "window=turbine")
			usr.machine = null
			return

		else if( href_list["str"] )
			compressor.starter = !compressor.starter

		spawn(0)
			for(var/mob/M in viewers(1, src))
				if ((M.client && M.machine == src))
					src.interact(M)

	else
		usr << browse(null, "window=turbine")
		usr.machine = null

	return
