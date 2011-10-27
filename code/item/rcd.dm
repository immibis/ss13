/obj/item/rcd
	icon = 'icons/immibis/rcd.dmi'
	icon_state = "5"

	name = "Rapid Construction Device"

	var/const/MODE_DECONSTRUCT = 0
	var/const/MODE_CONSTRUCT = 1
	var/const/MODE_AIRLOCK = 2

	var/const/MAX_AMMO = 90
	var/const/CART_AMMO = 30

	var/mode = MODE_DECONSTRUCT

	var/list/mode_names = list("deconstruct", "construct", "airlock")

	var/ammo = MAX_AMMO

	New()
		. = ..()
		updateicon()

	attack_self(mob/user)
		mode = (mode + 1) % 3
		user << "\red You switch \the [src] to [mode_names[mode + 1]] mode."
		updateicon()

	proc/updateicon()
		overlays = null
		overlays += mode_names[mode + 1]
		icon_state = "[min(5, round(ammo/(MAX_AMMO/5) + 1))]"

	attackby(obj/item/rcd_ammo/A, mob/user)
		if(!istype(A))
			. = ..()
		else
			if(ammo > MAX_AMMO - CART_AMMO)
				user << "\red The RCD cannot hold this much ammo."
				return
			ammo += CART_AMMO
			user << "\red You insert \the [A] into the RCD."
			del(A)

	proc/use_ammo(amt)
		if(ammo < amt)
			return 0
		ammo -= amt
		return 1

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(mode == MODE_DECONSTRUCT)
			if(isturf(target))
				if(istype(target, /turf/simulated/r_wall))
					user << "\red Downgrading wall..."
					sleep(20)
					if(!use_ammo(5)) return
					new /turf/simulated/wall(target)
					create_sparks(loc, 5)
				else if(istype(target, /turf/simulated/wall))
					user << "\red Deconstructing wall..."
					sleep(20)
					if(!use_ammo(3)) return
					new /turf/simulated/floor(target)
					create_sparks(loc, 5)
				else if(istype(target, /turf/simulated/floor))
					user << "\red Deconstructing floor..."
					sleep(20)
					if(!use_ammo(1)) return
					new /turf/space(target)
					create_sparks(loc, 5)
				target.buildlinks()
			else if(istype(target, /obj/machinery/door/airlock))
				user << "\red Deconstructing airlock..."
				sleep(20)
				if(!use_ammo(5)) return
				del(target)
				create_sparks(loc, 5)
		else if(mode == MODE_CONSTRUCT)
			if(istype(target, /turf/space))
				user << "\red Constructing floor..."
				sleep(20)
				if(!use_ammo(1)) return
				new /turf/simulated/floor(target)
				target.buildlinks()
				create_sparks(loc, 5)
			else if(istype(target, /turf/simulated/floor))
				user << "\red Constructing wall..."
				sleep(20)
				if(!use_ammo(3)) return
				new /turf/simulated/wall(target)
				target.buildlinks()
				create_sparks(loc, 5)
			else if(istype(target, /turf/simulated/wall))
				user << "\red Upgrading wall..."
				sleep(20)
				if(!use_ammo(5)) return
				new /turf/simulated/r_wall(target)
				target.buildlinks()
				create_sparks(loc, 5)
		else if(mode == MODE_AIRLOCK)
			if(istype(target, /turf/simulated/floor))
				user << "\red Constructing airlock..."
				sleep(20)
				if(!use_ammo(5)) return
				new /obj/machinery/door/airlock(target)
				create_sparks(loc, 5)

/obj/item/rcd_ammo
	icon = 'icons/immibis/rcd.dmi'
	icon_state = "ammo"

	name = "compressed matter cartridge"
	desc = "Used for reloading Rapid Construction Devices."