obj/weapsat_equipment/amplifier
	icon_state = "amplifier_0"
	name = "amplifier"

	process()
		var/has_laser
		if(stat & (BROKEN | NOPOWER))
			has_laser = 0
		else
			has_laser = (locate(/obj/weapsat/laser) in get_step(src, WEST)) != null
			use_power(WEAPSAT_AMPLIFIER_POWER)

		var/turf/laser_turf = locate(x+1, y, z)

		icon_state = "amplifier_[has_laser]"

		if(has_laser)
			if(!(locate(/obj/weapsat/laser/u_laser) in laser_turf))
				var/obj/weapsat/laser/u_laser/laser = new(laser_turf)
				laser.dir = EAST
		else
			var/obj/weapsat/laser/u_laser/laser = locate() in laser_turf
			if(laser)
				del laser