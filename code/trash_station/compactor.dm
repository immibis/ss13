obj/machinery/trashcompactor
	icon = 'icons/immibis/trashcompactor.dmi'
	icon_state = "off"
	layer = OBJ_LAYER + 1
	name = "compactor"

	density = 0
	anchored = 1

	var/was_running = 0

	CheckPass(O, oldloc)
		return isobj(O)

	var/tmp/matter = 0
	proc/AddMatter(obj/O)
		matter += O.weight
		for(var/obj/O2 in O.contents)
			AddMatter(O2)
		for(var/mob/M in O.contents)
			for(var/o in M.organs)
				var/obj/item/organ/organ = M.organs[o]
				M.organs -= o
				if(istype(organ, /obj/item/organ/internal))
					del(organ)
				else
					organ.Move(get_step(loc, EAST))
			// instant kill
			M.bruteloss = 200 - M.oxyloss - M.fireloss - M.toxloss
			M.updatehealth()
		del(O)

	process()
		if(stat & (BROKEN | NOPOWER))
			return
		matter = 0
		for(var/obj/O in loc)
			if(O == src)
				continue
			AddMatter(O)
			del(O)
		if(matter > 0)
			use_power(TRASHCOMPACTOR_POWER)
			var/obj/item/compacted_cube/cube = new(loc)
			cube.weight = matter
			step(cube, EAST)
			if(!was_running)
				icon_state = "on"
				was_running = 1
		else if(was_running)
			icon_state = "off"
			was_running = 0

	power_change()
		if(powered(EQUIP))
			was_running = 1
			icon_state = "on"
		else
			was_running = 0
			icon_state = "off"

obj/item/compacted_cube
	name = "cube"
	icon = 'icons/immibis/trashcompactor.dmi'
	icon_state = "cube"
