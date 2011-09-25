obj/weapsat_equipment/heater // TODO: make this require plasma in small tanks
	icon_state = "heater_0"
	name = "heater"
	layer = OBJ_LAYER + 1

	process()
		var/operating
		if(stat & (BROKEN | NOPOWER))
			operating = 0
		else
			operating = 1
			use_power(WEAPSAT_HEATER_POWER)

		icon_state = "heater_[operating]"

		if(operating)
			var/obj/weapsat/plasmaball_orange/plasmaball = new(loc)
			plasmaball.dir = NORTH