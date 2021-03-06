
/obj/machinery/computer/sleep_console/New()
	..()
	spawn( 5 )
		src.connected = locate(/obj/machinery/sleeper, get_step(src, WEST))
		return
	return

/obj/machinery/computer/sleep_console/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/sleep_console/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/sleep_console/attack_hand(mob/user as mob)
	if(..())
		return
	if (src.connected)
		var/mob/occupant = src.connected.occupant
		var/dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
		if (occupant)
			var/t1
			switch(occupant.stat)
				if(0)
					t1 = "Conscious"
				if(1)
					t1 = "Unconscious"
				if(2)
					t1 = "*dead*"
				else
			dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
			dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.bruteloss < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.bruteloss)
			dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.oxyloss < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.oxyloss)
			dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.toxloss < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.toxloss)
			dat += text("[]\t-Burn Severity %: []</FONT><BR>", (occupant.fireloss < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.fireloss)
			dat += text("<BR>Paralysis Summary %: [] ([] seconds left!)</FONT><BR>", occupant.paralysis, round(occupant.paralysis / 4))
			dat += text("<HR><A href='?src=\ref[];refresh=1'>Refresh</A><BR><A href='?src=\ref[];rejuv=1'>Inject Rejuvenators</A>", src, src)
		else
			dat += "The sleeper is empty."
		dat += text("<BR><BR><A href='?src=\ref[];mach_close=sleeper'>Close</A>", user)
		user << browse(dat, "window=sleeper;size=400x500")
	return

/obj/machinery/computer/sleep_console/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (get_dist(src, usr) <= 1 && istype(src.loc, /turf))) || (istype(usr, /mob/ai)))
		usr.machine = src
		if (href_list["rejuv"])
			if (src.connected)
				src.connected.inject(usr)
		if (href_list["refresh"])
			src.updateUsrDialog()
		src.add_fingerprint(usr)
	return

/obj/machinery/computer/sleep_console/process()
	if(stat & (NOPOWER|BROKEN))
		return
	src.updateUsrDialog()
	return

/obj/machinery/computer/sleep_console/power_change()
	// no change - sleeper works without power (you just can't inject more)
	return

