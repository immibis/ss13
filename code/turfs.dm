/turf/CheckPass(atom/O as mob|obj|turf|area)
	return !( src.density )

/turf/New()
	..()
	for(var/atom/movable/AM as mob|obj in src)
		spawn( 0 )
			src.Entered(AM)
			return
	return

/turf/Enter(atom/movable/O as mob|obj, atom/forget as mob|obj|turf|area)

	if (!isturf(O.loc))
		return 1
	for(var/atom/A in O.loc)
		if (!A.CheckExit(O, src) && O != A && A != forget)
			if (O)
				O.Bump(A, 1)
			return 0
	for(var/atom/A in src)
		if (A.flags & WINDOW && get_dir(A, O) & A.dir)
			if (!A.CheckPass(O, src) && A != src && A != forget)
				if (O)
					O.Bump(A, 1)
				return 0
		if (!A.CheckPass(O, src) && A != forget)
			if (O)
				O.Bump(A, 1)
			return 0
	if (src != forget)
		if (!src.CheckPass(O, src))
			if (O)
				O.Bump(src, 1)
			return 0
	return 1

/turf/Entered(atom/movable/M as mob|obj)
	if(ismob(M) && !istype(src, /turf/space))
		var/mob/tmob = M
		tmob.inertia_dir = 0
	..()
	for(var/atom/A as mob|obj|turf|area in src)
		spawn(0)
			if(A && M)
				A.HasEntered(M, 1)
	for(var/atom/A as mob|obj|turf|area in range(1))
		spawn(0)
			if(A && M)
				A.HasProximity(M, 1)


/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)


/turf/simulated/r_wall/updatecell()

	if (src.state == 2)
		return
	else
		..()
	return

/turf/simulated/r_wall/proc/update()

	if (src.d_state > 6)
		src.d_state = 0
		src.state = 1
	if (src.state == 2)
		src.icon_state = "r_wall[src.d_state > 0 ? "-[src.d_state]" : ""]"
		src.opacity = 1
		src.density = 1
		src.updatecell = 0
		src.buildlinks()
	else
		src.icon_state = "r_girder"
		src.opacity = 0
		src.density = 1
		src.updatecell = 1
		src.buildlinks()
	return

/turf/simulated/r_wall/meteorhit(obj/M as obj)

	if ((M.icon_state == "flaming" && prob(30)))
		if (src.state == 2)
			src.state = 1
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/metal( src )
			update()
		else
			if ((prob(20) && src.state == 1))
				src.state = 0
				//var/turf/simulated/floor/F = new /turf/simulated/floor( locate(src.x, src.y, src.z) )
				var/turf/simulated/floor/F = src.ReplaceWithFloor()
				new /obj/item/weapon/sheet/metal( F )
				new /obj/item/weapon/sheet/metal( F )
				F.buildlinks()
				F.levelupdate()
	return

/turf/proc/ReplaceWithFloor()
	var/turf/simulated/floor/W
	var/area/A
	if (istype(src, /turf/space) || istype(src, /turf/simulated/wall) || istype(src, /turf/simulated/r_wall))
		var/area/oldArea = src:previousArea
		if (oldArea!=null)
			A = oldArea
		else
			A = src.loc
		W = new /turf/simulated/floor( locate(src.x, src.y, src.z) )
	else
		A = src.loc
		W = new /turf/simulated/floor( locate(src.x, src.y, src.z) )

	W.gas = gas
	W.ngas = ngas
	gas = new
	ngas = new
	if (istype(A, /area))
		if (A!=world.area)
			A.contents -= W
			A.contents += W
	return W

/turf/proc/ReplaceWithSpace()
	var oldAreaArea = src.loc
	var/turf/space/S = new /turf/space( locate(src.x, src.y, src.z) )
	if (oldAreaArea==world.area)
		if (istype(src, /turf/simulated/wall) || istype(src, /turf/simulated/r_wall) || istype(src, /turf/space))
			S.previousArea = src:previousArea
		else
			S.previousArea = null
	else
		S.previousArea = oldAreaArea
	new /area( locate(src.x, src.y, src.z) )
	return S

