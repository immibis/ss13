/obj/item/reagent/bottle
	name = "bottle"
	throw_speed = 4
	throw_range = 20
	w_class = 1.0
	max_volume = 50

	icon = 'icons/goonstation/obj/chemical.dmi'
	icon_state = "bottle3" // 3, 14-19

	New()
		. = ..()
		src.pixel_y = rand(-8, 8)
		src.pixel_x = rand(-8, 8)

	inaprovaline
		name = "inaprovaline bottle"
		default_reagent = /datum/reagent/inaprovaline
		icon_state = "bottle14"

	sleep_toxin
		name = "sleep toxin bottle"
		default_reagent = /datum/reagent/sleep_toxin
		icon_state = "bottle15"

	antitoxin
		name = "antitoxin bottle"
		default_reagent = /datum/reagent/antitoxins
		icon_state = "bottle16"


	weedkiller
		name = "weedkiller bottle"
		default_reagent = /datum/reagent/weedkiller
		icon_state = "bottle15"