/obj/machinery/atmospherics/unary/freezer
	name = "Freezer"
	icon = 'icons/goonstation/machinery/freezer.dmi'
	icon_state = "freezer_0"
	density = 1
	var/connector = null
	var/c_used = 1.0
	var/status = 0.0
	var/t_flags = 3.0
	var/transfer = 0.0
	var/temperature = 60.0+T0C

	p_dir = 4.0
	anchored = 1.0
	capmult = 1

	attackby(obj/item/flasks/F as obj, mob/user as mob)
		if (!( istype(F, /obj/item/flasks) ))
			return
		if (src.contents.len >= 3)
			user << "\blue All slots are full!"
		else
			user.drop_item()
			F.loc = src
			src.rebuild_overlay()

	proc/rebuild_overlay()
		src.overlays = null
		src.overlays += src.connector
		var/counter = 0
		for(var/obj/item/flasks/F in src.contents)
			var/obj/overlay/O = new /obj/overlay(  )
			O.icon = F.icon
			O.icon_state = F.icon_state
			O.pixel_y = -17.0
			O.pixel_x = counter * 12
			src.overlays += O
			counter++
			if(counter>3)	break

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(..())
			return
		user.machine = src

		if(istype(user, /mob/monkey))
			var/d1 = null
			if (locate(/obj/item/flasks, src))
				var/counter = 1
				for(var/obj/item/flasks/F in src)
					d1 += text("<A href = '?src=\ref[];flask=[]'><B>[] []</B></A>: []<BR>", src, counter, stars("Flask"), counter, stars(text("[] / [] / []", F.oxygen, F.plasma, F.coolant)))
					counter++
				d1 += "Key:    Oxygen / Plasma / Coolant<BR>"
			else
				d1 = "<B>No flasks!</B>"
			var/t1 = null
			switch(src.t_flags)
				if(0.0)
					t1 = text("<A href = '?src=\ref[];oxygen=1'>[]</A> <A href = '?src=\ref[];plasma=1'>[]</A>", src, stars("Oxygen-No"), src, stars("Plasma-No"))
				if(1.0)
					t1 = text("<A href = '?src=\ref[];oxygen=0'>[]</A> <A href = '?src=\ref[];plasma=1'>[]</A>", src, stars("Oxygen-Yes"), src, stars("Plasma-No"))
				if(2.0)
					t1 = text("<A href = '?src=\ref[];oxygen=1'>[]</A> <A href = '?src=\ref[];plasma=0'>[]</A>", src, stars("Oxygen-No"), src, stars("Plasma-Yes"))
				if(3.0)
					t1 = text("<A href = '?src=\ref[];oxygen=0'>[]</A> <A href = '?src=\ref[];plasma=0'>[]</A>", src, stars("Oxygen-Yes"), src, stars("Plasma-Yes"))
				else
			var/t2 = null
			if (src.status)
				t2 = text("Cooling-[] <A href = '?src=\ref[];cool=0'>[]</A>", src.c_used, src, stars("Stop"))
			else
				t2 = text("<A href = '?src=\ref[];cool=1'>Cool</A> []", src, stars("Stopped"))
			var/dat = text("<HTML><HEAD></HEAD><BODY><TT><BR>\n\t\t<B>[]</B>: []<BR>\n\t\t<B>[]</B>: []<BR>\n\t\t   <B>[]</B>: []<BR>\n\t\t<B>[]</B>: []<BR>\n\t\t   <A href='?src=\ref[];cp=-5'>-</A> <A href='?src=\ref[];cp=-1'>-</A> [] <A href='?src=\ref[];cp=1'>+</A> <A href='?src=\ref[];cp=5'>+</A><BR>\n<BR>\n\t[]<BR>\n<BR>\n<BR>\n\t<A href='?src=\ref[];mach_close=freezer'>Close</A>\n\t</TT></BODY></HTML>", stars("Temperature"), src.temperature-T0C, stars("Transfer Status"), (src.transfer ? text("Transfering <A href='?src=\ref[];transfer=0'>Stop</A>", src) : text("<A href='?src=\ref[];transfer=1'>Transfer</A> Stopped", src)), stars("Chemicals Used"), t1, stars("Freezer status"), t2, src, src, src.c_used, src, src, d1, user)
			user << browse(dat, "window=freezer;size=400x500")
		else
			var/d1
			if (locate(/obj/item/flasks, src))
				var/counter = 1

				for(var/obj/item/flasks/F in src)
					d1 += text("<A href = '?src=\ref[];flask=[]'><B>Flask []</B></A>: [] / [] / []<BR>", src, counter, counter, F.oxygen, F.plasma, F.coolant)
					counter++
				d1 += "Key:    Oxygen / Plasma / Coolant<BR>"
			else
				d1 = "<B>No flasks!</B>"
			var/t1 = null
			switch(src.t_flags)
				if(0.0)
					t1 = text("<A href = '?src=\ref[];oxygen=1'>Oxygen-No</A> <A href = '?src=\ref[];plasma=1'>Plasma-No</A>", src, src)
				if(1.0)
					t1 = text("<A href = '?src=\ref[];oxygen=0'>Oxygen-Yes</A> <A href = '?src=\ref[];plasma=1'>Plasma-No</A>", src, src)
				if(2.0)
					t1 = text("<A href = '?src=\ref[];oxygen=1'>Oxygen-No</A> <A href = '?src=\ref[];plasma=0'>Plasma-Yes</A>", src, src)
				if(3.0)
					t1 = text("<A href = '?src=\ref[];oxygen=0'>Oxygen-Yes</A> <A href = '?src=\ref[];plasma=0'>Plasma-Yes</A>", src, src)
				else
			var/t2 = null
			if (src.status)
				t2 = text("Cooling-[] <A href = '?src=\ref[];cool=0'>Stop</A>", src.c_used, src)
			else
				t2 = text("<A href = '?src=\ref[];cool=1'>Cool</A> Stopped", src)
			var/dat = text("<HTML><HEAD></HEAD><BODY><TT><BR>\n\t\t<B>Temperature</B>: []<BR>\n\t\t<B>Transfer Status</B>: []<BR>\n\t\t   <B>Chemicals Used</B>: []<BR>\n\t\t<B>Freezer status</B>: []<BR>\n\t\t   <A href='?src=\ref[];cp=-5'>-</A> <A href='?src=\ref[];cp=-1'>-</A> [] <A href='?src=\ref[];cp=1'>+</A> <A href='?src=\ref[];cp=5'>+</A><BR>\n<BR>\n\t[]<BR>\n<BR>\n<BR>\n\t<A href='?src=\ref[];mach_close=freezer'>Close</A><BR>\n\t</TT></BODY></HTML>", src.temperature-T0C, (src.transfer ? text("Transfering <A href='?src=\ref[];transfer=0'>Stop</A>", src) : text("<A href='?src=\ref[];transfer=1'>Transfer</A> Stopped", src)), t1, t2, src, src, src.c_used, src, src, d1, user)
			user << browse(dat, "window=freezer;size=400x500")

	Topic(href, href_list)
		if(..())
			return
		if ((usr.contents.Find(src) || (get_dist(src, usr) <= 1 && istype(src.loc, /turf))) || (istype(usr, /mob/ai)))
			usr.machine = src
			if (href_list["cp"])
				var/cp = text2num(href_list["cp"])
				src.c_used += cp
				src.c_used = min(max(round(src.c_used), 0), 10)
			if (href_list["oxygen"])
				var/t1 = text2num(href_list["oxygen"])
				if (t1)
					src.t_flags |= 1
				else
					src.t_flags &= 65534
			if (href_list["plasma"])
				var/t1 = text2num(href_list["plasma"])
				if (t1)
					src.t_flags |= 2
				else
					src.t_flags &= 65533
			if (href_list["cool"])
				src.status = text2num(href_list["cool"])
				src.icon_state = text("freezer_[]", src.status)
			if (href_list["transfer"])
				src.transfer = text2num(href_list["transfer"])
			if (href_list["flask"])
				var/t1 = text2num(href_list["flask"])
				if (t1 <= src.contents.len)
					var/obj/F = src.contents[t1]
					F.loc = src.loc
					src.rebuild_overlay()
		src.add_fingerprint(usr)

	power_change()
		..()
		if(stat & NOPOWER)
			icon_state = "freezer_0"
		else
			src.icon_state = "freezer_[status]"

	process()
		if(stat & (BROKEN|NOPOWER))
			return

		use_power(CRYO_FREEZER_POWER)

		var/obj/item/flasks/F1
		var/obj/item/flasks/F2
		var/obj/item/flasks/F3
		if (src.contents.len >= 3)
			F3 = src.contents[3]
		if (src.contents.len >= 2)
			F2 = src.contents[2]
		if (src.contents.len >= 1)
			F1 = src.contents[1]
		var/u_cool = 0
		if (src.status)
			u_cool = src.c_used
			if ((F2 && F2.coolant))
				if (F2.coolant >= u_cool)
					F2.coolant -= u_cool
				else
					u_cool = F2.coolant
					F2.coolant = 0
			else
				if ((F1 && F1.coolant))
					if (F1.coolant >= u_cool)
						F1.coolant -= u_cool
					else
						u_cool = F1.coolant
						F1.coolant = 0
				else
					if ((F3 && F3.coolant))
						if (F3.coolant >= u_cool)
							F3.coolant -= u_cool
						else
							u_cool = F3.coolant
							F3.coolant = 0
					else
						u_cool = 0
		if (u_cool)
			src.temperature = max((-100.0+T0C), src.temperature - (u_cool * 5) )
			use_power(CRYO_FREEZER_COOLING_POWER)

		src.temperature = min(src.temperature + 5, 20+T0C)
		if (src.transfer)
			var/u_oxy = 0
			var/u_pla = 0
			if (src.t_flags & 1)
				u_oxy = 1
				if ((F1 && F1.oxygen))
					if (F1.oxygen >= u_oxy)
						F1.oxygen -= u_oxy
					else
						u_oxy = F1.oxygen
						F1.oxygen = 0
				else
					if ((F2 && F2.oxygen))
						if (F2.oxygen >= u_oxy)
							F2.oxygen -= u_oxy
						else
							u_oxy = F2.oxygen
							F2.oxygen = 0
					else
						if ((F3 && F3.oxygen))
							if (F3.oxygen >= u_oxy)
								F3.oxygen -= u_oxy
							else
								u_oxy = F3.oxygen
								F3.oxygen = 0
						else
							u_oxy = 0
			if (src.t_flags & 2)
				u_pla = 1
				if ((F3 && F3.plasma))
					if (F3.plasma >= u_pla)
						F3.plasma -= u_pla
					else
						u_pla = F3.plasma
						F3.plasma = 0
				else
					if ((F2 && F2.plasma))
						if (F2.plasma >= u_pla)
							F2.plasma -= u_pla
						else
							u_pla = F2.plasma
							F2.plasma = 0
					else
						if ((F1 && F1.plasma))
							if (F1.plasma >= u_pla)
								F1.plasma -= u_pla
							else
								u_pla = F1.plasma
								F1.plasma = 0
						else
							u_pla = 0
				if ( (u_oxy + u_pla) > 0)
					gas.o2 += u_oxy
					gas.plasma += u_pla
					gas.temperature = src.temperature

		src.updateUsrDialog()


	New()
		. = ..()
		var/obj/overlay/O1 = new /obj/overlay(  )
		O1.icon = 'icons/goonstation/cryoflasks.dmi'
		O1.icon_state = "canister connector_0"
		O1.pixel_y = -16.0
		src.overlays += O1
		src.connector = O1
		new /obj/item/flasks/oxygen( src )
		new /obj/item/flasks/coolant( src )
		new /obj/item/flasks/plasma( src )
		rebuild_overlay()