/turf/proc/ReplaceWithWall()
	var oldAreaArea = src.loc
	var/turf/simulated/wall/S = new /turf/simulated/wall( locate(src.x, src.y, src.z) )

	S.gas = gas
	S.ngas = ngas

	if (oldAreaArea==world.area)
		if (istype(src, /turf/simulated/wall) || istype(src, /turf/simulated/r_wall) || istype(src, /turf/space))
			S.previousArea = src:previousArea
		else
			S.previousArea = null
	else
		S.previousArea = oldAreaArea
	new /area( locate(src.x, src.y, src.z) )
	return S

/turf/proc/ReplaceWithRWall()
	var oldAreaArea = src.loc
	var/turf/simulated/r_wall/S = new /turf/simulated/r_wall( locate(src.x, src.y, src.z) )

	S.gas = gas
	S.ngas = ngas

	if (oldAreaArea==world.area)
		if (istype(src, /turf/simulated/wall) || istype(src, /turf/simulated/r_wall) || istype(src, /turf/space))
			S.previousArea = src:previousArea
		else
			S.previousArea = null
	else
		S.previousArea = oldAreaArea
	new /area( locate(src.x, src.y, src.z) )
	return S

/turf/simulated/r_wall/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			var/turf/space/S = src.ReplaceWithSpace()
			S.buildlinks()

			//del(src)
			return
		if(2.0)
			if (prob(75))
				src.opacity = 0
				src.updatecell = 1
				src.buildlinks()
				src.state = 1
				src.intact = 0
				src.levelupdate()
				new /obj/item/weapon/sheet/metal( src )
				new /obj/item/weapon/sheet/metal( src )
			else
				src.state = 0
				//var/turf/simulated/floor/F = new /turf/simulated/floor( locate(src.x, src.y, src.z) )
				var/turf/simulated/floor/F = src.ReplaceWithFloor()
				F.burnt = 1
				F.health = 30
				F.icon_state = "Floor1"
				new /obj/item/weapon/sheet/metal( F )
				new /obj/item/weapon/sheet/metal( F )
				F.buildlinks()
				F.levelupdate()
		if(3.0)
			if (prob(15))
				src.opacity = 0
				src.updatecell = 1
				src.buildlinks()
				src.intact = 0
				src.levelupdate()
				src.state = 1
				new /obj/item/weapon/sheet/metal( src )
				new /obj/item/weapon/sheet/metal( src )
				src.icon_state = "girder"
				update()
		else
	return

/turf/simulated/r_wall/blob_act()

	if(prob(10))
		if(!intact)
			src.state = 0
			//var/turf/simulated/floor/F = new /turf/simulated/floor( locate(src.x, src.y, src.z) )
			var/turf/simulated/floor/F = src.ReplaceWithFloor()
			F.burnt = 1
			F.health = 30
			F.icon_state = "Floor1"
			new /obj/item/weapon/sheet/metal( F )
			F.buildlinks()
			F.levelupdate()
		else
			src.opacity = 0
			src.updatecell = 1
			src.buildlinks()
			src.state = 1
			src.intact = 0
			src.levelupdate()
			new /obj/item/weapon/sheet/metal( src )
			src.icon_state = "girder"
			update()



