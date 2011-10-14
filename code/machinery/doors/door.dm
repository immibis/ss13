/obj/machinery/door/meteorhit(obj/M as obj)
	src.open()
	return

/obj/machinery/door/Move()
	..()
	if (src.density)
		var/turf/simulated/location = src.loc
		if (istype(location))
			location.updatecell = 0
			location.buildlinks()
	return

/obj/machinery/door/CheckPass(mob/user)
	if(density && ismob(user))
		attack_hand(user)
	return ..()

/obj/machinery/door/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/attack_hand(mob/user as mob)
	return src.attackby(user, user)

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/attackby(obj/item/I as obj, mob/user as mob)
	if (src.operating)
		return
	src.add_fingerprint(user)
	if (!src.requiresID())
		//don't care who they are or what they have, act as if they're NOTHING
		user = null
	if (src.density && istype(I, /obj/item/weapon/card/emag))
		src.operating = -1
		flick("door_spark", src)
		sleep(6)
		open()
		return 1
	if (src.allowed(user))
		if (src.density)
			open()
		else
			close()
	else if (src.density)
		flick("door_deny", src)
	return

/obj/machinery/door/blob_act()
	if(prob(20))
		if(checkForMultipleDoors())
			var/turf/simulated/T = src.loc
			if(istype(T))
				T.updatecell = 1
				T.buildlinks()
		del(src)

/obj/machinery/door/ex_act(severity)

	if(severity == 1 || (severity == 2 && prob(25)))
		if(checkForMultipleDoors())
			var/turf/simulated/T = src.loc
			if(istype(T))
				T.updatecell = 1
				T.buildlinks()
		del(src)
	else if(severity == 3 && prob(80))
		var/obj/effects/sparks/S = new /obj/effects/sparks(src.loc)
		S.dir = pick(NORTH, SOUTH, EAST, WEST)
		spawn(0)
			S.Life()

/obj/machinery/door/New()
	..()
	var/turf/simulated/T = src.loc
	if (istype(T))
		if (src.density && !istype(src, /obj/machinery/door/window))
			T.updatecell = 0
			T.buildlinks()
		else
			T.buildlinks()
	layer = 4
	return

/obj/machinery/door/proc/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if(!density) return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick(text("[]door_opening", (src.p_open ? "o_" : null)), src)
	src.icon_state = text("[]door_open", (src.p_open ? "o_" : null))
	sleep(15)
	src.density = 0
	src.opacity = 0
	var/turf/simulated/T = src.loc
	if (istype(T) && checkForMultipleDoors())
		T.updatecell = 1
		T.buildlinks()
	if(operating == 1) //emag again
		src.operating = 0
	return 1

/obj/machinery/door/proc/close()
	if (src.operating)
		return
	if(density) return
	src.operating = 1
	flick(text("[]door_closing", (src.p_open ? "o_" : null)), src)
	src.icon_state = text("[]door_closed", (src.p_open ? "o_" : null))
	src.density = 1
	if (src.visible)
		src.opacity = 1
	var/turf/simulated/T = src.loc
	if (istype(T))
		T.updatecell = 0
		T.buildlinks()
	sleep(15)
	src.operating = 0
	return