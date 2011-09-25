area/immibis/weapsat/name = "Weapons Satellite"

turf/weapsat
	parent_type = /turf/simulated
	icon = 'icons/ss13/weap_sat.dmi'
	icon_state = "Floor"
	name = "floor"

	New()
		. = ..()
		icon_state = "Floor1"

	proc/power_changed(has_power)
		icon_state = has_power ? "Floor" : "Floor1"

obj/weapsat_equipment/floor_lighting_controller
	// invisible object that controls the floor's appearance
	invisibility = 101
	anchored = 1
	density = 0
	opacity = 0
	var/was_powered = -1
	var/nturfs = 0
	var/ticks = 0
	New()
		. = ..()
		was_powered = 0

	process()
		if(stat & NOPOWER)
			if(was_powered != 0)
				for(var/turf/weapsat/T in loc.loc)
					T.power_changed(0)
			was_powered = 0
		else
			if(was_powered != 1)
				for(var/turf/weapsat/T in loc.loc)
					T.power_changed(1)
			was_powered = 1
		ticks ++
		if(ticks == 10)
			ticks = 0
			nturfs = 0
			for(var/turf/weapsat/T in loc.loc)
				nturfs ++
		use_power(nturfs * WEAPSAT_FLOOR_POWER, EQUIP)
