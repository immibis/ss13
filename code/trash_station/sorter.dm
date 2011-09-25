obj/machinery/trashsorter
	icon = 'icons/immibis/trashsorter.dmi'
	layer = OBJ_LAYER + 1
	name = "sorter"

	density = 0
	anchored = 1

	var/pass_dir
	var/reject_dir

	New()
		..()
		reject_dir = dir
		pass_dir = (dir == NORTH || dir == SOUTH) ? EAST : SOUTH;

	CheckPass(O, oldloc)
		return isobj(O)

	process()
		if(stat & (BROKEN | NOPOWER))
			return
		for(var/obj/O in loc)
			if(O == src)
				continue
			if(O.weight < MIN_RECYCLE_WEIGHT)
				step(O, reject_dir)
			else
				step(O, pass_dir)
