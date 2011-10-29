// Hydroponics reagent classes:
// plant_toxic (1 = same damage amount as lack of water)
// fertilizer (1 = same fertilization as poo)

obj/item/reagent/watering_can
	max_volume = 360
	transfer_size = 60
	name = "watering can"
	icon = 'icons/isno/Hydroponics/Items/WateringCan.dmi'
	default_reagent = /datum/reagent/water

// PLACEHOLDERS
mob
	proc/irradiate()
	proc/splash_reagent(datum/reagent/R)

datum/plant
	var/name
	var/id

	// stage 0 = dead
	// stage 1 = growing
	// stage 2 = mature, growing
	// stage 3 = ready to harvest

	// plants grow 1 --> 2 <-> 3 --> 0

	var/stage = 1
	var/growth_pct = 0
	var/health = 100
	var/yield

	var/stage1_multiplier
	var/stage2_multiplier

	var/harvests
	var/generation
	var/endurance

	var/base_harvests = 3
	var/base_yield = 5
	var/base_endurance = 1
	var/base_maturation = AVERAGE
	var/base_production = AVERAGE
	var/reagent_multiplier = 1 // multiplier for mL used per percent grown
	var/fruit_type = null

	var/const/AVERAGE = 1
	var/const/SLOW = 0.5
	var/const/VERY_SLOW = 0.25
	var/const/FAST = 3

	// genes
	// unlike Goonstation, higher is better for the
	// maturation and production rates
	var/g_maturation = 0
	var/g_production = 0
	var/g_lifespan = 0
	var/g_yield = 0
	var/g_endurance = 0

	proc/apply_genes()
		stage1_multiplier = max(0.2, base_maturation * (1 + g_maturation / 10 + rand_frac(-0.15, 0.15)))
		stage2_multiplier = max(0.2, base_production * (1 + g_production / 10 + rand_frac(-0.15, 0.15)))
		harvests = round(max(1, base_harvests + round(g_lifespan / 5, 1) + rand_frac(-1, 1)), 1)
		yield = round(max(1, base_yield * (1 + round(g_yield / 10) + rand_frac(-0.1, 0.1))), 1)
		endurance = max(0.2, 1 + g_endurance / 5)

	proc/create_seed()
		var/obj/item/seed/S = new
		S.g_maturation = g_maturation + rand(-3, 3)
		S.g_production = g_production + rand(-3, 3)
		S.g_lifespan = g_lifespan + rand(-3, 3)
		S.g_yield = g_yield + rand(-3, 3)
		S.g_endurance = g_endurance + rand(-3, 3)
		S.generation = generation + 1
		S.plant_type = type
		return S

	weed
		proc/do_effect(obj/plant_pot/pot)

		creeper
			name = "creeper plant"
			id = "creeper"
			do_effect(obj/plant_pot/P)
				if(prob(90))
					return
				for(var/obj/plant_pot/P2 in orange(P, 1))
					if(P2.plant == null && prob(50))
						P2.start_growing(/datum/plant/weed/creeper)

		lasher
			name = "lasher plant"
			id = "lasher"
			do_effect(obj/plant_pot/P)
				if(prob(70))
					return
				for(var/mob/M in orange(P, 1))
					if(prob(25))
						continue
					for(var/mob/M2 in viewers(src))
						M2.show_message("\red <B> \The [src] lashes out at [M]!", 1)
					M.show_message("\red <B> \The [src] lashes out at you!", 1)
					M.bruteloss += 2
					M.updatehealth()
		radweed
			name = "radweed plant"
			id = "radweed"
			do_effect(obj/plant_pot/P)
				if(prob(80))
					return
				for(var/mob/M in orange(P, 1))
					if(prob(50))
						M.irradiate()

		// For some reason my version of the slurrypod creates welding fuel.
		// Meh. I decided not to remove it. SS13 needs lots of weirdness!
		slurrypod
			name = "slurrypod plant"
			id = "slurrypod"
			do_effect(obj/plant_pot/P)
				var/datum/reagent/R

				// splash toxic goop
				for(var/mob/M in orange(P, 4))
					for(var/mob/M2 in viewers(M))
						M2.show_message("\red <B> [M] is splashed by toxic goop!", 1)
					M.show_message("\red <B> You are splashed by toxic goop!", 1)

					R = new/datum/reagent/slurrypod_toxin
					R.amount = health / 2
					M.splash_reagent(R)

				// add toxins to the soil (and welding fuel???)
				R = new /datum/reagent/slurrypod_toxin
				R.amount = health
				P.reagents.add_reagent(R)
				R = new /datum/reagent/welding_fuel
				R.amount = health
				P.reagents.add_reagent(R)

				// kill the slurrypod
				P.kill_plant()

		fungus
			name = "space fungus plant"
			id = "fungus"
			// doesn't do anything special, just annoys people

