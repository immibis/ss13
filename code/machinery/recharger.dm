obj/machinery/recharger
	anchored = 1.0
	icon = 'icons/ss13/stationobjs.dmi'
	icon_state = "recharger0"
	name = "recharger"

	var
		obj/item/weapon/gun/energy/charging = null

/obj/machinery/recharger/attackby(obj/item/weapon/G as obj, mob/user as mob)
	if (src.charging)
		return
	if (istype(G, /obj/item/weapon/gun/energy))
		user.drop_item()
		G.loc = src
		src.charging = G

/obj/machinery/recharger/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if (src.charging)
		src.charging.update_icon()
		src.charging.loc = src.loc
		src.charging = null

/obj/machinery/recharger/attack_paw(mob/user as mob)
	if ((ticker && ticker.mode.name == "monkey"))
		return src.attack_hand(user)

/obj/machinery/recharger/process()
	if (src.charging && ! (stat & NOPOWER) )
		if (src.charging.charges < src.charging.maximum_charges)
			src.charging.charges++
			src.icon_state = "recharger1"
			use_power(RECHARGER_POWER)
		else
			src.icon_state = "recharger2"
	else
		src.icon_state = "recharger0"