/turf/simulated/r_wall/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	if (src.state == 2)
		if (istype(W, /obj/item/weapon/wrench))
			if (src.d_state == 4)
				var/turf/T = user.loc
				user << "\blue Cutting support rods."
				sleep(40)
				if ((user.loc == T && user.equipped() == W && !( user.stat )) && istype(src, /turf/simulated/r_wall))
					src.d_state = 5
					user << "\blue You cut the support rods."
		else if (istype(W, /obj/item/weapon/wirecutters))
			if (src.d_state == 0)
				src.d_state = 1
				new /obj/item/weapon/rods( src )

		else if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
			if (W:weldfuel < 5)
				user << "\blue You need more welding fuel to complete this task."
				return
			W:weldfuel -= 5
			if (src.d_state == 2)
				var/turf/T = user.loc
				user << "\blue Slicing metal cover."
				sleep(60)
				if ((user.loc == T && user.equipped() == W && !( user.stat )) && istype(src, /turf/simulated/r_wall))
					src.d_state = 3
					user << "\blue You sliced the metal cover."
			else if (src.d_state == 5)
				var/turf/T = user.loc
				user << "\blue Removing support rods."
				sleep(100)
				if ((user.loc == T && user.equipped() == W && !( user.stat )) && istype(src, /turf/simulated/r_wall))
					src.d_state = 6
					new /obj/item/weapon/rods( src )
					user << "\blue You removed the support rods."
		else if (istype(W, /obj/item/weapon/screwdriver))
			if (src.d_state == 1)
				var/turf/T = user.loc
				user << "\blue Removing support lines."
				sleep(40)
				if ((user.loc == T && user.equipped() == W && !( user.stat )) && istype(src, /turf/simulated/r_wall))
					src.d_state = 2
					user << "\blue You removed the support lines."
		else if (istype(W, /obj/item/weapon/crowbar))
			if (src.d_state == 3)
				var/turf/T = user.loc
				user << "\blue Prying cover off."
				sleep(100)
				if ((user.loc == T && user.equipped() == W && !( user.stat )) && istype(src, /turf/simulated/r_wall))
					src.d_state = 4
					user << "\blue You pried off the cover."
			else if (src.d_state == 6)
				var/turf/T = user.loc
				user << "\blue Prying outer sheath off."
				sleep(100)
				if ((user.loc == T && user.equipped() == W && !( user.stat )) && istype(src, /turf/simulated/r_wall))
					src.d_state = 7
					new /obj/item/weapon/sheet/metal( src )
					user << "\blue You pried of the outer sheath."
		else if (istype(W, /obj/item/weapon/sheet/metal))
			var/turf/T = user.loc
			user << "\blue Repairing wall."
			sleep(100)
			if ((user.loc == T && user.equipped() == W && !( user.stat )  && istype(src, /turf/simulated/r_wall) && src.state == 2))
				src.d_state = 0
				if (W:amount > 1)
					W:amount--
				else
					del(W)
				user << "\blue You repaired the wall."
	if (src.state == 1)
		if (istype(W, /obj/item/weapon/wrench))
			user << "\blue Now dismantling girders."
			var/turf/T = user.loc
			sleep(100)
			if ((user.loc == T && user.equipped() == W && !( user.stat )) && istype(src, /turf/simulated/r_wall))
				src.state = 0
				//var/turf/simulated/floor/F = new /turf/simulated/floor( locate(src.x, src.y, src.z) )
				var/turf/simulated/floor/F = src.ReplaceWithFloor()
				new /obj/item/weapon/sheet/metal( F )
				new /obj/item/weapon/sheet/metal( F )
				F.buildlinks()
				F.levelupdate()
				user << "You dismantled the girders."
		else if (istype(W, /obj/item/weapon/sheet/r_metal))
			src.state = 2
			src.d_state = 0
			del(W)
	if(istype(src,/turf/simulated/r_wall))
		src.update()
	return

/turf/simulated/r_wall/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/r_wall/attack_hand(mob/user as mob)
	user << "\blue You push the wall but nothing happens!"
	src.add_fingerprint(user)
	return

//routine above sometimes erroneously calls turf/simulated/floor/update
//src being miss-set somehow? Maybe due to multiple-clicking
/turf/simulated/floor/proc/update()
	return


/turf/simulated/wall/examine()
	set src in oview(1)

	usr << "It looks like a regular wall."
	return

/turf/simulated/wall/updatecell()

	if (src.state == 2)
		return
	else
		..()
	return


/turf/simulated/wall/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			var/turf/space/S = src.ReplaceWithSpace()
			S.buildlinks()
			del(src)
			return
		if(2.0)
			if (prob(50))
				src.opacity = 0
				src.updatecell = 1
				buildlinks()
				src.state = 1
				src.intact = 0
				src.levelupdate()
				new /obj/item/weapon/sheet/metal( src )
				new /obj/item/weapon/sheet/metal( src )
				src.icon_state = "girder"
			else
				src.state = 0
				//var/turf/simulated/floor/F = new /turf/simulated/floor( locate(src.x, src.y, src.z) )
				var/turf/simulated/floor/F = src.ReplaceWithFloor()
				F.burnt = 1
				F.health = 30
				F.icon_state = "Floor1"
				new /obj/item/weapon/sheet/metal( F )
				new /obj/item/weapon/sheet/metal( F )
				F.buildlinks()
				F.levelupdate()
		if(3.0)
			if (prob(25))
				src.opacity = 0
				src.updatecell = 1
				buildlinks()
				src.intact = 0
				levelupdate()
				src.state = 1
				new /obj/item/weapon/sheet/metal( src )
				new /obj/item/weapon/sheet/metal( src )
				src.icon_state = "girder"
		else
	return

