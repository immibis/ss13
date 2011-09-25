/obj/grille/New()
	..()

//returns the netnum of a stub cable at this grille loc, or 0 if none

/obj/grille/proc/get_connection()
	var/turf/T = src.loc
	if(!istype(T, /turf/simulated/floor))
		return

	for(var/obj/cable/C in T)
		if(C.d1 == 0)
			return C.netnum

	return 0

/obj/grille/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		if(3.0)
			if (prob(25))
				src.health -= 11
				healthcheck()
		else
	return

/obj/grille/blob_act()
	src.health--
	src.healthcheck()


/obj/grille/meteorhit(var/obj/M)
	if (M.icon_state == "flaming")
		src.health -= 2
		healthcheck()
	return

/obj/grille/CheckPass(var/obj/B)
	if ((istype(B, /obj/effects) || istype(B, /obj/item/weapon/dummy) || istype(B, /obj/beam) || istype(B, /obj/meteor/small)))
		return 1
	else
		if (istype(B, /obj/bullet))
			return prob(30)
		else
			return !( src.density )
	return

/obj/grille/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wirecutters))
		if(!shock(user, 100))
			src.health = 0
	else if ((istype(W, /obj/item/weapon/screwdriver) && (istype(src.loc, /turf/simulated) || src.anchored)))
		if(!shock(user, 90))
			src.anchored = !( src.anchored )
			user << (src.anchored ? "You have fastened the grille to the floor." : "You have unfastened the grill.")
	else if(istype(W, /obj/item/weapon/shard))	// can't get a shock by attacking with glass shard
		src.health -= W.force * 0.1

	else						// anything else, chance of a shock
		if(!shock(user, 70))
			switch(W.damtype)
				if("fire")
					src.health -= W.force
				if("brute")
					src.health -= W.force * 0.1

	src.healthcheck()
	..()
	return

/obj/grille/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.icon_state = "brokengrille"
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/rods( src.loc )

		else
			if (src.health <= -10.0)
				new /obj/item/weapon/rods( src.loc )
				//SN src = null
				del(src)
				return
	return

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/grille/proc/shock(mob/user, prb)

	if(!anchored || destroyed)		// anchored/destroyed grilles are never connected
		return 0

	if(!prob(prb))
		return 0

	var/net = get_connection()		// find the powernet of the connected cable

	if(!net)		// cable is unpowered
		return 0

	return src.electrocute(user, prb, net)

