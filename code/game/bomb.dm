/obj/bomb/New()
	..()

	switch (src.btype)
		// radio
		if (0)
			var/obj/item/assembly/r_i_ptank/R = new /obj/item/assembly/r_i_ptank(src.loc)
			var/obj/item/tank/plasma/p3 = new /obj/item/tank/plasma(R)
			var/obj/item/radio/signaler/p1 = new /obj/item/radio/signaler(R)
			var/obj/item/igniter/p2 = new /obj/item/igniter(R)
			R.part1 = p1
			R.part2 = p2
			R.part3 = p3
			p1.master = R
			p2.master = R
			p3.master = R
			R.status = explosive
			p1.b_stat = 0
			p2.status = 1
			p3.gas.temperature = btemp + T0C

		// proximity
		if (1)
			var/obj/item/assembly/m_i_ptank/R = new /obj/item/assembly/m_i_ptank(src.loc)
			var/obj/item/tank/plasma/p3 = new /obj/item/tank/plasma(R)
			var/obj/item/prox_sensor/p1 = new /obj/item/prox_sensor(R)
			var/obj/item/igniter/p2 = new /obj/item/igniter(R)
			R.part1 = p1
			R.part2 = p2
			R.part3 = p3
			p1.master = R
			p2.master = R
			p3.master = R
			R.status = explosive

			p3.gas.temperature = btemp +T0C
			p2.status = 1

			if(src.active)
				R.part1.state = 1
				R.part1.icon_state = text("motion[]", 1)
				R.c_state(1, src)

		// timer
		if (2)
			var/obj/item/assembly/t_i_ptank/R = new /obj/item/assembly/t_i_ptank(src.loc)
			var/obj/item/tank/plasma/p3 = new /obj/item/tank/plasma(R)
			var/obj/item/timer/p1 = new /obj/item/timer(R)
			var/obj/item/igniter/p2 = new /obj/item/igniter(R)
			R.part1 = p1
			R.part2 = p2
			R.part3 = p3
			p1.master = R
			p2.master = R
			p3.master = R
			R.status = explosive

			p3.gas.temperature = btemp +T0C
			p2.status = 1

	del(src)