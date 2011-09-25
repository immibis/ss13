obj/weapsat_equipment/combiner
	var/has_plasma = 0
	name = "combiner"
	icon_state = "combine_0"
	layer = OBJ_LAYER + 1
	process()
		var/operating
		if(stat & (BROKEN | NOPOWER))
			operating = 0
		else
			operating = (locate(/obj/weapsat/laser/u_laser) in get_step(src, WEST)) != null && has_plasma
			has_plasma = 0
			use_power(WEAPSAT_COMBINER_POWER)

		var/turf/laser_turf = locate(x+1, y, z)

		icon_state = "combine_[operating ? 1 : 0]"

		if(operating)
			if(!(locate(/obj/weapsat/laser/c_laser) in laser_turf))
				var/obj/weapsat/laser/c_laser/laser = new(laser_turf)
				laser.dir = EAST
		else
			var/obj/weapsat/laser/c_laser/laser = locate() in laser_turf
			if(laser)
				del laser