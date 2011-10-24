// on-off valve

/obj/machinery/atmospherics/binary/valve
	var/open = 0
	anchored = 1
	icon = 'icons/ss13/pipes.dmi'

	process()
		if(open)
			equalize_gas(gas1, gas2)

	examine()
		set src in oview(1)

		usr << "[desc] It is [ open? "open" : "closed"]."

	mvalve
		name = "manual valve"
		desc = "A manually controlled valve."
		icon = 'icons/ss13/pipes.dmi'
		icon_state = "valve0"

		New()
			..()
			icon_state = "valve[open]"

		attack_paw(mob/user)
			attack_hand(user)

		attack_ai(mob/user)
			user << "\red You are unable to use this as it is physically operated."

		attack_hand(mob/user)
			..()
			add_fingerprint(user)
			if(stat & BROKEN)
				return
			toggle()

		proc/toggle()
			if(!open)		// now opening
				flick("valve01", src)
				icon_state = "valve1"
				sleep(10)
			else			// now closing
				flick("valve10", src)
				icon_state = "valve0"
				sleep(10)
			open = !open

	dvalve
		name = "digital valve"
		desc = "A digitally controlled valve."
		icon = 'icons/ss13/pipes.dmi'
		icon_state = "dvalve0"

		New()
			..()
			icon_state = "dvalve[open]"

		examine()
			set src in oview(1)
			if(stat & NOPOWER)
				usr << "[desc] It is unpowered! It is [ open? "open" : "closed"]."
			else
				usr << "[desc] It is [ open? "open" : "closed"]."

		power_change()
			..()
			icon_state = "dvalve[open][stat & NOPOWER ? "nopower" : ""]"


		attack_paw(mob/user)
			return src.attack_hand(user)

		attack_ai(var/mob/user as mob)
			return src.attack_hand(user)

		attack_hand(mob/user)
			..()
			add_fingerprint(user)
			if(stat & (BROKEN|NOPOWER))
				return
			toggle()

		proc/toggle()
			if(!open)		// now opening
				flick("dvalve01", src)
				icon_state = "dvalve1"
				sleep(10)
			else			// now closing
				flick("dvalve10", src)
				icon_state = "dvalve0"
				sleep(10)
			open = !open

// remote digital valve control
/*/obj/machinery/dvalve_control
	name = "Remote Valve Control"
	icon = 'icons/ss13/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control switch for a digital valve."
	var/id = null
	anchored = 1

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attackby(obj/item/weapon/W, mob/user as mob)
		if(istype(W, /obj/item/weapon/f_print_scanner))
			return
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(stat & (NOPOWER|BROKEN))
			return
		use_power(DVALVE_CONTROL_POWER)
		icon_state = "doorctrl1"

		//for(var/obj/machinery/valve/dvalve/M in machines)
			//if (M.id == src.id)
				//M.toggle()

		spawn(15)
			if(!(stat & NOPOWER))
				icon_state = "doorctrl0"
		src.add_fingerprint(usr)

	power_change()
		..()
		if(stat & NOPOWER)
			icon_state = "doorctrl-p"
		else
			icon_state = "doorctrl0"*/