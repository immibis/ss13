obj/bomb/New()
	. = ..()

	var/obj/item/assembly/bomb/B = new(loc)
	B.attackby(new/obj/item/tank/plasma)
	B.attackby(new/obj/item/igniter)

	B.PT.gas.temperature = btemp + T0C

	switch (src.btype)
		// radio
		if (0)
			B.attackby(new/obj/item/trigger/radio)

		// proximity
		if (1)
			B.attackby(new/obj/item/trigger/proximity)

			if(active)
				var/obj/item/trigger/proximity/P = B.TR
				P.state = 1
				P.c_state(1)

		// timer
		if (2)
			B.attackby(new/obj/item/trigger/timer)

	del(src)