obj/item/seed
	icon = 'icons/isno/Hydroponics/Items/seed.dmi'
	icon_state = "1"

	var/plant_type = null
	var/g_maturation = 0
	var/g_production = 0
	var/g_lifespan = 0
	var/g_yield = 0
	var/g_endurance = 0
	var/generation = 1

	proc/create_plant()
		var/datum/plant/P = new plant_type()
		P.g_maturation = g_maturation
		P.g_production = g_production
		P.g_lifespan = g_lifespan
		P.g_yield = g_yield
		P.g_endurance = g_endurance
		P.generation = generation
		P.apply_genes()
		return P

	New()
		. = ..()
		icon_state = "[rand(1, 3)]"
		pixel_x = rand(-12, 12)
		pixel_y = rand(-12, 12)

obj/plant_pot
	var/datum/plant/plant = null

	anchored = 1
	density = 1

	icon = 'icons/isno/Hydroponics/Standard Crops/crops.dmi'
	icon_state = "empty"

	New()
		reagents = new(INFINITY)
		reagents.add_reagent(new/datum/reagent/water {amount = 180})
		. = ..()

		start_growing(/datum/plant/tomato)

	OnTickerStart()
		spawn(rand(0,9))
			while(1)
				process()
				sleep(10)

	proc/process()
		if(plant == null)
			if(prob(5))
				start_growing(pick(typesof(/datum/plant/weed) - /datum/plant/weed))
			return

		if(plant.stage == 0)
			return // dead plants can't do anything

		var/compost = reagents.get_amount_of("fertilizer")
		var/water = reagents.get_amount_of(/datum/reagent/water)
		var/toxic = reagents.get_amount_of("plant_toxic")

		if(istype(plant, /datum/plant/weed))
			toxic += reagents.get_amount_of("weedkiller")

		var/reagent_use

		plant.health -= toxic / plant.endurance

		if(plant.stage == 3)
			// if the plant can be harvested, then it doesn't grow, but it still uses some reagent.
			reagent_use = plant.reagent_multiplier

			if(istype(plant, /datum/plant/weed))
				var/datum/plant/weed/W = plant
				W.do_effect(src)
		else
			var/w_mult = 1
			if(water > 180)
				w_mult = 0.75
			else if(water <= 120)
				w_mult = max(water/60 - 1, 0.5)

			var/c_mult = min(1 + compost / 20, 2.5)

			var/grow_amt = c_mult * w_mult * (plant.stage == 1 ? plant.stage1_multiplier : plant.stage2_multiplier)
			reagent_use = grow_amt * plant.reagent_multiplier

			plant.growth_pct += grow_amt
			if(plant.growth_pct >= 100)
				plant.growth_pct -= 100
				plant.stage++

		if(water <= 60)
			// 5% damage/sec at 0 water, 0% at 60 water
			plant.health -= (60 - water) / 12 / plant.endurance
		else if(compost >= 30)
			// heal plants slowly when watered and composted
			plant.health += min((water - 60) / 60 * compost / 10, 0.5)


		// otherwise it uses wayyyy too much reagent
		reagent_use *= 0.1


		// this is "cheating" and doesn't quite work properly...
		// for example, someone could fill the pot with random
		// reagents and it would use less water and compost.

		// but if a player finds that out, good on them - it's just another
		// part of the weirdness that is SS13!

		reagents.split_and_remove(reagent_use)



		if(plant.health < 0 || plant.harvests <= 0)
			kill_plant()

		updateicon()

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/screwdriver))
			for(var/mob/M in viewers(user))
				M.show_message("[user] [anchored ? "unscrews \the [src]." : "screws \the [src] in place."]", 1)
			user << "\blue You [anchored ? "unscrew \the [src]." : "screw \the [src] in place."]"
			anchored = !anchored
		else if(istype(I, /obj/item/seed))
			var/obj/item/seed/S = I
			plant = S.create_plant()
			del(S)
			updateicon()
		else if(istype(I, /obj/item/reagent))
			var/obj/item/reagent/IR = I
			//IR.transfer_to(src)
			IR.attackby(src, user)
			updateicon()
		else if(istype(I, /obj/item/plant_analyzer))
			reagents.describe_detailed_to(src, user)
			if(plant)
				user << "\blue \The [src] is [round(plant.health, 1)]% healthy."
				user << "\blue Maturation: [plant.g_maturation] ([round(plant.stage1_multiplier, 0.1)]%)"
				user << "\blue Production: [plant.g_production] ([round(plant.stage2_multiplier, 0.1)]%)"
				user << "\blue Lifespan: [plant.g_lifespan] (estimated [plant.harvests + (prob(70) ? 0 : rand(-1, 1))] harvests remaining)"
				user << "\blue Yield: [plant.g_yield] (estimated [plant.yield + (prob(50) ? 0 : rand(-1, 1))] items expected)"
				user << "\blue Endurance: [plant.g_endurance]"
			else
				user << "\blue Nothing is planted here."
		else
			. = ..()

	attack_paw(mob/user)
		attack_hand(user)

	MouseDrop(atom/M)
		if(M != usr) return
		if(get_dist(usr,src) > 1) return
		if(istype(M,/mob/ai)) return
		if(LinkBlocked(usr.loc,src.loc)) return

		user << "\blue You empty out the pot."

		plant = null
		if(loc.reagents)
			reagents.transfer_into(loc.reagents)
		else
			reagents.clear()
		updateicon()

	attack_hand(mob/user)
		add_fingerprint(user)
		if(plant && plant.stage == 3)
			harvest(user)
		else if(plant && plant.stage == 2)
			user << "\blue You clear the dead plant from the pot."
			empty_pot()
		else if(plant)
			user << "You check \the [src]."
			var/compost = reagents.get_amount_of("fertilizer")
			var/water = reagents.get_amount_of(/datum/reagent/water)
			var/toxic = reagents.get_amount_of("plant_toxic")

			if(istype(plant, /datum/plant/weed))
				toxic += reagents.get_amount_of("weedkiller")

			if(water == 60)
				user << "\red The soil is completely dry."
			else if(water <= 120)
				user << "\red The soil looks a little dry."
			else if(water > 180)
				user << "\red The soil is too soggy."

			else if(plant.health < 50)
				user << "\red The plant is in a poor condition."
			else if(plant.health > 150)
				user << "\blue The plant is flourishing!"
			else if(plant.health > 90)
				user << "\blue The plant looks very healthy."

			if(istype(plant, /datum/plant/weed))
				user << "\red Weeds have infested the soil."

			if(toxic > 1)
				user << "\red The plant is withering!"
			else if(toxic > 0.1)
				user << "\red The plant looks sick."
			else if(toxic > 0.01)
				user << "\red The plant looks slightly sick."

			if(compost > 3)
				user << "\blue The soil looks rich and fertile."
		else
			user << "You check \the [src]."
			user << "\blue \The [src] is empty."
			if(reagents.get_amount_of("plant_toxic") > 1)
				user << "\red A foul odor emanates from the soil."

	proc/harvest(mob/user)
		if(!plant)
			return
		for(var/mob/M in viewers(user))
			M.show_message("[user] harvests \the [src].", 1)
		user << "\blue You harvest \the [src]."

		if(plant.fruit_type)
			for(var/k = 1 to plant.yield)
				new plant.fruit_type(user.loc)
		for(var/k = 1 to rand(1, plant.yield))
			var/obj/item/seed/S = plant.create_seed()
			S.loc = user.loc
		plant.harvests--
		if(plant.harvests <= 0)
			kill_plant()
		else
			plant.stage = 2
			plant.growth_pct = 0
		updateicon()

	proc/kill_plant()
		plant.stage = 0
		if(!("[plant.id]-0" in icon_states(icon)))
			// if there's no dead icon, then the plant can't exist in a dead state
			// - it just disappears instead
			empty_pot()
			return

	proc/empty_pot()
		plant = null
		updateicon()

	proc/start_growing(plant_type)
		plant = new plant_type
		plant.apply_genes()
		updateicon()

	var/cur_overlay = -1
	var/cur_overlay_h = 0
	proc/updateicon()
		if(plant)
			if("[plant.id]-[plant.stage]" in icon_states(icon))
				icon_state = "[plant.id]-[plant.stage]"
			else if(plant.stage == 3)
				icon_state = "[plant.id]-2"
			else
				icon_state = "error"
			name = plant.name
		else
			icon_state = "empty"
			name = "plant pot"

		// 0 - red flashing bar
		// 1 to 60 - red bar
		// 61 to 120 - yellow bar
		// 121 to 180 - green bar
		// 181+ - blue flashing bar

		var/overlay_h = (plant && plant.stage == 3)
		var/num = 0
		var/water = reagents.get_amount_of(/datum/reagent/water)
		if(water == 0)
			num = 0
		else if(water <= 60)
			num = 1
		else if(water <= 120)
			num = 2
		else if(water <= 180)
			num = 3
		else
			num = 4

		if(overlay_h != cur_overlay_h || num != cur_overlay)
			cur_overlay_h = overlay_h
			cur_overlay = num
			overlays = null
			overlays += image('icons/isno/Hydroponics/Resprite 2/overlays.dmi', "[num]")
			if(plant && plant.stage == 3)
				overlays += image('icons/isno/Hydroponics/Resprite 2/overlays.dmi', "harvest")

/obj/item/plant_analyzer
	name = "plant analyzer"
	icon = 'icons/immibis/plant_analyzer.dmi'
	icon_state = "blank"

	New()
		. = ..()
		icon_state = "[rand(1, 3)]"

/datum/reagent
	weedkiller
		name = "weedkiller"
		class = list("weedkiller"=1)
	slurrypod_toxin
		name = "toxic goop"
		class = list("toxic"=1, "plant_toxic"=3)

turf/simulated/floor/astroturf
	name = "astroturf"
#if 0 // this uses darker grass
	icon = 'icons/isno/Hydroponics/Resprite 2/grass.dmi'
	icon_state = "1"
	New()
		icon_state = "[rand(1, 4)]"
		. = ..()
#else // this uses brighter grass
	icon = 'icons/goonstation/floor.dmi'
	icon_state = "grass1"
	New()
		icon_state = "grass[rand(1, 4)]"
		. = ..()
#endif