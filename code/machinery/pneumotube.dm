obj/machinery/pneumotube
	var/dir1
	var/dir2

	anchored = 1
	density = 0
	opacity = 0
	layer = OBJ_LAYER - 1
	name = "pneumo-tube"

	icon = 'icons/immibis/pneumotube.dmi'

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
		flick("[prefix][suffix]", src)

	proc/get_random_source_dir()
		return pick(dir1, dir2)

	proc/receive_item(obj/item/weapon/item, from)
		var/indir = get_dir(src, from)
		if(indir != dir1 && indir != dir2)
			world.log << "In-dir [dir2text(indir)] isn't in direction ([dir2text(dir1)]/[dir2text(dir2)]) of [x],[y],[z]"
			indir = get_random_source_dir()
		var/outdir = indir ^ (dir1 ^ dir2)
		animate(indir, outdir)
		item.Move(src)
		spawn(4) send_item(item, outdir)

	proc/send_item(obj/item/weapon/item, outdir)
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
			else
				//world.log << "pneumotube deleted [item] because no exit"
				del(item)

	end
		icon_state = "end"
		name = "Garbage disposal" // change this in the map individually
		layer = OBJ_LAYER + 1

		CheckPass(O, oldloc)
			return !ismob(O)

		get_random_source_dir()
			return turn(dir, 180)

		animate(in_dir, out_dir)

		attackby(obj/item/weapon/item, mob/user)
			if(!istype(item))
				return
			if(istype(item, /obj/item/weapon/grab))
				var/obj/item/weapon/grab/G = item
				send_item(G.affecting, dir)
				user.drop_item(item)
			else
				user.drop_item(item)
				send_item(item, dir)

		receive_item(obj/item/weapon/item, from)
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
				if(O != src)
					send_item(O, dir)
				return


	merge
		icon_state = "merge"

		receive_item(obj/item/weapon/item, from)
			var/indir = get_dir(src, from)
			var/outdir = (indir == dir ? pick(turn(dir, -90), turn(dir, 90)) : dir)
			spawn(4) send_item(item, outdir)

		animate(in_dir, out_dir)

	oneway
		icon_state = "oneway"

		receive_item(obj/item/weapon/item, from)
			spawn(4) send_item(item, dir)
