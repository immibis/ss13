/obj/machinery/door/poddoor/open()
	usr << "This is a remote controlled door!"
	return

/obj/machinery/door/poddoor/close()
	usr << "This is a remote controlled door!"
	return

/obj/machinery/door/poddoor/attackby(obj/item/weapon/C as obj, mob/user as mob)
	src.add_fingerprint(user)
	if (!( istype(C, /obj/item/weapon/crowbar) ))
		return
	if ((src.density && (stat & NOPOWER) && !( src.operating )))
		spawn( 0 )
			src.operating = 1
			flick("pdoorc0", src)
			src.icon_state = "pdoor0"
			sleep(15)
			src.density = 0
			src.opacity = 0
			var/turf/simulated/T = src.loc
			if (istype(T) && checkForMultipleDoors())
				T.updatecell = 1
				T.buildlinks()
			src.operating = 0
			return
	return

/obj/machinery/door/poddoor/proc/openpod()
	set src in oview(1)

	if(stat & (NOPOWER|BROKEN))
		return

	if (src.operating || !src.density)
		return
	src.operating = 1
	use_power(PODDOOR_POWER)
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	sleep(15)
	src.density = 0
	src.opacity = 0
	var/turf/simulated/T = src.loc
	if (istype(T) && checkForMultipleDoors())
		T.updatecell = 1
		T.buildlinks()
	src.operating = 0
	return

/obj/machinery/door/poddoor/proc/closepod()
	set src in oview(1)

	if(stat & (NOPOWER|BROKEN))
		return

	if (src.operating || src.density)
		return
	use_power(PODDOOR_POWER)
	src.operating = 1
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"
	src.density = 1
	src.opacity = 1
	var/turf/simulated/T = src.loc
	if (istype(T))
		T.updatecell = 0
		T.buildlinks()
	sleep(15)
	src.operating = 0
	return