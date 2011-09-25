obj/machinery/conveyor
	name = "conveyor belt"
	icon = 'icons/goonstation/conveyor.dmi'
	icon_state = "conveyor-off"
	density = 0
	opacity = 0
	anchored = 1

	proc/process_2()
		if(stat & (BROKEN | NOPOWER))
			return
		var/turf/T = get_step(src, dir)
		if(!isturf(T))
			return

		for(var/obj/machinery/door/D in loc) // if closed door on loc, don't operate (even if items on loc)
			if(D.density)
				return

		for(var/obj/machinery/door/D in T) // fixes weird bug where conveyor belts push objs (but not mobs) through closed doors
			if(D.density)
				return

		for(var/atom/movable/A as obj|mob in T)
			if(!A.anchored)
				return // something already on output tile
		for(var/atom/movable/A in loc)
			if(!A.anchored)
				use_power(CONVEYOR_POWER * A.weight)
				//spawn(CONVEYOR_DELAY - 1)
				spawn(9)
					if(A && T && A.loc == loc)
						A.Move(T)
						moved_object(A)
				break // only move one item per tick

	proc/moved_object(atom/movable/A as obj|mob)

	process()
		//for(var/k = CONVEYOR_DELAY; k < 10; k += CONVEYOR_DELAY)
		//	spawn(k) process_2()
		process_2()

	power_change()
		if(powered(EQUIP))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		updateicon()

	proc/updateicon()
		if(stat & NOPOWER)
			icon_state = "conveyor-off"
		else
			icon_state = "conveyor"

obj/machinery/conveyor/autoreverse
	moved_object(atom/movable/A as obj|mob)
		dir = turn(dir, 180)

obj/flaps
	name = "plastic flaps"
	icon = 'icons/goonstation/conveyor.dmi'
	icon_state = "flaps"
	layer = OBJ_LAYER + 1
	anchored = 1
	density = 0
	opacity = 0
	CheckPass(O, oldloc)
		// you can get through in a closet or by lying down
		if(ismob(O))
			var/mob/M = O
			return !M.lying
		return 1