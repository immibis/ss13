/obj/machinery/door/window/New()
	..()
	if (src.req_access && src.req_access.len)
		src.icon = 'icons/ss13/security.dmi'
	return

/obj/machinery/door/window/Bumped(atom/movable/AM as mob|obj)
	if (!( ismob(AM) ))
		return
	if (!( ticker ))
		return
	if (src.operating)
		return
	if (src.density && src.allowed(AM))
		open()
		if(src.check_access(null))
			sleep(50)
		else //secure doors close faster
			sleep(20)
		close()
	return

/obj/machinery/door/window/CheckPass(atom/movable/O as mob|obj, target as turf)
	if (src.density)
		var/direct = get_dir(O, target)
		if ((direct == NORTH && src.dir & 12))
			return 0
		else
			if ((direct == WEST && src.dir & 3))
				return 0
	return 1

/obj/machinery/door/window/CheckExit(atom/movable/O as mob|obj, target as turf)
	if (src.density)
		var/direct = get_dir(O, target)
		if ((direct == SOUTH && src.dir & 12))
			return 0
		else
			if ((direct == EAST && src.dir & 3))
				return 0
	return 1

/obj/machinery/door/window/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick(text("[]doorc0", (src.p_open ? "o_" : null)), src)
	src.icon_state = text("[]door0", (src.p_open ? "o_" : null))
	sleep(15)
	src.density = 0
	src.opacity = 0
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.buildlinks()
	if(operating == 1) //emag again
		src.operating = 0
	return 1

/obj/machinery/door/window/close()
	if (src.operating)
		return
	src.operating = 1
	flick(text("[]doorc1", (src.p_open ? "o_" : null)), src)
	src.icon_state = text("[]door1", (src.p_open ? "o_" : null))
	src.density = 1
	if (src.visible)
		src.opacity = 1
	sleep(15)
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.buildlinks()
	src.operating = 0
	return
