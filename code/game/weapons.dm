/obj/item/weapon/assembly/proc/r_signal(signal)
	return

/obj/item/weapon/assembly/proc/c_state(n, O as obj)
	return

//*****RM

/obj/item/weapon/assembly/time_ignite/Del()
	del(part1)
	del(part2)
	..()

/obj/item/weapon/assembly/time_ignite/attack_self(mob/user as mob)
	src.part1.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/time_ignite/r_signal()
	for(var/mob/O in hearers(1, src.loc))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	src.part2.ignite()
	return

/obj/item/weapon/assembly/time_ignite/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null

		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The timer is now secured!", 1)
	else
		user.show_message("\blue The timer is now unsecured!", 1)
	src.part2.status = src.status
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/time_ignite/c_state(n)
	src.icon_state = text("time_igniter[]", n)
	return

//*****

/obj/item/weapon/assembly/rad_time/Del()
	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	..()
	return

/obj/item/weapon/assembly/rad_time/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The signaler is now secured!", 1)
	else
		user.show_message("\blue The signaler is now unsecured!", 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/rad_time/attack_self(mob/user as mob)

	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/rad_time/r_signal(n, source)
	if (source == src.part2)
		src.part1.s_signal(1)
	return

/obj/item/weapon/assembly/rad_prox/c_state(n)
	src.icon_state = text("motion[]", n)
	return

/obj/item/weapon/assembly/rad_prox/Del()
	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	..()
	return

/obj/item/weapon/assembly/rad_prox/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/beam))
		return
	if (AM.move_speed < 12)
		src.part2.sense()
	return

/obj/item/weapon/assembly/rad_prox/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The proximity sensor is now secured!", 1)
	else
		user.show_message("\blue The proximity sensor is now unsecured!", 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/rad_prox/attack_self(mob/user as mob)
	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/rad_prox/r_signal(n, source)
	if (source == src.part2)
		src.part1.s_signal(1)
	return

/obj/item/weapon/assembly/rad_prox/Move()
	..()
	src.part2.sense()
	return

/obj/item/weapon/assembly/rad_prox/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/assembly/rad_prox/dropped()
	spawn( 0 )
		src.part2.sense()
		return
	return

/obj/item/weapon/assembly/rad_infra/c_state(n)
	src.icon_state = text("infrared[]", n)
	return

/obj/item/weapon/assembly/rad_infra/Del()
	del(src.part1)
	del(src.part2)
	..()
	return

/obj/item/weapon/assembly/rad_infra/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The infrared laser is now secured!", 1)
	else
		user.show_message("\blue The infrared laser is now unsecured!", 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/rad_infra/attack_self(mob/user as mob)

	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/rad_infra/r_signal(n, source)

	if (source == src.part2)
		src.part1.s_signal(1)
	return

/obj/item/weapon/assembly/rad_infra/verb/rotate()
	set src in usr

	src.dir = turn(src.dir, 90)
	src.part2.dir = src.dir
	src.add_fingerprint(usr)
	return

/obj/item/weapon/assembly/rad_infra/Move()

	var/t = src.dir
	..()
	src.dir = t
	//src.part2.first = null
	del(src.part2.first)
	return

/obj/item/weapon/assembly/rad_infra/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/assembly/rad_infra/attack_hand(M)
	del(src.part2.first)
	..()
	return

/obj/item/weapon/assembly/prox_ignite/HasProximity(atom/movable/AM as mob|obj)

	if (istype(AM, /obj/beam))
		return
	if (AM.move_speed < 12 && src.part1)
		src.part1.sense()
	return

/obj/item/weapon/assembly/prox_ignite/dropped()
	spawn( 0 )
		src.part1.sense()
		return
	return

/obj/item/weapon/assembly/prox_ignite/Del()
	del(src.part1)
	del(src.part2)
	..()
	return

/obj/item/weapon/assembly/prox_ignite/c_state(n)
	src.icon_state = text("prox_igniter[]", n)
	return

/obj/item/weapon/assembly/prox_ignite/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The proximity sensor is now secured! The igniter now works!", 1)
	else
		user.show_message("\blue The proximity sensor is now unsecured! The igniter will not work.", 1)
	src.part2.status = src.status
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/prox_ignite/attack_self(mob/user as mob)

	src.part1.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/prox_ignite/r_signal()
	for(var/mob/O in hearers(1, src.loc))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	src.part2.ignite()
	return

/obj/item/weapon/assembly/rad_ignite/Del()
	del(src.part1)
	del(src.part2)
	..()
	return

/obj/item/weapon/assembly/rad_ignite/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The radio is now secured! The igniter now works!", 1)
	else
		user.show_message("\blue The radio is now unsecured! The igniter will not work.", 1)
	src.part2.status = src.status
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/rad_ignite/attack_self(mob/user as mob)

	src.part1.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/rad_ignite/r_signal()
	for(var/mob/O in hearers(1, src.loc))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	src.part2.ignite()
	return

/obj/item/weapon/assembly/m_i_ptank/c_state(n)

	src.icon_state = text("m_i_ptank[]", n)
	return

/obj/item/weapon/assembly/m_i_ptank/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/beam))
		return
	if (AM.move_speed < 12 && src.part1)
		src.part1.sense()
	return


//*****RM
/obj/item/weapon/assembly/m_i_ptank/Bump(atom/O)
	spawn(0)
		//world << "miptank bumped into [O]"
		if(src.part1.state)
			//world << "sending signal"
			r_signal()
		else
			//world << "not active"
	..()

