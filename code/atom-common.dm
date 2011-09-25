/atom/proc/burn(fi_amount)
	return

/atom/movable/Move()
	var/atom/A = src.loc
	. = ..()
	src.move_speed = world.time - src.l_move_time
	src.l_move_time = world.time
	src.m_flag = 1
	if ((A != src.loc && A && A.z == src.z))
		src.last_move = get_dir(A, src.loc)
		src.moved_recently = 1

/atom/proc/meteorhit(obj/meteor as obj)
	return

/atom/proc/allow_drop()
	return 1

/atom/proc/CheckPass(atom/O as mob|obj|turf|area)
	if(istype(O,/atom/movable))
		var/atom/movable/A = O
		return (!src.density || (!A.density && !A.throwing))
	return (!O.density || !src.density)

/atom/proc/CheckExit()
	return 1

/atom/proc/HasEntered(atom/movable/AM as mob|obj)
	return

/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/atom/movable/overlay/attackby(a, b)
	if (src.master)
		return src.master.attackby(a, b)
	return

/atom/movable/overlay/attack_paw(a, b, c)
	if (src.master)
		return src.master.attack_paw(a, b, c)
	return

/atom/movable/overlay/attack_hand(a, b, c)
	if (src.master)
		return src.master.attack_hand(a, b, c)
	return

/atom/movable/overlay/New()
	for(var/x in src.verbs)
		src.verbs -= x
	return