/obj/machinery/sleeper/process()
	src.updateDialog()
	return

/obj/machinery/sleeper/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
	return

/obj/machinery/sleeper/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
			A.blob_act()
		del(src)
	return

/obj/machinery/sleeper/verb/eject()
	set src in oview(1)

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/sleeper/verb/move_inside()
	set src in oview(1)

	if (usr.stat != 0)
		return
	if (src.occupant)
		usr << "\blue <B>The sleeper is already occupied!</B>"
		return
	if (usr.abiotic())
		usr << "Subject may not have abiotic items on."
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	src.icon_state = "sleeper_1"
	for(var/obj/O in src)
		del(O)
	src.add_fingerprint(usr)
	return

/obj/machinery/sleeper/attackby(obj/item/grab/G as obj, mob/user as mob)
	if ((!( istype(G, /obj/item/grab) ) || !( ismob(G.affecting) )))
		return
	if (src.occupant)
		user << "\blue <B>The sleeper is already occupied!</B>"
		return
	if (G.affecting.abiotic())
		user << "Subject may not have abiotic items on."
		return
	var/mob/M = G.affecting
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src
	src.occupant = M
	src.icon_state = "sleeper_1"
	for(var/obj/O in src)
		O.loc = src.loc
	src.add_fingerprint(user)
	//G = null
	del(G)
	return

