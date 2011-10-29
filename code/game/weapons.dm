/obj/bullet/Bump(atom/A as mob|obj|turf|area)
	spawn(0)
		if(A)
			A.las_act("bullet", src)
		del(src)
	return

/obj/bullet/CheckPass(B as obj)
	if(istype(B, /obj/bullet))
		return prob(95)
	else
		return 1
	return 0

/obj/bullet/electrode/Bump(atom/A as mob|obj|turf|area)
	spawn(0)
		if(A) A.las_act(1)
		del(src)
	return

/obj/bullet/proc/process()
	if ((!( src.current ) || src.loc == src.current))
		src.current = locate(min(max(src.x + src.xo, 1), world.maxx), min(max(src.y + src.yo, 1), world.maxy), src.z)
	if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
		//SN src = null
		del(src)
		return
	step_towards(src, src.current)
	spawn( 1 )
		process()
		return
	return

/obj/beam/a_laser/Bump(atom/A as mob|obj|turf|area)
	spawn(0)
		if(A)
			A.las_act(null, src)
		del(src)

/obj/beam/a_laser/proc/process()
	//world << text("laser at [] []:[], target is [] []:[]", src.loc, src.x, src.y, src:current, src.current:x, src.current:y)
	if ((!( src.current ) || src.loc == src.current))
		src.current = locate(min(max(src.x + src.xo, 1), world.maxx), min(max(src.y + src.yo, 1), world.maxy), src.z)
		//world << text("current changed: target is now []. location was [],[], added [],[]", src.current, src.x, src.y, src.xo, src.yo)
	if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
		//world << text("off-world, deleting")
		//SN src = null
		del(src)
		return
	step_towards(src, src.current)
	// make it able to hit lying-down folk
	var/list/dudes = list()
	for(var/mob/M in src.loc)
		dudes += M
	if(dudes.len)
		src.Bump(pick(dudes))
	//world << text("laser stepped, now [] []:[], target is [] []:[]", src.loc, src.x, src.y, src.current, src.current:x, src.current:y)
	src.life--
	if (src.life <= 0)
		//SN src = null
		del(src)
		return

	spawn(1)
		src.process()
		return
	return

/obj/beam/i_beam/proc/hit()
	//world << "beam \ref[src]: hit"
	if (src.master)
		//world << "beam hit \ref[src]: calling master \ref[master].hit"
		src.master.hit()
	//SN src = null
	del(src)
	return

/obj/beam/i_beam/proc/vis_spread(v)
	//world << "i_beam \ref[src] : vis_spread"
	src.visible = v
	spawn( 0 )
		if (src.next)
			//world << "i_beam \ref[src] : is next [next.type] \ref[next], calling spread"
			src.next.vis_spread(v)
		return
	return

/obj/beam/i_beam/proc/process()
	//world << "i_beam \ref[src] : process"

	if ((src.loc.density || !( src.master )))
		//SN src = null
	//	world << "beam hit loc [loc] or no master [master], deleting"
		del(src)
		return
	//world << "proccess: [src.left] left"

	if (src.left > 0)
		src.left--
	if (src.left < 1)
		if (!( src.visible ))
			src.invisibility = 100
		else
			src.invisibility = 0
	else
		src.invisibility = 0


	//world << "now [src.left] left"
	var/obj/beam/i_beam/I = new /obj/beam/i_beam( src.loc )
	I.master = src.master
	I.density = 1
	I.dir = src.dir
	//world << "created new beam \ref[I] at [I.x] [I.y] [I.z]"
	step(I, I.dir)

	if (I)
		//world << "step worked, now at [I.x] [I.y] [I.z]"
		if (!( src.next ))
			//world << "no src.next"
			I.density = 0
			//world << "spreading"
			I.vis_spread(src.visible)
			src.next = I
			spawn( 0 )
				//world << "limit = [src.limit] "
				if ((I && src.limit > 0))
					I.limit = src.limit - 1
					//world << "calling next process"
					I.process()
				return
		else
			//world << "is a next: \ref[next], deleting beam \ref[I]"
			//I = null
			del(I)
	else
		//src.next = null
		//world << "step failed, deleting \ref[src.next]"
		del(src.next)
	spawn( 10 )
		src.process()
		return
	return

/obj/beam/i_beam/Bump()
	del(src)
	return

/obj/beam/i_beam/Bumped()
	src.hit()
	return

/obj/beam/i_beam/HasEntered(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/beam))
		return
	spawn( 0 )
		src.hit()
		return
	return

/obj/beam/i_beam/Del()
	del(src.next)
	..()
	return

/atom/proc/ex_act()
	return

/atom/proc/blob_act()
	return

/atom/proc/las_act()
	return

/atom/proc/buildlinks()
	return

/turf/Entered(atom/A as mob|obj)
	..()
	if ((A && A.density && !( istype(A, /obj/beam) )))
		for(var/obj/beam/i_beam/I in src)
			spawn( 0 )
				if (I)
					I.hit()
				return
	return