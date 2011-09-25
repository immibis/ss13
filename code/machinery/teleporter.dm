/obj/machinery/computer/teleporter/New()
	src.id = text("[]", rand(1000, 9999))
	..()
	return

/obj/machinery/computer/teleporter/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/x in src.verbs)
					src.verbs -= x
				src.icon_state = "broken"
		if(3.0)
			if (prob(25))
				for(var/x in src.verbs)
					src.verbs -= x
				src.icon_state = "broken"
		else
	return

/obj/machinery/computer/teleporter/attackby(obj/item/weapon/W)
	src.attack_hand()

/obj/machinery/computer/teleporter/attack_paw()
	src.attack_hand()

/obj/machinery/teleport/station/attack_ai()
	src.attack_hand()

/obj/machinery/computer/teleporter/attack_hand()
	if(stat & (NOPOWER|BROKEN))
		return

	var/list/L = list()
	var/list/areaindex = list()
	for(var/obj/item/weapon/radio/beacon/R in world)
		var/turf/T = find_loc(R)
		if (!T)	continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R
	var/desc = input("Please select a location to lock in.", "Locking Computer") in L
	src.locked = L[desc]
	for(var/mob/O in hearers(src, null))
		O.show_message("\blue Locked In: [desc]", 2)
	src.add_fingerprint(usr)
	return

/obj/machinery/computer/teleporter/verb/set_id(t as text)
	set src in oview(1)
	set desc = "ID Tag:"

	if(stat & (NOPOWER|BROKEN) )
		return
	if (t)
		src.id = t
	return

/proc/find_loc(obj/R as obj)
	if (!R)	return null
	var/turf/T = R.loc
	while(!istype(T, /turf))
		T = T.loc
		if(!T || istype(T, /area))	return null
	return T

/obj/machinery/teleport/hub/Bumped(M as mob|obj)
	spawn
		if(src.icon_state == "tele1")
			teleport(M)

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj)
	var/atom/l = src.loc
	var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(l.x - 2, l.y, l.z))
	var/obj/machinery/teleport/station/st = locate(/obj/machinery/teleport/station, locate(l.x - 1, l.y, l.z))
	if (!com)
		return
	if (!st.try_use_power()) // even if not locked on
		return
	if (!com.locked)
		for(var/mob/O in hearers(src, null))
			O.show_message("\red Failure: Cannot authenticate locked on coordinates. Please reinstantiate coordinate matrix.")
		return
	if (istype(M, /atom/movable))
		if(prob(5)) //oh dear a problem, put em in deep space
			do_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy - 5), 3), 2)
		else
			do_teleport(M, com.locked, 2)
	else
		var/obj/effects/sparks/O = new /obj/effects/sparks(com.locked)
		O.dir = pick(NORTH, SOUTH, EAST, WEST)
		spawn( 0 )
			O.Life()
		for(var/mob/B in hearers(src, null))
			B.show_message("\blue Test fire completed.")
	return

/proc/do_teleport(atom/movable/M as mob|obj, atom/destination, precision)
	var/turf/destturf = get_turf(destination)

	var/tx = destturf.x + rand(precision * -1, precision)
	var/ty = destturf.y + rand(precision * -1, precision)

	var/tmploc = locate(tx, ty, destination.z)

	if(tx == destturf.x && ty == destturf.y && (istype(destination.loc, /obj/closet) || istype(destination.loc, /obj/secloset)))
		tmploc = destination.loc
	if(tmploc==null)	return
	M.loc = tmploc
	sleep(2)

	var/obj/effects/sparks/O = new /obj/effects/sparks(M)
	O.dir = pick(NORTH, SOUTH, EAST, WEST)
	spawn( 0 )
		O.Life()
	return

/obj/machinery/teleport/station
	parent_type = /obj/machinery/power // hack
	icon = 'icons/ss13/stationobjs.dmi'
	icon_state = "controller"
	name = "station"
	desc = ""
	density = 1
	anchored = 1
	var/active = 0
	var/engaged = 0

/obj/machinery/teleport/station/attackby(obj/item/weapon/W)
	src.attack_hand()

