/obj/blob/New(loc, var/h = 30)

	blobs += src

	src.health = h
	src.dir = pick(1,2,4,8)
	//world << "new blob #[blobs.len]"
	src.update()
	..(loc)

/obj/blob/Del()
	blobs -= src
	//world << "del blob #[blobs.len]"
	..()

/obj/blob/proc/Life()

	var/turf/simulated/U = src.loc

	if(U.gas.plasma> 200000)
		src.health -= round(U.gas.plasma/200000)
		src.update()
		return

	if (istype(U, /turf/space))
		src.health -= 8
		src.update()

	var/p = health * (U.gas.n2/66 + U.gas.o2/17 + U.gas.co2)

	if(!istype(U, /turf/space))
		p+=3

	if(!prob(p))
		return

	for(var/dirn in cardinal)
		var/turf/T = get_step(src, dirn)

		if (istype(T.loc, /area/arrival))
			continue

		var/obj/blob/B = new /obj/blob(U, src.health)

		if(T.Enter(B,src) && !(locate(/obj/blob) in T))
			B.loc = T							// open cell, so expand
		else
			if(prob(50))						// closed cell, 50% chance to not expand
				if(!locate(/obj/blob) in T)
					for(var/atom/A in T)			// otherwise explode contents of turf
						A.blob_act()

					T.blob_act()
					T.buildlinks()
			del(B)

/obj/blob/burn(fi_amount)
	src.health-= round(fi_amount/500000)
	src.update()

/obj/blob/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			src.health -= rand(20,30)
			src.update()
		if(3)
			src.health -= rand(15,25)
			src.update()


/obj/blob/proc/update()
	if(health<=0)
		del(src)
		return
	if(health<10)
		icon_state = "blobc0"
		return
	if(health<20)
		icon_state = "blobb0"
		return
	icon_state = "bloba0"



/obj/blob/las_act(flag)

	if (flag == "bullet")
		health -= 10
		update()
	else
		health -= 20
		update()


/obj/blob/attackby(var/obj/item/W, var/mob/user)
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red <B>The blob has been attacked with [][] </B>", W, (user ? text(" by [].", user) : ".")), 1)

	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W

		if(WT.welding)
			damage = 15

	src.health -= damage
	src.update()
	return

/obj/blob/examine()
	set src in oview(1)
	usr << "A mysterious alien blob-like organism."

/datum/station_state/proc/count()
	for(var/turf/T in world)
		if(T.z != 1)
			continue

		if(istype(T,/turf/simulated/floor))
			if(!(T:burnt))
				src.floor+=2
			else
				src.floor++

		else if(istype(T, /turf/simulated/engine/floor))
			src.floor+=2

		else if(istype(T, /turf/simulated/wall))
			if(T:intact)
				src.wall+=2
			else
				src.wall++

		else if(istype(T, /turf/simulated/r_wall))
			if(T:intact)
				src.r_wall+=2
			else
				src.r_wall++



	for(var/obj/O in world)
		if(O.z != 1)
			continue

		if(istype(O, /obj/window))
			src.window++
		else if(istype(O, /obj/grille))
			if(!O:destroyed)
				src.grille++
		else if(istype(O, /obj/machinery/door))
			src.door++
		else if(istype(O, /obj/machinery))
			src.mach++


/datum/station_state/proc/score(var/datum/station_state/result)

	var/r1a = min( result.floor / floor, 1.0)
	var/r1b = min(result.r_wall/ r_wall, 1.0)
	var/r1c = min(result.wall / wall, 1.0)

	var/r2a = min(result.window / window, 1.0)
	var/r2b = min(result.door / door, 1.0)
	var/r2c = min(result.grille / grille, 1.0)

	var/r3 = min(result.mach / mach, 1.0)


	//world.log << "Blob scores:[r1b] [r1c] / [r2a] [r2b] [r2c] / [r3] [r1a]"

	return (4*(r1b+r1c) + 2*(r2a+r2b+r2c) + r3+r1a)/16.0

