obj/weapsat_equipment/laser
	icon_state = "laser_0"
	name = "laser"

	process()
		var/has_laser
		if(stat & (BROKEN | NOPOWER))
			has_laser = 0
		else
			has_laser = 1
			use_power(WEAPSAT_LASER_POWER)

		var/turf/laser_turf = get_step(src, EAST)

		icon_state = "laser_[has_laser]"

		if(has_laser)
			if(!(locate(/obj/weapsat/laser) in laser_turf))
				var/obj/weapsat/laser/laser = new(laser_turf)
				laser.dir = EAST
		else
			var/obj/weapsat/laser/laser = locate() in laser_turf
			if(laser)
				del laser
