/obj/window
	name = "window"
	icon = 'icons/goonstation/window.dmi'
	icon_state = "window"
	desc = "A window."
	density = 1
	var/health = 14.0
	var/ini_dir = null
	var/state = 0
	var/reinf = 0
	weight = 2500000.0
	anchored = 1.0
	flags = WINDOW

	las_act(flag)
		if (flag == "bullet")
			if(!reinf)
				new /obj/item/shard( src.loc )
				//SN src = null
				src.density = 0
				src.loc.buildlinks()

				del(src)
			else
				health -= 35
				if(health <=0)
					new /obj/item/shard( src.loc )
					new /obj/item/rods( src.loc )
					src.density = 0
					src.loc.buildlinks()
					del(src)

			return
		return

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				new /obj/item/shard( src.loc )
				if(reinf) new /obj/item/rods( src.loc)
				//SN src = null
				del(src)
				return
			if(3.0)
				if (prob(50))
					new /obj/item/shard( src.loc )
					if(reinf) new /obj/item/rods( src.loc)

					del(src)
					return
		return

	blob_act()
		if(prob(50))
			new /obj/item/shard( src.loc )
			if(reinf) new /obj/item/rods( src.loc)
			density = 0
			src.loc.buildlinks()
			del(src)

	CheckPass(atom/movable/O as mob|obj, target as turf)

		if (istype(O, /obj/beam))
			return 1
		if (src.dir == SOUTHWEST)
			return 0
		else
			if (get_dir(target, O.loc) == src.dir)
				return 0
		return 1

	CheckExit(atom/movable/O as mob|obj, target as turf)
		if (get_dir(O.loc, target) == src.dir)
			return 0
		return 1

	meteorhit()
		src.health = 0
		new /obj/item/shard( src.loc )
		if(reinf) new /obj/item/rods( src.loc)
		src.density = 0
		src.loc.buildlinks()


		del(src)
		return


	hitby(obj/item/W as obj)

		..()
		var/tforce = W.throwforce
		if(reinf) tforce /= 4.0

		src.health = max(0, src.health - tforce)
		if (src.health <= 7 && !reinf)
			src.anchored = 0
			step(src, get_dir(W, src))
		if (src.health <= 0)
			new /obj/item/shard( src.loc )
			if(reinf) new /obj/item/rods( src.loc)
			src.density = 0
			src.loc.buildlinks()
			del(src)
			return
		..()
		return

	attackby(obj/item/W as obj, mob/user as mob)

		if (istype(W, /obj/item/screwdriver))
			if(reinf && state >= 1)
				state = 3 - state
				usr << ( state==1? "You have unfastened the window from the frame." : "You have fastened the window to the frame." )
			else if(reinf && state == 0)
				anchored = !anchored
				user << (src.anchored ? "You have fastened the frame to the floor." : "You have unfastened the frame from the floor.")
			else if(!reinf)
				src.anchored = !( src.anchored )
				user << (src.anchored ? "You have fastened the window to the floor." : "You have unfastened the window.")
		else if(istype(W, /obj/item/crowbar) && reinf)
			if(state <=1)
				state = 1-state;
				user << (state ? "You have pried the window into the frame." : "You have pried the window out of the frame.")
		else
			var/aforce = W.force
			if(reinf) aforce /= 2.0

			src.health = max(0, src.health - aforce)
			if (src.health <= 7)
				src.anchored = 0
				var/turf/sl = src.loc
				step(src, get_dir(user, src))
				sl.buildlinks()
				src.loc.buildlinks()
			if (src.health <= 0)
				if (src.dir == SOUTHWEST)
					var/index = null
					index = 0
					while(index < 2)
						new /obj/item/shard( src.loc )
						if(reinf) new /obj/item/rods( src.loc)
						index++
				else
					new /obj/item/shard( src.loc )
					if(reinf) new /obj/item/rods( src.loc)

				src.density = 0
				src.loc.buildlinks()
				del(src)
				return
			..()
		src.loc.buildlinks()
		return

	verb/rotate()
		set src in oview(1)

		if (src.anchored)
			usr << "It is fastened to the floor; therefore, you can't rotate it!"
			return 0
		else
			if (src.dir == SOUTHWEST)
				usr << "You can't rotate this! "
				return 0
		src.dir = turn(src.dir, 90)
		src.ini_dir = src.dir
		src.loc.buildlinks()
		return

	New(Loc,re=0)
		..()

		if(re)	reinf = re

		src.ini_dir = src.dir
		src.loc.buildlinks()
		if(reinf)
			icon_state = "rwindow"
			desc = "A reinforced window."
			name = "reinforced window"
			state = 2*anchored
			health = 40

		return

	Del()
		src.density = 0
		src.loc.buildlinks()
		..()

	Move()
		var/turf/sl = src.loc
		..()
		src.dir = src.ini_dir
		sl.buildlinks()
		src.loc.buildlinks()
		return

	reinforced
		icon_state = "rwindow"
		desc = "A reinforced window"
		name = "reinforced window"
		state = 2
		health = 40
		reinf = 1