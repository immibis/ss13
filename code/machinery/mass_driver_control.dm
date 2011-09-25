obj/machinery/mass_driver_control
	name = "Mass Driver Control"
	icon = 'icons/ss13/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control switch for a mass driver."
	var/id = null
	anchored = 1

	attack_ai(mob/user as mob)
		return attack_hand(user)

	attack_paw(mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/weapon/W, mob/user as mob)
		if(istype(W, /obj/item/weapon/f_print_scanner))
			return
		return attack_hand(user)

	attack_hand(mob/user as mob)
		if(stat & (NOPOWER|BROKEN))
			return

		for(var/obj/machinery/door/poddoor/M in machines)
			if (M.id == src.id)
				spawn(0)
					M.openpod()

		sleep(20)

		for(var/obj/machinery/mass_driver/M in machines)
			if(M.id == src.id)
				M.drive()

		sleep(50)

		for(var/obj/machinery/door/poddoor/M in machines)
			if (M.id == src.id)
				spawn(0)
					M.closepod()

		if(!(stat & (NOPOWER|BROKEN)))
			icon_state = "doorctrl0"

		add_fingerprint(user)

	power_change()
		..()
		if(stat & NOPOWER)
			icon_state = "doorctrl-p"
		else
			icon_state = "doorctrl0"