/obj/machinery/teleport/station/attack_paw()
	src.attack_hand()

/obj/machinery/teleport/station/attack_ai()
	src.attack_hand()

/obj/machinery/teleport/station/attack_hand()
	if(engaged)
		src.disengage()
	else
		src.engage()

/obj/machinery/teleport/station/proc/engage()
	if(stat & BROKEN)
		return

	if(surplus() < TELEPORTER_ENGAGE_POWER)
		return

	var/atom/l = src.loc
	var/atom/com = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (com)
		com.icon_state = "tele1"
		add_load(TELEPORTER_ENGAGE_POWER)
		for(var/mob/O in hearers(src, null))
			O.show_message("\blue Teleporter engaged!", 2)
	src.add_fingerprint(usr)
	src.engaged = 1
	return

/obj/machinery/teleport/station/proc/disengage()
	if(stat & BROKEN)
		return

	var/atom/l = src.loc
	var/atom/com = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (com)
		com.icon_state = "tele0"
		for(var/mob/O in hearers(src, null))
			O.show_message("\blue Teleporter disengaged!", 2)
	src.add_fingerprint(usr)
	src.engaged = 0
	return

/*/obj/machinery/teleport/station/verb/testfire()
	set src in oview(1)

	if(stat & (BROKEN|NOPOWER))
		return

	var/atom/l = src.loc
	var/obj/machinery/teleport/hub/com = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (com && !active)
		active = 1
		for(var/mob/O in hearers(src, null))
			O.show_message("\blue Test firing!", 2)
		com.teleport()
		//use_power(5000)

		spawn(30)
			active=0

	src.add_fingerprint(usr)
	return*/

/obj/machinery/teleport/station/process()
	if(stat & BROKEN)
		return
	if(src.engaged)
		if(surplus() >= TELEPORTER_ON_POWER)
			add_load(TELEPORTER_ON_POWER)
		else
			disengage()

/obj/machinery/teleport/station/proc/try_use_power()
	if(surplus() < TELEPORTER_TELEPORT_POWER)
		disengage()
		return 0
	else
		add_load(TELEPORTER_TELEPORT_POWER)
		return 1

/*/obj/machinery/teleport/station/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "controller-p"
		disengage()
	else
		icon_state = "controller"*/

/obj/effects/smoke/proc/Life()
	if (src.amount > 1)
		var/obj/effects/smoke/W = new src.type( src.loc )
		W.amount = src.amount - 1
		W.dir = src.dir
		spawn( 0 )
			W.Life()
			return
	src.amount--
	if (src.amount <= 0)
		sleep(50)
		//SN src = null
		del(src)
		return
	var/turf/T = get_step(src, turn(src.dir, pick(90, 0, 0, -90.0)))
	if ((T && T.density))
		src.dir = turn(src.dir, pick(-90.0, 90))
	else
		step_to(src, T, null)
		T = src.loc
		if (istype(T, /turf))
			T.firelevel = T.gas.plasma
	spawn( 3 )
		src.Life()
		return
	return

/obj/effects/sparks/proc/Life()
	if (src.amount > 1)
		var/obj/effects/sparks/W = new src.type( src.loc )
		W.amount = src.amount - 1
		W.dir = src.dir
		spawn( 0 )
			W.Life()
			return
	src.amount--
	if (src.amount <= 0)
		sleep(50)
		//SN src = null
		del(src)
		return
	var/turf/T = get_step(src, turn(src.dir, pick(90, 0, 0, -90.0)))
	if ((T && T.density))
		src.dir = turn(src.dir, pick(-90.0, 90))
	else
		step_to(src, T, null)
		T = src.loc
		if (istype(T, /turf))
			T.firelevel = T.gas.plasma
	spawn( 3 )
		src.Life()
		return
	return

/obj/effects/sparks/New()
	..()
	var/turf/simulated/T = src.loc
	if (istype(T, /turf/simulated))
		T.firelevel = T.gas.plasma + T.gas.o2

/obj/effects/sparks/Del()
	var/turf/simulated/T = src.loc
	if (istype(T, /turf/simulated))
		T.firelevel = T.gas.plasma + T.gas.o2
	..()

