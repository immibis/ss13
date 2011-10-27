/obj/machinery/power/solar/New()
	..()
	spawn(10)
		updateicon()
		updatefrac()

		if(powernet)
			for(var/obj/machinery/power/solar_control/SC in powernet.nodes)
				if(SC.id == id)
					control = SC

/obj/machinery/power/solar/attackby(obj/item/W, mob/user)
	..()
	src.add_fingerprint(user)
	src.health -= W.force
	src.healthcheck()
	return

/obj/machinery/power/solar/blob_act()
	src.health--
	src.healthcheck()
	return

/obj/machinery/power/solar/proc/healthcheck()
	if (src.health <= 0)
		if(!(stat & BROKEN))
			broken()
		else
			new /obj/item/shard(src.loc)
			new /obj/item/shard(src.loc)
			del(src)
			return
	return

/obj/machinery/power/solar/proc/updateicon()
	overlays = null
	if(stat & BROKEN)
		overlays += image('icons/immibis/power.dmi', icon_state = "solar_panel-b", layer = FLY_LAYER)
	else
		overlays += image('icons/immibis/power.dmi', icon_state = "solar_panel", layer = FLY_LAYER)
		src.dir = angle2dir(adir)
	return

/obj/machinery/power/solar/proc/updatefrac()
	if(obscured)
		sunfrac = 0
		return

	var/p_angle = abs((360+adir)%360 - (360+sun.angle)%360)
	if(p_angle > 90)			// if facing more than 90deg from sun, zero output
		sunfrac = 0
		return

	sunfrac = cos(p_angle) ** 2

#define SOLARGENRATE 1500

/obj/machinery/power/solar/process()
	if(stat & BROKEN)
		return

	if(!obscured)
		var/sgen = SOLARGENRATE * sunfrac
		add_avail(sgen)
		if(powernet && control)
			if(control in powernet.nodes)
				control.gen += sgen

	if(adir != ndir)
		spawn(10+rand(0,15))
			adir = (360+adir+dd_range(-10,10,ndir-adir))%360
			updateicon()
			updatefrac()

/obj/machinery/power/solar/proc/broken()
	stat |= BROKEN
	updateicon()
	return

/obj/machinery/power/solar/meteorhit()
	if(stat & !BROKEN)
		broken()
	else
		del(src)

/obj/machinery/power/solar/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			if(prob(15))
				new /obj/item/shard( src.loc )
			return
		if(2.0)
			if (prob(50))
				broken()
		if(3.0)
			if (prob(25))
				broken()
	return

/obj/machinery/power/solar/blob_act()
	if(prob(50))
		broken()
		src.density = 0

