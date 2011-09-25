/obj/machinery/igniter
	name = "igniter"
	icon = 'icons/ss13/stationobjs.dmi'
	icon_state = "igniter1"
	var/on = 1.0
	anchored = 1.0

/obj/machinery/igniter/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/igniter/attack_paw(mob/user as mob)
	if ((ticker && ticker.mode.name == "monkey"))
		return src.attack_hand(user)
	return

/obj/machinery/igniter/attack_hand(mob/user as mob)
	if(..())
		return
	add_fingerprint(user)

	src.on = !( src.on )
	src.icon_state = text("igniter[]", src.on)
	return

/obj/machinery/igniter/process()
	if (src.on && !(stat & NOPOWER) )
		var/turf/T = src.loc
		T.ignite = 1
		use_power(IGNITER_POWER)
	return

/obj/machinery/igniter/New()
	..()
	icon_state = "igniter[on]"

/obj/machinery/igniter/power_change()
	if(!( stat & NOPOWER) )
		icon_state = "igniter[src.on]"
	else
		icon_state = "igniter0"