/turf/simulated/wall/blob_act()

	if(prob(20))
		if(!intact)
			src.state = 0
			//var/turf/simulated/floor/F = new /turf/simulated/floor( locate(src.x, src.y, src.z) )
			var/turf/simulated/floor/F = src.ReplaceWithFloor()
			F.burnt = 1
			F.health = 30
			F.icon_state = "Floor1"
			new /obj/item/weapon/sheet/metal( F )
			F.buildlinks()
			F.levelupdate()
		else
			src.opacity = 0
			src.updatecell = 1
			buildlinks()
			src.state = 1
			src.intact = 0
			levelupdate()
			new /obj/item/weapon/sheet/metal( src )
			src.icon_state = "girder"

/turf/simulated/wall/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/wall/attack_hand(mob/user as mob)
	user << "\blue You push the wall but nothing happens!"
	src.add_fingerprint(user)
	return

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	if ((istype(W, /obj/item/weapon/wrench) && src.state == 1))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return
		user << "\blue Now dissembling the girders. Please stand still. This is a long process."
		sleep(100)
		if (!( istype(src, /turf/simulated/wall) ))
			return
		if ((user.loc == T && src.state == 1 && user.equipped() == W))
			src.state = 0
			//var/turf/simulated/floor/F = new /turf/simulated/floor( locate(src.x, src.y, src.z) )
			var/turf/simulated/floor/F = src.ReplaceWithFloor()
//			F.oxygen = O2STANDARD
			new /obj/item/weapon/sheet/metal( F )
			new /obj/item/weapon/sheet/metal( F )
			F.buildlinks()
			F.levelupdate()
	else if ((istype(W, /obj/item/weapon/screwdriver) && src.state == 1))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return
		user << "\blue Now dislodging girders."
		sleep(100)
		if (!( istype(src, /turf/simulated/wall) ))
			return
		if ((user.loc == T && src.state == 1 && user.equipped() == W))
			src.state = 0
			//var/turf/simulated/floor/F = new /turf/simulated/floor( locate(src.x, src.y, src.z) )
			var/turf/simulated/floor/F = src.ReplaceWithFloor()
//			F.oxygen = O2STANDARD
			new /obj/d_girders( F )
			new /obj/item/weapon/sheet/metal( F )
			F.buildlinks()
	else if (istype(W, /obj/item/weapon/sheet/r_metal) && src.state == 1)
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return
		user << "\blue Now reinforcing girders."
		sleep(100)
		if (!( istype(src, /turf/simulated/wall) ))
			return
		if ((user.loc == T && src.state == 1 && user.equipped() == W))
			src.state = 0
			//var/turf/simulated/r_wall/F = new /turf/simulated/r_wall( locate(src.x, src.y, src.z) )
			var/turf/simulated/r_wall/F = src.ReplaceWithRWall()