/obj/machinery/sleeper/proc/go_out()
	if (!src.occupant)
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	src.icon_state = "sleeper_0"
	return

/obj/machinery/sleeper/proc/inject(mob/user as mob)
	if (src.occupant)
		if (src.occupant.rejuv < 60)
			src.occupant.rejuv = 60
		user << text("Occupant now has [] units of rejuvenation in his/her bloodstream.", src.occupant.rejuv)
	else
		user << "No occupant!"
	return

/obj/machinery/sleeper/proc/check(mob/user as mob)
	if (src.occupant)
		user << text("\blue <B>Occupant ([]) Statistics:</B>", src.occupant)
		var/t1
		switch(src.occupant.stat)
			if(0.0)
				t1 = "Conscious"
			if(1.0)
				t1 = "Unconscious"
			if(2.0)
				t1 = "*dead*"
			else
		user << text("[]\t Health %: [] ([])", (src.occupant.health > 50 ? "\blue " : "\red "), src.occupant.health, t1)
		user << text("[]\t -Core Temperature: []&deg;C ([]&deg;F)</FONT><BR>", (src.occupant.bodytemperature > 50 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.bodytemperature-T0C, src.occupant.bodytemperature*1.8-459.67)
		user << text("[]\t -Brute Damage %: []", (src.occupant.bruteloss < 60 ? "\blue " : "\red "), src.occupant.bruteloss)
		user << text("[]\t -Respiratory Damage %: []", (src.occupant.oxyloss < 60 ? "\blue " : "\red "), src.occupant.oxyloss)
		user << text("[]\t -Toxin Content %: []", (src.occupant.toxloss < 60 ? "\blue " : "\red "), src.occupant.toxloss)
		user << text("[]\t -Burn Severity %: []", (src.occupant.fireloss < 60 ? "\blue " : "\red "), src.occupant.fireloss)
		user << "\blue Expected time till occupant can safely awake: (note: If health is below 20% these times are inaccurate)"
		user << text("\blue \t [] second\s (if around 1 or 2 the sleeper is keeping them asleep.)", src.occupant.paralysis / 5)
	else
		user << "\blue There is no one inside!"
	return

/obj/machinery/sleeper/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		else
	return

/obj/machinery/sleeper/alter_health(mob/M as mob)
	if (M.health > 0)
		if (M.oxyloss >= 10)
			var/amount = max(0.15, 1)
			M.oxyloss -= amount
		else
			M.oxyloss = 0
		M.updatehealth()
	M.paralysis -= 4
	M.weakened -= 4
	M.stunned -= 4
	if (M.paralysis <= 1)
		M.paralysis = 3
	if (M.weakened <= 1)
		M.weakened = 3
	if (M.stunned <= 1)
		M.stunned = 3
	if (M.rejuv < 3)
		M.rejuv = 4
	return

/obj/machinery/cryo_cell
	parent_type = /obj/machinery/atmospherics/unary
	name = "cryo cell"
	icon = 'icons/goonstation/machinery/cryocell.dmi'
	icon_state = "celltop"
	density = 1
	var/mob/occupant = null
	anchored = 1.0
	p_dir = 8.0
	capmult = 1

	var/obj/overlay/O1 = null
	var/obj/overlay/O2 = null

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					for(var/x in src.verbs)
						src.verbs -= x
					src.icon_state = "broken"
			else
		return

	blob_act()
		if(prob(75))
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				A.blob_act()
			src.icon_state = "broken"

	New()
		..()
		src.layer = 5
		O1 = new /obj/overlay(  )
		O1.icon = 'icons/goonstation/machinery/cryocell.dmi'
		O1.icon_state = "cellconsole"
		O1.pixel_y = -32.0
		O1.layer = 4

		O2 = new /obj/overlay(  )
		O2.icon = 'icons/goonstation/machinery/cryocell.dmi'
		O2.icon_state = "cellbottom"
		O2.pixel_y = -32.0
		src.pixel_y = 32

		add_overlays()

	proc/add_overlays()
		src.overlays = list(O1, O2)

	power_change()
		..()
		if(stat & NOPOWER)
			icon_state = "celltop-p"
			O1.icon_state="cellconsole-p"
			O2.icon_state="cellbottom-p"
		else
			icon_state = "celltop[ occupant ? "_1" : ""]"
			O1.icon_state ="cellconsole"
			O2.icon_state ="cellbottom"

		add_overlays()

	process()
		if(stat & NOPOWER)
			return

		use_power(CRYO_CELL_POWER)
		src.updateUsrDialog()
		return

	verb/move_eject()
		set src in oview(1)
		if (usr.stat != 0)
			return
		src.go_out()
		add_fingerprint(usr)
		return

	verb/move_inside()
		set src in oview(1)
		if (usr.stat != 0 || stat & (NOPOWER|BROKEN))
			return
		if (src.occupant)
			usr << "\blue <B>The cell is already occupied!</B>"
			return
		if (usr.abiotic())
			usr << "Subject may not have abiotic items on."
			return
		usr.pulling = null
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
		src.occupant = usr
		src.icon_state = "celltop_1"
		for(var/obj/O in src)
			O.loc = src.loc
		src.add_fingerprint(usr)
		return

	attackby(obj/item/grab/G as obj, mob/user as mob)
		if (stat & (BROKEN|NOPOWER))
			return
		if ((!( istype(G, /obj/item/grab) ) || !( ismob(G.affecting) )))
			return
		if (src.occupant)
			user << "\blue <B>The cell is already occupied!</B>"
			return
		if (G.affecting.abiotic())
			user << "Subject may not have abiotic items on."
			return
		var/mob/M = G.affecting
		if (M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		src.occupant = M
		src.icon_state = "celltop_1"
		for(var/obj/O in src)
			del(O)
		src.add_fingerprint(user)
		del(G)
		return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(..())
			return
		user.machine = src
		if(istype(user, /mob/human) || istype(user, /mob/ai))
			var/dat = "<font color='blue'> <B>System Statistics:</B></FONT><BR>"
			if (src.gas.temperature > T0C)
				dat += text("<font color='red'>\tTemperature (&deg;C): [] (MUST be below 0, add coolant to mixture)</FONT><BR>", round(src.gas.temperature-T0C, 0.1))
			else
				dat += text("<font color='blue'>\tTemperature (&deg;C): [] </FONT><BR>", round(src.gas.temperature-T0C, 0.1))
			if (src.gas.plasma < 1)
				dat += text("<font color='red'>\tPlasma Units: [] (Add plasma to mixture!)</FONT><BR>", round(src.gas.plasma, 0.1))
			else
				dat += text("<font color='blue'>\tPlasma Units: []</FONT><BR>", round(src.gas.plasma, 0.1))
			if (src.gas.o2 < 1)
				dat += text("<font color='red'>\tOxygen Units: [] (Add oxygen to mixture!)</FONT><BR>", round(src.gas.o2, 0.1))
			else
				dat += text("<font color='blue'>\tOxygen Units: []</FONT><BR>", round(src.gas.o2, 0.1))
			if (src.occupant)
				dat += text("<BR><font color='blue'><B>Occupant Statistics:</B></FONT><BR>")
				var/t1
				switch(src.occupant.stat)
					if(0.0)
						t1 = "Conscious"
					if(1.0)
						t1 = "Unconscious"
					if(2.0)
						t1 = "*dead*"
					else
				dat += text("[]\tHealth %: [] ([])</FONT><BR>", (src.occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.health, t1)
				dat += text("[]\t-Core Temperature: []&deg;C ([]&deg;F)</FONT><BR>", (src.occupant.bodytemperature > 50 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.bodytemperature-T0C, src.occupant.bodytemperature*1.8-459.67)
				dat += text("[]\t-Brute Damage %: []</FONT><BR>", (src.occupant.bruteloss < 60 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.bruteloss)
				dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (src.occupant.oxyloss < 60 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.oxyloss)
				dat += text("[]\t-Toxin Content %: []</FONT><BR>", (src.occupant.toxloss < 60 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.toxloss)
				dat += text("[]\t-Burn Severity %: []</FONT>", (src.occupant.fireloss < 60 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.fireloss)
				if(istype(src.occupant, /mob/human))
					dat += text("<BR><font color='blue'><B>Detailed Occupant Statistics:</B></FONT><BR>")
					var/mob/human/H = src.occupant
					for(var/A in H.organs)
						var/obj/item/organ/external/current = H.organs[A]
						var/organstatus = 100
						if(current.get_damage())
							organstatus = 100*(current.get_damage()/current.max_damage)
						dat += text("[]\t-[]: []% (Brute: [] Fire: [])<BR>",(organstatus > 60 ? "<font color='blue'>" : "<font color='red'>"), capitalize(A), round(organstatus, 0.1), current.brute_dam, current.burn_dam)

			dat += text("<BR><BR><A href = '?src=\ref[];drain=1'>Drain Cryocell</A> <A href='?src=\ref[];mach_close=cryo'>Close</A>", user, user)
			user << browse(dat, "window=cryo;size=400x565")
		else
			var/dat = text("<font color='blue'> <B>[]</B></FONT><BR>", stars("System Statistics:"))
			if (src.gas.temperature > T0C)
				dat += text("<font color='red'>\t[]</FONT><BR>", stars(text("Temperature (C): [] (MUST be below 0, add coolant to mixture)", round(src.gas.temperature-T0C, 0.1))))
			else
				dat += text("<font color='blue'>\t[] </FONT><BR>", stars(text("Temperature(C): []", round(src.gas.temperature-T0C, 0.1))))
			if (src.gas.plasma < 1)
				dat += text("<font color='red'>\t[]</FONT><BR>", stars(text("Plasma Units: [] (Add plasma to mixture!)", round(src.gas.plasma, 0.1))))
			else
				dat += text("<font color='blue'>\t[]</FONT><BR>", stars(text("Plasma Units: []", round(src.gas.plasma, 0.1))))
			if (src.gas.o2 < 1)
				dat += text("<font color='red'>\t[]</FONT><BR>", stars(text("Oxygen Units: [] (Add oxygen to mixture!)", round(src.gas.o2, 0.1))))
			else
				dat += text("<font color='blue'>\t[]</FONT><BR>", stars(text("Oxygen Units: []", round(src.gas.o2, 0.1))))
			if (src.occupant)
				dat += text("<BR><font color='blue'><B>[]:</B></FONT><BR>", stars("Occupant Statistics"))
				var/t1 = null
				switch(src.occupant.stat)
					if(0.0)
						t1 = "Conscious"
					if(1.0)
						t1 = "Unconscious"
					if(2.0)
						t1 = "*dead*"
					else
				dat += text("[]\t[]</FONT><BR>", (src.occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), stars(text("Health %: [] ([])", src.occupant.health, t1)))
				dat += text("[]\t[]</FONT><BR>", (src.occupant.bruteloss < 60 ? "<font color='blue'>" : "<font color='red'>"), stars(text("-Brute Damage %: []", src.occupant.bruteloss)))
				dat += text("[]\t[]</FONT><BR>", (src.occupant.oxyloss < 60 ? "<font color='blue'>" : "<font color='red'>"), stars(text("-Respiratory Damage %: []", src.occupant.oxyloss)))
				dat += text("[]\t[]</FONT><BR>", (src.occupant.toxloss < 60 ? "<font color='blue'>" : "<font color='red'>"), stars(text("-Toxin Content %: []", src.occupant.toxloss)))
				dat += text("[]\t[]</FONT>", (src.occupant.fireloss < 60 ? "<font color='blue'>" : "<font color='red'>"), stars(text("-Burn Severity %: []", src.occupant.fireloss)))
				if(istype(src.occupant, /mob/human))
					dat += text("<BR><font color='blue'><BR>[]:</B></FONT><BR>", stars("Detailed Occupant Statistics"))
					var/mob/human/H = src.occupant
					for(var/A in H.organs)
						var/obj/item/organ/external/current = H.organs[A]
						var/organstatus = 100
						if(current.get_damage())
							organstatus = 100*(current.max_damage/current.get_damage())
						dat += text("[]\t-[]: []% ([stars("Brute")]: [] [stars("Fire")]: [])<BR>",(organstatus > 60 ? "<font color='blue'>" : "<font color='red'>"), stars(capitalize(A)), round(organstatus, 0.1), current.brute_dam, current.burn_dam)
			dat += text("<BR><BR><A href = '?src=\ref[];drain=1'>Drain Cryocell</A> <A href='?src=\ref[];mach_close=cryo'>Close</A>", user, user)
			user << browse(dat, "window=cryo;size=400x565")
		return

	Topic(href, href_list)
		if(..())
			return
		if ((usr.contents.Find(src) || (get_dist(src, usr) <= 1 && istype(src.loc, /turf))) || (istype(usr, /mob/ai)))
			usr.machine = src
			if (href_list["drain"])
				world << "Immibis really needs to fix the Drain option on cryo-cells. This chat window message should make everyone hate him until he does. Thank you for listening to this NanoTrasen Chat Window Message (TM)."
			src.add_fingerprint(usr)

		else
			usr << "User too far?"
		return

	proc/go_out()
		if(!( src.occupant ))
			return
		for(var/obj/O in src)
			O.loc = src.loc
		if (src.occupant.client)
			src.occupant.client.eye = src.occupant.client.mob
			src.occupant.client.perspective = MOB_PERSPECTIVE
		src.occupant.loc = src.loc
		src.occupant = null
		src.icon_state = "celltop"
		return

	relaymove(mob/user as mob)
		if(user.stat)
			return
		src.go_out()
		return

	alter_health(mob/M as mob)
		if(stat & NOPOWER)
			return

		M.bodytemperature = M.adjustBodyTemp(M.bodytemperature, src.gas.temperature, 1.0)
		if (M.health < 0)
			if ((src.gas.temperature > T0C || src.gas.plasma < 1))
				return
		if (M.stat == 2)
			return
		if (src.gas.o2 >= 1)
			src.gas.o2--
			if (M.oxyloss >= 10)
				var/amount = max(0.15, 2)
				M.oxyloss -= amount
			else
				M.oxyloss = 0
			M.updatehealth()
		if ((src.gas.temperature < T0C && src.gas.plasma >= 1))
			src.gas.plasma--
			if (M.toxloss > 5)
				var/amount = max(0.1, 2)
				M.toxloss -= amount
			else
				M.toxloss = 0
			M.updatehealth()
			if (istype(M, /mob/human))
				var/mob/human/H = M
				var/ok = 0
				for(var/organ in H.organs)
					var/obj/item/organ/external/affecting = H.organs[text("[]", organ)]
					ok += affecting.heal_damage(5, 5)
				if (ok)
					H.UpdateDamageIcon()
				else
					H.UpdateDamage()
			else
				if (M.fireloss > 15)
					var/amount = max(0.3, 2)
					M.fireloss -= amount
				else
					M.fireloss = 0
				if (M.bruteloss > 10)
					var/amount = max(0.3, 2)
					M.bruteloss -= amount
				else
					M.bruteloss = 0
			M.updatehealth()
			M.paralysis += 5
		if (src.gas.temperature < (60+T0C))
			src.gas.temperature = min(src.gas.temperature + 1, 60+T0C)
		src.updateUsrDialog()
		return

/obj/item/flasks/examine()
	set src in oview(1)
	usr << text("The flask is []% full", (src.oxygen + src.plasma + src.coolant) * 100 / 500)
	usr << "The flask can ONLY store liquids."
	return

/mob/human/abiotic()
	if ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.w_radio || src.glasses || src.ears || src.gloves))
		return 1
	else
		return 0
	return

/mob/proc/abiotic()
	if ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || src.back || src.wear_mask)
		return 1
	else
		return 0
	return

/datum/data/function/proc/reset()
	return

/datum/data/function/proc/r_input(href, href_list, mob/user as mob)
	return

/datum/data/function/proc/display()
	return