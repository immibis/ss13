atom
	var/datum/reagent_container/reagents = null

obj/item/weapon/reagent
	var/max_volume = 50
	var/transfer_size = 50
	var/default_reagent = null

	var/const/TRANSFER_DEFAULT = 0
	var/const/TRANSFER_DRAW = 1
	var/const/TRANSFER_INJECT = 2
	var/transfer_mode = TRANSFER_DEFAULT

	var/draw_verb = "draw" // You [draw_verb] X units from...
	var/inject_verb = "inject" // You [inject_verb] X units into...
	var/transfer_verb = "transfer" // You [transfer_verb] X units into...

	New()
		. = ..()
		reagents = new
		reagents.max_volume = max_volume
		if(default_reagent)
			reagents.init(max_volume, default_reagent)

	examine()
		set src in view(usr)
		..()
		if(src in view(usr, 1))
			usr << "\blue \The [src] contains [reagents.describe()]"

	attackby(obj/item/weapon/reagent/B as obj, mob/user as mob)

		if(!istype(B))
			return ..()

		if(B.transfer_mode != TRANSFER_DEFAULT && transfer_mode == TRANSFER_DEFAULT)
			return B.attackby(src, user)

		switch(transfer_mode)
			if(TRANSFER_DEFAULT)
				var/amt = min(min(B.reagents.cur_volume, B.transfer_size), reagents.max_volume - reagents.cur_volume)
				reagents.transfer_from(B.reagents, amt)
				user.show_message("\blue You [transfer_verb] [amt] units into \the [src]. \The [src] now contains [reagents.describe()].", 1)

			if(TRANSFER_DRAW)
				// Like TRANSFER_DEFAULT, but use src.transfer_size instead of B.transfer_size,
				// and display a different message
				var/amt = min(min(B.reagents.cur_volume, B.transfer_size), reagents.max_volume - reagents.cur_volume)
				reagents.transfer_from(B.reagents, amt)
				user.show_message("\blue You [draw_verb] [amt] units from \the [B]. \The [src] now contains [reagents.describe()].", 1)

			if(TRANSFER_INJECT)
				var/amt = min(min(reagents.cur_volume, transfer_size), B.reagents.max_volume - B.reagents.cur_volume)
				B.reagents.transfer_from(reagents, amt)
				user.show_message("\blue You [inject_verb] [amt] units into \the [B]. \The [src] now contains [reagents.describe()].", 1)
