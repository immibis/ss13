obj/weapsat/plasmaball_orange
	icon_state = "plasma_orange"
	name = "plasma ball"
	anchored = 1
	density = 0
	luminosity = 2
	icon = 'icons/ss13/weap_sat.dmi'
	New()
		spawn
			sleep(8)
			while(Move(get_step(src, NORTH)))
				sleep(8)
			sleep(8)
			loc = get_step(src, NORTH)
			var/obj/weapsat_equipment/combiner/c = locate() in loc
			if(c)
				c.has_plasma = 1
			sleep(8)
			del(src)
	// todo: make this damage things