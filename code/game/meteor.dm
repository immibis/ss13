/var/const/meteor_wave_delay = 10 //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round

/var/const/meteors_in_wave = 400
/var/const/meteors_in_small_wave = 1

/proc/meteor_wave()
	if(!ticker || wavesecret)
		return

	wavesecret = 1
	for(var/i = 0 to meteors_in_wave)
		spawn(rand(10,100))
			spawn_meteor()
	spawn(meteor_wave_delay)
		wavesecret = 0

/proc/spawn_meteors()
	for(var/i = 0; i < meteors_in_small_wave; i++)
		spawn(0)
			spawn_meteor()

/proc/spawn_meteor()
	var/startedge = pick(prob(20); NORTH,
	                     prob(5); NORTHEAST,
	                     prob(20); EAST,
	                     prob(5); SOUTHEAST,
	                     prob(20); SOUTH,
	                     prob(5); SOUTHWEST,
	                     prob(20); WEST,
	                     prob(5); NORTHWEST)
	var/startx
	var/starty
	var/endx
	var/endy

	if(startedge & NORTH)
		starty = world.maxy-2 // because of the dumb way the z-level code works
		endy = 1
	else if(startedge & SOUTH)
		starty = 3
		endy = world.maxy-2 // because of the dumb way the z-level code works
	else
		starty = rand(1, world.maxy-2)
		endy = max(min(starty + rand(-5, 5), 1), world.maxy-2) // up to 5 away from starty

	if(startedge & WEST)
		startx = 3 // because of the dumb way the z-level code works
		endx = world.maxx
	else if(startedge & EAST)
		startx = world.maxx - 2 // because of the dumb way the z-level code works
		endx = 1
	else
		startx = rand(1, world.maxx-2)
		endx = max(min(startx + rand(-5, 5), 1), world.maxx) // up to 5 away from starty

	var/obj/meteor/M
	if(rand(50))
		M = new /obj/meteor(locate(startx, starty, 1)) //meteors only spawn on z-level 1, boo hoo
	else
		M = new /obj/meteor/small(locate(startx, starty, 1))
	M.dest = locate(endx, endy, 1)
	walk_towards(M, M.dest, 1)

/obj/meteor
	name = "meteor"
	icon = 'icons/ss13/meteor.dmi'
	icon_state = "flaming"
	density = 1
	anchored = 1.0
	var/hits = 3
	var/dest

/obj/meteor/small
	name = "small meteor"
	icon_state = "smallf"

/obj/meteor/Move()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.firelevel = T.gas.plasma + 5
	..()
	if(src.z != 1 || src.loc == src.dest)
		del(src)
		world << "at dest [src.loc.x] [src.loc.y]"
		return
	return

/obj/meteor/Bump(atom/A)
	spawn(0)
		for(var/mob/M in view(A, null))
			if(!M.stat && !istype(M, /mob/ai)) //bad idea to shake an ai's view
				shake_camera(M, 15, 1)
		if (A)
			A.meteorhit(src)
		if (--src.hits <= 0)
			if(prob(15) && !istype(A, /obj/grille))
				var/obj/item/tank/plasma/pt = new /obj/item/tank/plasma( src )
				pt.gas.temperature = 475+T0C
				pt.ignite()
				//this is pretty crazy, but it seems to be the easiest way to get an explosion
			del(src)
	return


/obj/meteor/ex_act(severity)

	if (severity < 4)
		del(src)
	return