/obj/item/weapon/assembly/m_i_ptank/proc/prox_check()
	if(!part1 || !part1.state)
		return
	for(var/atom/A in view(1, src.loc))
		if(A!=src && !istype(A, /turf/space) && !isarea(A))
			//world << "[A]:[A.type] was sensed"
			src.part1.sense()
			break

	spawn(50)
		prox_check()


//*****


/obj/item/weapon/assembly/m_i_ptank/dropped()

	spawn( 0 )
		src.part1.sense()
		return
	return

/obj/item/weapon/assembly/m_i_ptank/examine()
	..()
	src.part3.examine()

/obj/item/weapon/assembly/m_i_ptank/Del()

	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	//src.part3 = null
	del(src.part3)
	..()
	return

/obj/item/weapon/assembly/m_i_ptank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/analyzer))
		src.part3.attackby(W, user)

	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/obj/item/weapon/assembly/prox_ignite/R = new /obj/item/weapon/assembly/prox_ignite(  )
		R.part1 = src.part1
		R.part2 = src.part2
		R.loc = src.loc
		if (user.r_hand == src)
			user.r_hand = R
			R.layer = 20
		else
			if (user.l_hand == src)
				user.l_hand = R
				R.layer = 20
		src.part1.loc = R
		src.part2.loc = R
		src.part1.master = R
		src.part2.master = R
		var/turf/T = src.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		src.part3.loc = T
		src.part1 = null
		src.part2 = null
		src.part3 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/weldingtool) ))
		return
	if (!( src.status ))
		src.status = 1
		bombers -= user.ckey
		bombers += user.ckey
		user.show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		src.status = 0
		user << "\blue The hole has been closed."
	src.part2.status = src.status
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/m_i_ptank/attack_self(mob/user as mob)

	src.part1.attack_self(user, 1)
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/m_i_ptank/r_signal()
	//world << "miptank [src] got signal"
	for(var/mob/O in hearers(1, null))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		//Foreach goto(19)

	if ((src.status && prob(90)))
		//world << "sent ignite() to [src.part3]"
		src.part3.ignite()
	else
		if(!src.status)
			src.part3.release()
			src.part1.state = 0.0

	return

//*****RM

/obj/item/weapon/assembly/t_i_ptank/c_state(n)

	src.icon_state = text("t_i_ptank[]", n)
	return

/obj/item/weapon/assembly/t_i_ptank/examine()
	..()
	src.part3.examine()

/obj/item/weapon/assembly/t_i_ptank/Del()

	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	//src.part3 = null
	del(src.part3)
	..()
	return

/obj/item/weapon/assembly/t_i_ptank/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/analyzer))
		src.part3.attackby(W, user)

	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/obj/item/weapon/assembly/time_ignite/R = new /obj/item/weapon/assembly/time_ignite(  )
		R.part1 = src.part1
		R.part2 = src.part2
		R.loc = src.loc
		if (user.r_hand == src)
			user.r_hand = R
			R.layer = 20
		else
			if (user.l_hand == src)
				user.l_hand = R
				R.layer = 20
		src.part1.loc = R
		src.part2.loc = R
		src.part1.master = R
		src.part2.master = R
		var/turf/T = src.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		src.part3.loc = T
		src.part1 = null
		src.part2 = null
		src.part3 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/weldingtool) ))
		return
	if (!( src.status ))
		src.status = 1
		bombers -= user.ckey
		bombers += user.ckey
		user.show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		src.status = 0
		user << "\blue The hole has been closed."
	src.part2.status = src.status

	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/t_i_ptank/attack_self(mob/user as mob)

	if (src.part1)
		src.part1.attack_self(user, 1)
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/t_i_ptank/r_signal()
	//world << "tiptank [src] got signal"
	for(var/mob/O in hearers(1, null))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		//Foreach goto(19)
	if ((src.status && prob(90)))
		//world << "sent ignite() to [src.part3]"
		src.part3.ignite()
	else
		if(!src.status)
			src.part3.release()
	return

/obj/item/weapon/assembly/r_i_ptank/examine()
	..()
	src.part3.examine()

/obj/item/weapon/assembly/r_i_ptank/Del()

	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	//src.part3 = null
	del(src.part3)
	..()
	return

/obj/item/weapon/assembly/r_i_ptank/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/analyzer))
		src.part3.attackby(W, user)

	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/obj/item/weapon/assembly/rad_ignite/R = new /obj/item/weapon/assembly/rad_ignite(  )
		R.part1 = src.part1
		R.part2 = src.part2
		R.loc = src.loc
		if (user.r_hand == src)
			user.r_hand = R
			R.layer = 20
		else
			if (user.l_hand == src)
				user.l_hand = R
				R.layer = 20
		src.part1.loc = R
		src.part2.loc = R
		src.part1.master = R
		src.part2.master = R
		var/turf/T = src.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		src.part3.loc = T
		src.part1 = null
		src.part2 = null
		src.part3 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/weldingtool) ))
		return
	if (!( src.status ))
		src.status = 1
		bombers -= user.ckey
		bombers += user.ckey
		user.show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		src.status = 0
		user << "\blue The hole has been closed."
	src.part2.status = src.status
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/r_i_ptank/attack_self(mob/user as mob)

	if (src.part1)
		src.part1.attack_self(user, 1)
	src.add_fingerprint(user)
	return

/obj/item/weapon/assembly/r_i_ptank/r_signal()
	//world << "riptank [src] got signal"
	for(var/mob/O in hearers(1, null))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		//Foreach goto(19)
	if ((src.status && prob(90)))
		//world << "sent ignite() to [src.part3]"
		src.part3.ignite()
	else
		if(!src.status)
			src.part3.release()
	return

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