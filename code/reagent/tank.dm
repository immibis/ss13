/obj/largetank
	var/datum/reagent_container/chem
	var/default_reagent

	name = "large tank"
	icon = 'icons/goonstation/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	flags = FPRINT
	weight = 5000000

	New()
		chem = new(60000)
		if(default_reagent)
			var/datum/reagent/R = new default_reagent
			R.amount = chem.max_volume
			chem.add_reagent(R)
		. = ..()

	Del()
		if(isturf(loc))
			chem.move_to_turf(loc)
		. = ..()

	ex_act(severity)
		switch(severity)
			if(1)
				del(src)
			if(2)
				if(prob(50))
					del(src)
			if(3)
				if(prob(5))
					del(src)
			else
		return

	blob_act()
		if(prob(25))
			del(src)

	attackby(obj/W as obj, mob/user as mob)
		if("chem" in W.vars)
			chem.pour_into(W:chem)
			for(var/mob/M in viewers(user) - user)
				M.show_message("\blue [user] refuels \the [W] from \the [src]", 1)
			user.show_message("\the You refuel \the [W] from \the [src]", 1)
		else
			..()


/obj/largetank/water
	name = "water tank"
	icon = 'icons/goonstation/obj/objects.dmi'
	icon_state = "watertank"

	default_reagent = /datum/reagent/water

	Del()
		new /obj/effects/water(src.loc)
		. = ..()

/obj/largetank/weldfuel
	name = "welding fuel tank"
	icon = 'icons/goonstation/obj/objects.dmi'
	icon_state = "weldtank"

	default_reagent = /datum/reagent/welding_fuel


