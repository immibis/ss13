/obj/machinery/vehicle/meteorhit(var/obj/O as obj)
	for (var/obj/item/I in src)
		I.loc = src.loc

	for (var/mob/M in src)
		M.loc = src.loc
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE
	del(src)

/obj/machinery/vehicle/ex_act(severity)
	switch (severity)
		if (1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			del(src)
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)

/obj/machinery/vehicle/blob_act()
	for(var/atom/movable/A as mob|obj in src)
		A.loc = src.loc
	del(src)

/obj/machinery/vehicle/Bump(var/atom/A)
	..()
	src.speed = 0

/obj/machinery/vehicle/relaymove(mob/user as mob, direction)
	if (user.stat)
		return

	if (user in src)
		if (direction & SOUTH)
			src.speed = max(src.speed - 1, 0)
		else if (direction & NORTH)
			src.speed = min(10, src.speed + 1)
		else if (src.can_rotate && direction & EAST)
			src.dir = turn(src.dir, -90.0)
		else if (src.can_rotate && direction & WEST)
			src.dir = turn(src.dir, 90)
		if(speed)
			walk(src, dir, 11-speed)
		else
			walk(src, 0)

/obj/machinery/vehicle/verb/eject()
	set src = usr.loc

	if (usr.stat)
		return

	var/mob/M = usr
	M.loc = src.loc
	if (M.client)
		M.client.eye = M.client.mob
		M.client.perspective = MOB_PERSPECTIVE
	step(M, turn(src.dir, 180))
	return

/obj/machinery/vehicle/verb/board()
	set src in oview(1)

	if (usr.stat)
		return

	if (src.one_person_only && locate(/mob, src))
		usr << "There is no room! You can only fit one person."
		return

	var/mob/M = usr
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src

	walk(src, 0)
	src.speed = 0

	M.loc = src

/obj/machinery/vehicle/verb/unload(var/atom/movable/A in src)
	set src in oview(1)

	if (usr.stat)
		return

	if (istype(A, /atom/movable))
		A.loc = src.loc
		for(var/mob/O in view(src, null))
			if ((O.client && !(O.blinded)))
				O << text("\blue <B> [] unloads [] from []!</B>", usr, A, src)

		if (ismob(A))
			var/mob/M = A
			if (M.client)
				M.client.perspective = MOB_PERSPECTIVE
				M.client.eye = M

/obj/machinery/vehicle/verb/load()
	set src in oview(1)

	if (usr.stat)
		return

	if (((istype(usr, /mob/human)) && (!(ticker) || (ticker && ticker.mode != "monkey"))))
		var/mob/human/H = usr

		if ((H.pulling && !(H.pulling.anchored)))
			if (src.one_person_only && !(istype(H.pulling, /obj/item)))
				usr << "You may only place items in."
			else
				H.pulling.loc = src
				if (ismob(H.pulling))
					var/mob/M = H.pulling
					if (M.client)
						M.client.perspective = EYE_PERSPECTIVE
						M.client.eye = src

				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O << text("\blue <B> [] loads [] into []!</B>", H, H.pulling, src)

				H.pulling = null
