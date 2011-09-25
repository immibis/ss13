obj/machinery/recycler
	icon = 'icons/immibis/recycler.dmi'
	icon_state = "off"
	layer = OBJ_LAYER + 1
	name = "recycler"

	density = 0
	anchored = 1

	var/stored_matter = 0

	var/was_running = 0

	CheckPass(O, oldloc)
		return isobj(O)

	process()
		if(stat & (BROKEN | NOPOWER))
			return
		var/matter = 0
		for(var/obj/O in loc)
			if(O == src)
				continue
			if(O.weight < MIN_RECYCLE_WEIGHT)
				return
			matter += O.weight
			del(O)
		if(matter > 0)
			use_power(RECYCLER_POWER)
			// convert matter into metal sheets and glass sheets randomly
			stored_matter += matter
			if(stored_matter > 1000000)
				var/total_sheets = round(stored_matter / 1000000)
				var/metal_sheets = round(rand() * total_sheets, 1)
				var/glass_sheets = total_sheets - metal_sheets
				if(metal_sheets > 0)
					var/obj/item/weapon/sheet/metal/metal = new(loc)
					step(metal, SOUTH)
					metal.amount = metal_sheets
				if(glass_sheets > 0)
					var/obj/item/weapon/sheet/glass/glass = new(loc)
					step(glass, SOUTH)
					glass.amount = glass_sheets
				stored_matter -= total_sheets * 1000000
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

