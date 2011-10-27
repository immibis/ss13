obj/machinery/pneumotube
	var/dir1
	var/dir2

	anchored = 1
	density = 0
	opacity = 0
	layer = 2.5
	name = "pneumo-tube"

	icon = 'icons/immibis/pneumotube.dmi'

	var/fast = 0

	var/broken = 0

	blob_act()
		if(prob(25))
			broken = 1
			updateicon()

	ex_act(severity)
		if(prob(133 - 33*severity))
			broken = 1
			updateicon()

	attackby(obj/item/weldingtool/W, mob/user)
		if(istype(W) && W.welding && broken)
			for(var/mob/M in viewers(user) - user)
				M.show_message("\blue [user] repairs \the [src].", 1)
			user.show_message("You repair \the [src].", 1)
			broken = 0
			updateicon()

	level = 1
	hide(var/i)
		invisibility = i ? 101 : 0
		updateicon()

	proc/updateicon()
		icon_state = broken ? (invisibility ? "broken-f" : "broken") : (invisibility ? "f" : "")

	New()
		if(dir == NORTH || dir == SOUTH || dir == EAST || dir == WEST)
			dir1 = dir
			dir2 = turn(dir, 180)
		else
			if(dir == NORTHEAST || dir == NORTHWEST)
				dir1 = NORTH
			else
				dir1 = SOUTH
			dir2 = dir ^ dir1
		if(level == 1)
			var/turf/T = loc
			if(T && istype(T))
				hide(T.intact)
		. = ..()

	proc/animate(in_dir, out_dir)
		var/prefix
		var/suffix
		if(in_dir == turn(out_dir, 180))
			prefix = "move"
		else
			prefix = "move[(dir & SOUTH) ? "s" : "n"][dir & (EAST) ? "e" : "w"]"
		switch(out_dir)
			if(SOUTH)
				suffix = "s"
			if(NORTH)
				suffix = "n"
			if(EAST)
				suffix = "e"
			if(WEST)
				suffix = "w"
		flick("[prefix][suffix][fast ? "f" : ""]", src)

	proc/get_random_source_dir()
		return pick(dir1, dir2)

	proc/receive_item(obj/item/item, atom/from)
		var/indir = get_dir(src, from)
		if(indir != dir1 && indir != dir2)
			if(!item.Move(loc))
				if(!item.Move(from.loc))
					item.loc = from.loc
			return
			//world.log << "Input direction [dir2text(indir)] isn't in direction ([dir2text(dir1)]/[dir2text(dir2)]) of [x],[y],[z]"
			indir = get_random_source_dir()
		var/outdir = indir ^ (dir1 ^ dir2)
		animate(indir, outdir)
		item.Move(src)
		spawn(fast ? 1 : 4) send_item(item, outdir)

	proc/send_item(obj/item, outdir)
		if(!item)
			return
		var/obj/machinery/pneumotube/P = locate() in get_step(src, outdir)
		if(P)
			P.receive_item(item, src)
		else
			var/turf/T = get_step(src, outdir)
			var/turf/Tloc = loc
			//world.log << "No pneumotube [dir2text(outdir)] of [x],[y],[z]. Direction: [dir2text(dir1)]/[dir2text(dir2)]"
			if(T.isempty())
				item.Move(T)
			else if(Tloc.isempty())
				item.Move(Tloc)
			else if(!T.density)
				item.Move(T)
			else if(!Tloc.density)
				item.Move(Tloc)
			else
				item.Move(loc)
				//world.log << "pneumotube deleted [item] because no exit"
				//del(item)

	fast
		name = "fast pneumo-tube"
		fast = 1
		level = 2

	end
		icon_state = "end"
		name = "Garbage disposal" // change this in the map individually
		layer = OBJ_LAYER + 1

		level = 2

		CheckPass(O, oldloc)
			return !ismob(O)

		get_random_source_dir()
			return turn(dir, 180)

		animate(in_dir, out_dir)

		attackby(obj/item, mob/user)
			if(!istype(item))
				return
			if(istype(item, /obj/item/grab))
				var/obj/item/grab/G = item
				send_item(G.affecting, dir)
				user.drop_item(item)
			else
				user.drop_item(item)
				send_item(item, dir)

		receive_item(obj/item/item, from)
			var/turf/T = get_step(loc, turn(dir, 180))
			if(T.isempty())
				item.Move(T)
			else
				T = loc
				if(T.isempty())
					item.Move(T)
				else
					send_item(item, dir)

		process()
			for(var/obj/O in loc)
				if(O != src && !O.anchored)
					send_item(O, dir)


	merge
		icon_state = "merge"

		updateicon()
			icon_state = invisibility ? "merge-f" : "merge"

		receive_item(obj/item/item, from)
			var/indir = get_dir(src, from)
			var/outdir = (indir == dir ? pick(turn(dir, -90), turn(dir, 90)) : dir)
			spawn(4) send_item(item, outdir)

		animate(in_dir, out_dir)

	oneway
		icon_state = "oneway"

		updateicon()
			icon_state = invisibility ? "oneway-f" : "oneway"

		receive_item(obj/item/item, from)
			spawn(4) send_item(item, dir)
