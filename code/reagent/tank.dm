/obj/largetank
	var/default_reagent

	name = "large tank"
	icon = 'icons/goonstation/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	flags = FPRINT
	weight = 5000000

	var/capacity = 2000

	New()
		reagents = new(capacity)
		if(default_reagent)
			var/datum/reagent/R = new default_reagent
			R.amount = reagents.max_volume
			reagents.add_reagent(R)
		. = ..()

	Del()
		if(isturf(loc))
			reagents.move_to_turf(loc)
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

	blob_act()
		if(prob(25))
			del(src)

	attackby(atom/W as obj, mob/user as mob)
		if(W.reagents)
			reagents.pour_into(W.reagents)
			for(var/mob/M in viewers(user) - user)
				M.show_message("\blue [user] refills \the [W] from \the [src]", 1)
			user.show_message("\blue You refill \the [W] from \the [src]", 1)
		else
			. = ..()


/obj/largetank/water
	name = "water tank"
	icon = 'icons/goonstation/obj/objects.dmi'
	icon_state = "watertank"

	default_reagent = /datum/reagent/water

	Del()
		new /obj/effects/water(src.loc)
		. = ..()

	hi_capacity
		capacity = 100000
		name = "high-capacity water tank"

/obj/largetank/weldfuel
	name = "welding fuel tank"
	icon = 'icons/goonstation/obj/objects.dmi'
	icon_state = "weldtank"

	default_reagent = /datum/reagent/welding_fuel


