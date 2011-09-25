/client/proc/Jump(var/area/A in world)
	set desc = "Area to jump to"
	set src = usr

	if(!src.holder)
		src << "Only administrators may use this command."
		return

	var/list/L = list()
	for(var/turf/T in A)
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	usr << "\blue Jumping to [A]!"
	world << "\red Admin [usr] jumped to [A]!"
	world.log_admin("[usr] jumped to [A]")

	usr.loc = pick(L)

	var/obj/effects/sparks/O = new /obj/effects/sparks( usr.loc )
	O.dir = pick(1, 2, 4, 8)
	spawn( 0 )
		O.Life()