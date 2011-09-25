obj/machinery/injector
	name = "injector"
	icon = 'icons/ss13/stationobjs.dmi'
	icon_state = "injector"
	density = 1
	anchored = 1.0
	flags = WINDOW

	attackby(obj/item/weapon/tank/T as obj, mob/user as mob)
		if(!istype(T))
			return ..()

		var/turf/turf = get_step(src, turn(dir, 180))
		if(turf.density)
			turf = loc
			if(turf.density)
				turf = user.loc
		if(T.gas.total_moles == 0)
			user << "No gas in tank."
		else
			user << "Injected [round(T.gas.total_moles)] moles of gas."
			turf.gas.add_delta(T.gas)
			T.gas.sub_delta(T.gas)