//			F.oxygen = O2STANDARD
			F.icon_state = "r_girder"
			F.state = 1
			F.opacity = 0
			F.updatecell = 1
			F.levelupdate()
			F.buildlinks()
	else if (istype(W, /obj/item/weapon/weldingtool) && src.state == 2 && W:welding)
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return
		if (W:weldfuel < 5)
			user << "\blue You need more welding fuel to complete this task."
			return
		W:weldfuel -= 5
		user << "\blue Now dissembling the outer wall plating. Please stand still."
		sleep(100)
		if ((user.loc == T && src.state == 2 && user.equipped() == W))
			src.opacity = 0
			src.updatecell = 1
			src.buildlinks()
			src.state = 1
			src.intact = 0
			src.levelupdate()
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/metal( src )
			src.icon_state = "girder"
	else if (istype(W, /obj/item/weapon/sheet/metal) && src.state == 1 && W:amount >= 2)
		var/turf/T = user.loc
		if (!istype(T, /turf))
			return
		if (user.loc == src.loc) //on the wall!
			user << "\blue Move off the wall before trying to finish it!"
		user << "\blue Now adding plating."
		sleep(30) //plating gets added fast! but not THAT fast
		if (!( istype(src, /turf/simulated/wall) ))
			return
		if (user.loc == T && src.state == 1 && user.equipped() == W && W:amount >= 2)
			src.icon_state = ""
			src.state = 2
			src.opacity = 1
			src.updatecell = 0
			src.intact = 1
			src.levelupdate()
			src.buildlinks()
			W:amount -= 2
			if(W:amount <= 0)
				del(W)
	else
		return attack_hand(user)
	return

/turf/simulated/wall/meteorhit(obj/M as obj)

	if (M.icon_state == "flaming")
		src.icon_state = "girder"
		if (src.state == 2)
			src.state = 1
			src.opacity = 0
			src.updatecell = 1
			src.intact = 0
			src.levelupdate()
			src.buildlinks()
			src.firelevel = 11
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/metal( src )
		else
			if ((prob(20) && src.state == 1))
				src.state = 0
				//var/turf/simulated/floor/F = new /turf/simulated/floor( locate(src.x, src.y, src.z) )
				var/turf/simulated/floor/F = src.ReplaceWithFloor()
//				F.oxygen = O2STANDARD
				new /obj/item/weapon/sheet/metal( F )
				new /obj/item/weapon/sheet/metal( F )
				F.buildlinks()
				F.levelupdate()
	return

/turf/simulated/floor/CheckPass(atom/movable/O as mob|obj)

	if (istype(O, /obj/machinery/vehicle) && src.intact)
		return 0
	return 1

/turf/simulated/floor/ex_act(severity)
	set src in oview(1)

	switch(severity)
		if(1.0)
			var/turf/space/S = src.ReplaceWithSpace()
			S.buildlinks()
			levelupdate()
			//del(src)	//deleting it makes this method silently stop executing and erases the saved area somehow (SL)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				var/turf/space/S = src.ReplaceWithSpace()
				S.buildlinks()
				levelupdate()
				//del(src)	//deleting it makes this method silently stop executing and erases the saved area somehow (SL)
				return
			else
				AddHotspot()
				src.burnt = 1
				src.health = 30
				src.intact = 0
				levelupdate()
				src.firelevel = 1800000.0
				src.buildlinks()
		if(3.0)
			if (prob(50))
				src.burnt = 1
				src.health = 1
				src.intact = 0
				levelupdate()
				src.icon_state = "Floor1"
				src.buildlinks()
		else
	return

/turf/simulated/floor/blob_act()
	return

/turf/simulated/floor/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/attack_hand(mob/user as mob)

	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/turf/simulated/floor/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if(!C || !user)
		return
	if(istype(C, /obj/item/weapon/crowbar))
		if (src.health <= 100) return
		src.health	= 100
		src.burnt	= 1
		src.intact	= 0
		levelupdate()
		new /obj/item/weapon/tile(src)
		src.icon_state = "Floor[src.burnt ? "1" : ""]"
	else if(istype(C, /obj/item/weapon/tile))
		if(src.health > 100) return
		src.health	= 150
		src.burnt	= 0
		src.intact	= 1
		levelupdate()
		if (src.firelevel >= 900000.0)
			AddHotspot()
		else
			src.icon_state = "Floor"
		var/obj/item/weapon/tile/T = C
		if(--T.amount < 1)
			del(T)
	else if(istype(C, /obj/item/weapon/cable_coil) )
		var/obj/item/weapon/cable_coil/coil = C
		coil.turf_place(src, user)

/turf/simulated/floor/updatecell()
	..()
	if (src.checkfire && src.firelevel >= 2700000)
		src.health--
		if (src.health <= 0)
			src.burnt = 1
			src.intact = 0
			levelupdate()
			del(src)
		else if (src.health <= 100 && !src.burnt && src.intact)
			src.burnt = 1
			src.intact = 0
			levelupdate()