/obj/effects/sparks/Move()
	..()
	var/turf/simulated/T = src.loc
	if (istype(T, /turf/simulated))
		T.firelevel = T.gas.plasma + T.gas.o2

/obj/laser/Bump()
	src.range--
	return

/obj/laser/Move()
	src.range--
	return

/atom/proc/laserhit(L as obj)
	return 1

/obj/machinery/computer/data/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/x in src.verbs)
					src.verbs -= x
				src.icon_state = "broken"
		if(3.0)
			if (prob(25))
				for(var/x in src.verbs)
					src.verbs -= x
				src.icon_state = "broken"
		else
	return

/obj/machinery/computer/data/weapon/log/New()
	..()
	src.topics["Super-heater"] = "This turns a can of semi-liquid plasma into a super-heated ball of plasma."
	src.topics["Amplifier"] = "This increases the intensity of a laser."
	src.topics["Class 11 Laser"] = "This creates a very slow laser that is capable of penetrating most objects."
	src.topics["Plasma Energizer"] = "This combines super-heated plasma with a laser beam."
	src.topics["Generator"] = "This controls the entire power grid."
	src.topics["Mirror"] = "this can reflect LOW power lasers. HIGH power goes through it!"
	src.topics["Targetting Prism"] = "This focuses a laser coming from any direction forward."
	return

/obj/machinery/computer/data/weapon/log/display()
	set src in oview(1)

	usr << "<B>Research Log:</B>"
	..()
	return

/obj/machinery/computer/data/weapon/info/New()
	..()
	src.topics["LOG(001)"] = "System: Deployment successful"
	src.topics["LOG(002)"] = "System: Safe orbit at inclination .003 established"
	src.topics["LOG(003)"] = "CenCom: Attempting test fire...ALERT(001)"
	src.topics["ALERT(001)"] = "System: Cannot attempt test fire"
	src.topics["LOG(004)"] = "System: Airlock accessed..."
	src.topics["LOG(005)"] = "System: System successfully reset...Generator engaged"
	src.topics["LOG(006)"] = "Physical: Super-heater (W005) added to power grid"
	src.topics["LOG(007)"] = "Physical: Amplifier (W007) added to power grid"
	src.topics["LOG(008)"] = "Physical: Plasma Energizer (W006) added to power grid"
	src.topics["LOG(009)"] = "Physical: Laser (W004) added to power grid"
	src.topics["LOG(010)"] = "Physical: Laser test firing"
	src.topics["LOG(011)"] = "Physical: Plasma added to Super-heater"
	src.topics["LOG(012)"] = "Physical: Orient N12.525,E22.124"
	src.topics["LOG(013)"] = "System: Location N12.525,E22.124"
	src.topics["LOG(014)"] = "Physical: Test fire...successful"
	src.topics["LOG(015)"] = "Physical: Airlock accessed..."
	src.topics["LOG(016)"] = "******: Disable locater systems"
	src.topics["LOG(017)"] = "System: Locater Beacon-Disengaged,CenCom link-Cut...ALERT(002)"
	src.topics["ALERT(002)"] = "System: Cannot seem to establish contact with Central Command"
	src.topics["LOG(018)"] = "******: Shutting down all systems...ALERT(003)"
	src.topics["ALERT(003)"] = "System: Power grid failure-Activating back-up power...ALERT(004)"
	src.topics["ALERT(004)"] = "System: Engine failure...All systems deactivated."
	return

/obj/machinery/computer/data/weapon/info/display()
	set src in oview(1)

	usr << "<B>Research Information:</B>"
	..()
	return

/obj/machinery/computer/data/verb/display()
	set src in oview(1)

	for(var/x in src.topics)
		usr << text("[], \...", x)
	usr << ""
	src.add_fingerprint(usr)
	return

/obj/machinery/computer/data/verb/read(topic as text)
	set src in oview(1)

	if (src.topics[text("[]", topic)])
		usr << text("<B>[]</B>\n\t []", topic, src.topics[text("[]", topic)])
	else
		usr << text("Unable to find- []", topic)
	src.add_fingerprint(usr)
	return