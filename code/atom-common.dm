atom
	proc/meteorhit(obj/meteor)
		return 1

	proc/CheckPass(atom/movable/O)
		if(istype(O,/atom/movable))
			return (!density || (!O.density && !O.throwing))
		return (!O.density || !density)

	proc/CheckExit()
		return 1

	proc/burn(fi_amount)
	proc/HasEntered(atom/movable/AM)
	proc/HasProximity(atom/movable/AM)
	proc/OnTickerStart()

atom/movable
	Move()
		var/atom/A = loc
		. = ..()
		move_speed = world.time - l_move_time
		l_move_time = world.time
		m_flag = 1
		if ((A != loc && A && A.z == z))
			last_move = get_dir(A, loc)
			moved_recently = 1

atom/movable/overlay
	attackby(a, b)
		if(master)
			return master.attackby(a, b)

	attack_paw(a, b, c)
		if(master)
			return master.attack_paw(a, b, c)

	attack_hand(a, b, c)
		if(master)
			return master.attack_hand(a, b, c)

	New()
		verbs -= verbs

