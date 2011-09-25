obj/weapsat/laser
	anchored = 1
	density = 1
	name = "laser"
	icon = 'icons/ss13/weap_sat.dmi'
	icon_state = "laser"

	var/obj/weapsat/laser/next = null
	var/list/reflections = new

	proc/TryNext(var/turf/T, dir)
		if(T.isempty())
			next = new type(T)
			next.dir = dir
		else
			var/obj/weapsat_equipment/mirror/mirror = locate() in T
			if(mirror)
				var/newdir
				var/reflectdir
				if(mirror.dir == SOUTH || mirror.dir == EAST)
					if(dir == SOUTH || dir == EAST)
						reflectdir = NORTHWEST
						newdir = turn(dir ^ (SOUTH ^ EAST), 180)
					else
						reflectdir = SOUTHEAST
						newdir = turn(dir ^ (NORTH ^ WEST), 180)
				else
					if(dir == SOUTH || dir == WEST)
						reflectdir = NORTHEAST
						newdir = turn(dir ^ (SOUTH ^ WEST), 180)
					else
						reflectdir = SOUTHWEST
						newdir = turn(dir ^ (NORTH ^ EAST), 180)
				var/obj/weapsat/laser/reflection = new type(T)
				reflection.dir = reflectdir
				reflections += reflection
				TryNext(get_step(T, newdir), newdir)

	New()
		. = ..()
		spawn
			if(dir == NORTH || dir == SOUTH || dir == EAST || dir == WEST)
				TryNext(get_step(src, dir), dir)

	Del()
		if(next)
			del(next)
		for(var/r in reflections)
			del(r)
		. = ..()

	u_laser
		icon_state = "u_laser"
	c_laser
		icon_state = "c_laser"

