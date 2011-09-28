/proc/text2dir(direction)
	switch(uppertext(direction))
		if("NORTH")
			return 1
		if("SOUTH")
			return 2
		if("EAST")
			return 4
		if("WEST")
			return 8
		if("NORTHEAST")
			return 5
		if("NORTHWEST")
			return 9
		if("SOUTHEAST")
			return 6
		if("SOUTHWEST")
			return 10
		else
	return

/proc/get_turf(turf/T as turf)
	while(!istype(T, /turf) && T)
		T = T.loc
	return T

/proc/dir2text(direction)
	switch(direction)
		if(1.0)
			return "north"
		if(2.0)
			return "south"
		if(4.0)
			return "east"
		if(8.0)
			return "west"
		if(5.0)
			return "northeast"
		if(6.0)
			return "southeast"
		if(9.0)
			return "northwest"
		if(10.0)
			return "southwest"
		else
	return

/obj/proc/hear_talk(mob/M as mob, text)
	return

/obj/item/weapon/table_parts/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/weapon/sheet/metal( src.loc )
		//SN src = null
		del(src)

/obj/item/weapon/table_parts/attack_self(mob/user as mob)
	var/state = input(user, "What type of table?", "Assembling Table", null) in list( "sides", "corners", "alone" )
	var/direct = SOUTH
	if (state == "corners")
		direct = input(user, "Direction?", "Assembling Table", null) in list( "northwest", "northeast", "southwest", "southeast" )
	else
		if (state == "sides")
			direct = input(user, "Direction?", "Assembling Table", null) in list( "north", "east", "south", "west" )
	var/obj/table/T = new /obj/table( user.loc )
	T.icon_state = state
	T.dir = text2dir(direct)
	T.add_fingerprint(user)
	del(src)
	return

/obj/item/weapon/rack_parts/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/weapon/sheet/metal( src.loc )
		del(src)
		return
	return

/obj/item/weapon/rack_parts/attack_self(mob/user as mob)
	var/obj/rack/R = new /obj/rack( user.loc )
	R.add_fingerprint(user)
	del(src)
	return

/obj/item/weapon/paper_bin/proc/update()
	src.icon_state = text("paper_bin[]", ((src.amount || locate(/obj/item/weapon/paper, src)) ? "1" : null))
	return

/obj/item/weapon/paper_bin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/paper))
		user.drop_item()
		W.loc = src
	else
		if (istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/T = W
			if ((T.welding && T.weldfuel > 0))
				viewers(user, null) << text("[] burns the paper with the welding tool!", user)
				spawn( 0 )
					src.burn(1800000.0)
					return
		else
			if (istype(W, /obj/item/weapon/igniter))
				viewers(user, null) << text("[] burns the paper with the igniter!", user)
				spawn( 0 )
					src.burn(1800000.0)
					return
	src.update()
	return

/obj/item/weapon/paper_bin/burn(fi_amount)
	flick("paper_binb", src)
	for(var/atom/movable/A as mob|obj in src)
		A.burn(fi_amount)
	if(fi_amount >= 900000.0)
		src.amount = 0
	src.update()
	sleep(11)
	del(src)
	return

/obj/item/weapon/paper_bin/MouseDrop(mob/user as mob)
	if ((user == usr && (!( usr.restrained() ) && (!( usr.stat ) && (usr.contents.Find(src) || get_dist(src, usr) <= 1)))))
		if (usr.hand)
			if (!( usr.l_hand ))
				spawn( 0 )
					src.attack_hand(usr, 1, 1)
					return
		else
			if (!( usr.r_hand ))
				spawn( 0 )
					src.attack_hand(usr, 0, 1)
					return
	return

/obj/item/weapon/paper_bin/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/paper_bin/attack_hand(mob/user as mob, unused, flag)
	if (flag)
		return ..()
	src.add_fingerprint(user)
	if (locate(/obj/item/weapon/paper, src))
		for(var/obj/item/weapon/paper/P in src)
			if ((usr.hand && !( usr.l_hand )))
				usr.l_hand = P
				P.loc = usr
				P.layer = 20
				P = null
				usr.UpdateClothing()
				break
			else if (!usr.r_hand)
				usr.r_hand = P
				P.loc = usr
				P.layer = 20
				P = null
				usr.UpdateClothing()
				break
	else
		if (src.amount >= 1)
			src.amount--
			new /obj/item/weapon/paper( usr.loc )
	src.update()
	return

/obj/item/weapon/paper_bin/examine()
	set src in oview(1)

	src.amount = round(src.amount)
	var/n = src.amount
	for(var/obj/item/weapon/paper/P in src)
		n++
	if (n <= 0)
		n = 0
		usr << "There are no papers in the bin."
	else
		if (n == 1)
			usr << "There is one paper in the bin."
		else
			usr << text("There are [] papers in the bin.", n)
	return

/obj/item/weapon/dummy/ex_act()
	return

/obj/item/weapon/dummy/blob_act()
	return

/obj/item/weapon/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(5))
				del(src)
				return
		else
	return

/obj/item/weapon/blob_act()
	return

//*****RM

/obj/item/weapon/verb/move_to_top()
	set src in oview(1)

	if(!istype(src.loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T


//*****


/obj/item/weapon/proc/attack_self()
	return

/obj/item/weapon/proc/talk_into(mob/M as mob, text)
	return

/obj/item/weapon/proc/moved(mob/user as mob, old_loc as turf)
	return

/obj/item/weapon/proc/dropped(mob/user as mob)
	return

/obj/item/weapon/proc/afterattack()
	return

/obj/item/weapon/proc/attack(mob/M as mob, mob/user as mob, def_zone)
	for(var/mob/O in viewers(M, null))
		O.show_message(text("\red <B>[] has been attacked with [][] </B>", M, src, (user ? text(" by [].", user) : ".")), 1)
	var/power = src.force
//	if (M.health >= -60.0)
	if (istype(M, /mob/human))
		var/mob/human/H = M
		var/obj/item/weapon/organ/external/affecting = H.organs["chest"]
		if (istype(user, /mob/human))
			if (!( def_zone ))
				var/mob/user2 = user
				var/t = user2.zone_sel.selecting
				if ((t in list( "hair", "eyes", "mouth", "neck" )))
					t = "head"
				def_zone = ran_zone(t)
			if (H.organs[text("[]", def_zone)])
				affecting = H.organs[text("[]", def_zone)]
		if (istype(affecting, /obj/item/weapon/organ/external))
			var/b_dam = (src.damtype == "brute" ? src.force : 0)
			var/f_dam = (src.damtype == "fire" ? src.force : 0)
			if (def_zone == "head")
				if ((b_dam && (((H.head && H.head.brute_protect & 1) || (H.wear_mask && H.wear_mask.brute_protect & 1)) && prob(75))))
					if (prob(20))
						affecting.take_damage(power, 0)
					else
						H.show_message("\red You have been protected from a hit to the head.")
					return
				if ((b_dam && prob(src.force + affecting.brute_dam + affecting.burn_dam)))
					var/time = rand(10, 120)
					if (prob(90))
						if (H.paralysis < time)
							H.paralysis = time
					else
						if (H.weakened < time)
							H.weakened = time
					if(H.stat != 2)	H.stat = 1
					for(var/mob/O in viewers(M, null))
						O.show_message(text("\red <B>[] has been knocked unconscious!</B>", H), 1, "\red You hear someone fall.", 2)
					H.show_message(text("\red <B>This was a []% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>", time * 100 / 120))
				affecting.take_damage(b_dam, f_dam)
			else
				if (def_zone == "chest")
					if ((b_dam && (((H.wear_suit && H.wear_suit.brute_protect & 2) || (H.w_uniform && H.w_uniform.brute_protect & 2)) && prob(90 - src.force))))
						H.show_message("\red You have been protected from a hit to the chest.")
						return
					if ((b_dam && prob(src.force + affecting.brute_dam + affecting.burn_dam)))
						if (prob(50))
							if (H.weakened < 5)
								H.weakened = 5
							for(var/mob/O in viewers(H, null))
								O.show_message(text("\red <B>[] has been knocked down!</B>", H), 1, "\red You hear someone fall.", 2)
						else
							if (H.stunned < 2)
								H.stunned = 2
							for(var/mob/O in viewers(H, null))
								O.show_message(text("\red <B>[] has been stunned!</B>", H), 1)
						if(H.stat != 2)	H.stat = 1
					affecting.take_damage(b_dam, f_dam)
				else
					if (def_zone == "diaper")
						if ((b_dam && (((H.wear_suit && H.wear_suit.brute_protect & 4) || (H.w_uniform && H.w_uniform.brute_protect & 4)) && prob(90 - src.force))))
							H.show_message("\red You have been protected from a hit to the lower chest/diaper.")
							return
						if ((b_dam && prob(src.force + affecting.brute_dam + affecting.burn_dam)))
							if (prob(50))
								if (H.weakened < 5)
									H.weakened = 5
								for(var/mob/O in viewers(H, null))
									O.show_message(text("\red <B>[] has been knocked down!</B>", H), 1, "\red You hear someone fall.", 2)
							else
								if (H.stunned < 2)
									H.stunned = 2
								for(var/mob/O in viewers(H, null))
									O.show_message(text("\red <B>[] has been stunned!</B>", H), 1)
							if(H.stat != 2)	H.stat = 1
						affecting.take_damage(b_dam, f_dam)
					else
						affecting.take_damage(b_dam, f_dam)
		H.UpdateDamageIcon()
	else
		switch(src.damtype)
			if("brute")
				M.bruteloss += power
			if("fire")
				M.fireloss += power
		M.updatehealth()
	src.add_fingerprint(user)
	return

/obj/item/weapon/bedsheet/ex_act(severity)
	if (severity <= 2)
		del(src)
		return
	return

/obj/item/weapon/bedsheet/attack_self(mob/user as mob)
	user.drop_item()
	src.layer = 5
	add_fingerprint(user)
	return

/obj/item/weapon/bedsheet/burn(fi_amount)
	if (fi_amount > 3.0E7)
		spawn( 0 )
			var/t = src.icon_state
			src.icon_state = ""
			src.icon = 'icons/ss13/b_items.dmi'
			flick(text("[]", t), src)
			spawn( 14 )
				//SN src = null
				del(src)
				return
			return
	return

/obj/item/weapon/wrapping_paper/examine()
	set src in oview(1)

	..()
	usr << text("There is about [] square units of paper left!", src.amount)
	return

/obj/item/weapon/wrapping_paper/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (!( locate(/obj/table, src.loc) ))
		user << "\blue You MUST put the paper on a table!"
	if (W.w_class < 4)
		if ((istype(user.l_hand, /obj/item/weapon/wirecutters) || istype(user.r_hand, /obj/item/weapon/wirecutters)))
			var/a_used = 2 ** (src.w_class - 1)
			if (src.amount < a_used)
				user << "\blue You need more paper!"
				return
			else
				src.amount -= a_used
				user.drop_item()
				var/obj/item/weapon/gift/G = new /obj/item/weapon/gift( src.loc )
				G.size = W.w_class
				G.w_class = G.size + 1
				G.icon_state = text("gift[]", G.size)
				G.gift = W
				W.loc = G
				G.add_fingerprint(user)
				W.add_fingerprint(user)
				src.add_fingerprint(user)
			if (src.amount <= 0)
				new /obj/item/weapon/c_tube( src.loc )
				//SN src = null
				del(src)
				return
		else
			user << "\blue You need scissors!"
	else
		user << "\blue The object is FAR too large!"
	return

/obj/item/weapon/gift/attack_self(mob/user as mob)
	if(!src.gift)
		user << "\blue The gift was empty!"
		del(src)
	src.gift.loc = user
	if (user.hand)
		user.l_hand = src.gift
	else
		user.r_hand = src.gift
	src.gift.layer = 20
	src.gift.add_fingerprint(user)
	del(src)
	return

/obj/item/weapon/a_gift/ex_act()
	del(src)
	return

/obj/item/weapon/a_gift/burn(fi_amount)
	if (fi_amount > 900000.0)
		del(src)
		return
	return

/obj/item/weapon/a_gift/attack_self(mob/M as mob)
	switch(pick("pill", "flash", "t_gun", "l_gun", "shield", "sword"))
		if("pill")
			var/obj/item/weapon/m_pill/superpill/W = new /obj/item/weapon/m_pill/superpill( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("flash")
			var/obj/item/weapon/flash/W = new /obj/item/weapon/flash( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("l_gun")
			var/obj/item/weapon/gun/energy/laser_gun/W = new /obj/item/weapon/gun/energy/laser_gun( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("t_gun")
			var/obj/item/weapon/gun/energy/taser_gun/W = new /obj/item/weapon/gun/energy/taser_gun( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("shield")
			var/obj/item/weapon/shield/W = new /obj/item/weapon/shield( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("sword")
			var/obj/item/weapon/sword/W = new /obj/item/weapon/sword( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		else
	return

/obj/item/weapon/flashbang/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/screwdriver))
		if (src.det_time == 100)
			src.det_time = 30
			user.show_message("\blue You set the flashbang for 3 second detonation time.")
			src.desc = "It is set to detonate in 3 seconds."
		else
			src.det_time = 100
			user.show_message("\blue You set the flashbang for 10 second detonation time.")
			src.desc = "It is set to detonate in 10 seconds."
		src.add_fingerprint(user)
	return

/obj/item/weapon/flashbang/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (user.equipped() == src)
		if (!( src.state ))
			user << "\red You prime the flashbang! [det_time/10] seconds!"
			src.state = 1
			src.icon_state = "flashbang1"
			spawn( src.det_time )
				prime()
				return
		user.dir = get_dir(user, target)
		user.drop_item()
		var/t = (isturf(target) ? target : target.loc)
		walk_towards(src, t, 3)
		src.add_fingerprint(user)
	return

/obj/item/weapon/flashbang/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/flashbang/attack_hand()
	walk(src, null, null)
	..()
	return

/obj/item/weapon/flashbang/proc/prime()
	var/turf/T = get_turf(src)
	T.firelevel = T.gas.plasma
	for(var/mob/M in viewers(T, null))
		if (locate(/obj/item/weapon/cloaking_device, M))
			for(var/obj/item/weapon/cloaking_device/S in M)
				S.active = 0
				S.icon_state = "shield0"
		if ((get_dist(M, T) <= 2 || src.loc == M.loc || src.loc == M))
			flick("e_flash", M.flash)
			M.stunned = 10
			M.weakened = 3
			M << "\red <B>BANG</B>"
			if ((prob(14) || (M == src.loc && prob(70))))
				M.ear_damage += rand(10, 20)
			else
				if (prob(30))
					M.ear_damage += rand(7, 14)
			if (!( M.paralysis ))
				M.eye_stat += rand(10, 15)
			if (prob(10))
				M.eye_stat += 7
			M.ear_deaf += 30
			if (M == src.loc)
				M.eye_stat += 10
				if (prob(60))
					if (istype(M, /mob/human))
						var/mob/human/H = M
						if (!( istype(H.ears, /obj/item/weapon/clothing/ears/earmuffs) ))
							M.ear_damage += 15
							M.ear_deaf += 60
					else
						M.ear_damage += 15
						M.ear_deaf += 60
		else
			if (get_dist(M, T) <= 5)
				flick("e_flash", M.flash)
				if (!( istype(M, /mob/human) ))
					M.stunned = 7
					M.weakened = 2
				else
					var/mob/human/H = M
					M.ear_deaf += 10
					if (prob(20))
						M.ear_damage += 10
					if ((!( istype(H.glasses, /obj/item/weapon/clothing/glasses/sunglasses) ) || M.paralysis))
						M.stunned = 7
						M.weakened = 2
					else
						if (!( M.paralysis ))
							M.eye_stat += rand(1, 3)
				M << "\red <B>BANG</B>"
			else
				if (!( istype(M, /mob/human) ))
					flick("flash", M.flash)
				else
					var/mob/human/H = M
					if (!( istype(H.glasses, /obj/item/weapon/clothing/glasses/sunglasses) ))
						flick("flash", M.flash)
				M.eye_stat += rand(1, 2)
				M.ear_deaf += 5
				M << "\red <B>BANG</B>"
		if (M.eye_stat >= 20)
			M << "\red Your eyes start to burn badly!"
			M.disabilities |= 1
			if (prob(M.eye_stat - 20 + 1))
				M << "\red You go blind!"
				M.sdisabilities |= 1
		if (M.ear_damage >= 15)
			M << "\red Your ears start to ring badly!"
			if (prob(M.ear_damage - 10 + 5))
				M << "\red You go deaf!"
				M.sdisabilities |= 4
		else
			if (M.ear_damage >= 5)
				M << "\red Your ears start to ring!"

	for(var/obj/blob/B in view(8,T))
		var/damage = round(30/(get_dist(B,T)+1))
		B.health -= damage
		B.update()
	del(src)
	return

/obj/item/weapon/flashbang/attack_self(mob/user as mob)
	if (!src.state)
		user << "\red You prime the flashbang! [det_time/10] seconds!"
		src.state = 1
		src.icon_state = "flashbang1"
		add_fingerprint(user)
		spawn( src.det_time )
			prime()
			return
	return

/obj/item/weapon/flash/attack(mob/M as mob, mob/user as mob)
	if (src.shots > 0)
		var/safety = null
		if (istype(M, /mob/human))
			var/mob/human/H = M
			if (istype(H.glasses, /obj/item/weapon/clothing/glasses/sunglasses))
				safety = 1
		if (!( safety ))
			M.weakened = 10
			if (M.client)
				if (!( safety ))
					if ((M.eye_stat > 15 && prob(M.eye_stat + 50)))
						flick("e_flash", M.flash)
						M.eye_stat += rand(1, 2)
					else
						flick("flash", M.flash)
						M.eye_stat += rand(0, 2)
					if (M.eye_stat >= 20)
						M << "\red You eyes start to burn badly!"
						M.disabilities |= 1
						if (prob(M.eye_stat - 20 + 1))
							M << "\red You go blind!"
							M.sdisabilities |= 1
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] blinds [] with the flash!", user, M))
	src.attack_self(user, 1)
	return

/obj/item/weapon/flash/attack_self(mob/user as mob, flag)
	if ( (world.time + 600) > src.l_time)
		src.shots = 5
	if (src.shots < 1)
		user.show_message("\red *click* *click*", 2)
		return
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	src.l_time = world.time
	add_fingerprint(user)
	src.shots--
	flick("flash2", src)
	if (!( flag ))
		for(var/mob/M in oviewers(3, null))
			if (prob(50))
				if (locate(/obj/item/weapon/cloaking_device, M))
					for(var/obj/item/weapon/cloaking_device/S in M)
						S.active = 0
						S.icon_state = "shield0"
			if (M.client)
				var/safety = null
				if (istype(M, /mob/human))
					var/mob/human/H = M
					if (istype(H.glasses, /obj/item/weapon/clothing/glasses/sunglasses))
						safety = 1
				if (!( safety ))
					flick("flash", M.flash)
	return

/obj/item/weapon/locator/attack_self(mob/user as mob)
	user.machine = src
	var/dat
	if (src.temp)
		dat = text("[]<BR><BR><A href='?src=\ref[];temp=1'>Clear</A>", src.temp, src)
	else
		dat = text("<B>Persistent Signal Locator</B><HR>\nFrequency: <A href='?src=\ref[];freq=-1'>-</A><A href='?src=\ref[];freq=-0.2'>-</A> [] <A href='?src=\ref[];freq=0.2'>+</A><A href='?src=\ref[];freq=1'>+</A><BR>\n<A href='?src=\ref[];refresh=1'>Refresh</A>", src, src, src.freq, src, src, src)
	user << browse(dat, "window=radio")
	return

/obj/item/weapon/locator/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if ((usr.contents.Find(src) || (get_dist(src, usr) <= 1 && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["refresh"])
			src.temp = "<B>Persistent Signal Locator</B><HR>"
			var/turf/sr = get_turf(src)
			if (sr)
				src.temp += "<B>Located Beacons:</B><BR>"
				for(var/obj/item/weapon/radio/beacon/W in world)
					if (W.freq == src.freq)
						var/turf/tr = get_turf(W)
						if ((tr.z == sr.z && tr))
							var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									if (direct < 20)
										direct = "weak"
									else
										direct = "very weak"
							src.temp += text("[]-[]-[]<BR>", W.code, dir2text(get_dir(sr, tr)), direct)
				src.temp += "<B>Extranneous Signals:</B><BR>"
				for(var/obj/item/weapon/implant/tracking/W in world)
					if (W.freq == src.freq)
						if ((!( W.implanted ) || !( ismob(W.loc) )))
							continue
						else
							var/mob/M = W.loc
							if (M.stat == 2)
								if (M.timeofdeath + 6000 < world.time)
									continue
						var/turf/tr = get_turf(W)
						if ((tr.z == sr.z && tr))
							var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
							if (direct < 20)
								if (direct < 5)
									direct = "very strong"
								else
									if (direct < 10)
										direct = "strong"
									else
										direct = "weak"
								src.temp += text("[]-[]-[]<BR>", W.id, dir2text(get_dir(sr, tr)), direct)
				src.temp += text("<B>You are at \[[],[],[]\]</B> in orbital coordinates.<BR><BR><A href='?src=\ref[];refresh=1'>Refresh</A><BR>", sr.x, sr.y, sr.z, src)
			else
				src.temp += "<B><FONT color='red'>Processing Error:</FONT></B> Unable to locate orbital position.<BR>"
		else
			if (href_list["freq"])
				src.freq += text2num(href_list["freq"])
				if (round(src.freq * 10, 1) % 2 == 0)
					src.freq += 0.1
				src.freq = min(148.9, src.freq)
				src.freq = max(144.1, src.freq)
			else
				if (href_list["temp"])
					src.temp = null
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return

/obj/item/weapon/syndicate_uplink/proc/explode()
	var/turf/T = get_turf(src.loc)
	T.firelevel = T.gas.plasma
	var/sw = locate(max(T.x - 4, 1), max(T.y - 4, 1), T.z)
	var/ne = locate(min(T.x + 4, world.maxx), min(T.y + 4, world.maxy), T.z)
	for(var/turf/U in block(sw, ne))
		var/zone = 4
		if ((U.y <= T.y + 2 && U.y >= T.y - 2 && U.x <= T.x + 2 && U.x >= T.x - 2))
			zone = 3
		for(var/atom/A as mob|obj|turf|area in U)
			A.ex_act(zone)
		U.ex_act(zone)
		U.buildlinks()
	del(src.master)
	del(src)
	return

/obj/item/weapon/syndicate_uplink/attack_self(mob/user as mob)
	user.machine = src
	var/dat
	if (src.selfdestruct)
		dat = "Self Destructing..."
	else
		if (src.temp)
			dat = text("[]<BR><BR><A href='?src=\ref[];temp=1'>Clear</A>", src.temp, src)
		else
			var/dat2 = ""
			if (src.origradio)
				dat2 = text("\n<A href='?src=\ref[];lock=1'>Lock</A><BR>\n<HR>", src)
			dat = text("<B>Syndicate Uplink Console:</B>\n<HR>\nTele-Crystals left: []<BR>\n<B>Request item:</B> (uses 1 tele-crystal)<BR>\n<A href='?src=\ref[];item_emag=1'>Electromagnet Card</A><BR>\n<A href='?src=\ref[];item_sleepypen=1'>Sleepy Pen</A><BR>\n<A href='?src=\ref[];item_cyanide=1'>Cyanide Pill</A><BR>\n<A href='?src=\ref[];item_cloak=1'>Cloaking Device</A><BR>\n<A href='?src=\ref[];item_revolver=1'>Revolver</A><BR>\n<A href='?src=\ref[];item_imp_freedom=1'>Implant- Freedom (with injector)</A><BR>\n<A href='?src=\ref[];item_ai_module=1'>'OxygenIsToxicToHumans' AI Module</A><BR>\n<HR>[]\n<A href='?src=\ref[];selfdestruct=1'>Self-Destruct</A>", src.uses, src, src, src, src, src, src, src, dat2, src)
	user << browse(dat, "window=radio")
	return

/obj/item/weapon/syndicate_uplink/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/mob/human/H = usr
	if (!( istype(H, /mob/human)))
		return 1
	if ((usr.contents.Find(src) || (get_dist(src, usr) <= 1 && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["item_emag"])
			if (src.uses > 0)
				src.uses--
				new /obj/item/weapon/card/emag( H.loc )
		else if (href_list["item_sleepypen"])
			if (src.uses > 0)
				src.uses--
				new /obj/item/weapon/pen/sleepypen( H.loc )
		else if (href_list["item_cyanide"])
			if (src.uses > 0)
				src.uses--
				new /obj/item/weapon/m_pill/cyanide( H.loc )
		else if (href_list["item_cloak"])
			if (src.uses > 0)
				src.uses--
				new /obj/item/weapon/cloaking_device( H.loc )
		else if (href_list["item_revolver"])
			if (src.uses > 0)
				src.uses--
				var/obj/item/weapon/gun/revolver/O = new /obj/item/weapon/gun/revolver( H.loc )
				O.bullets = 7
		else if (href_list["item_imp_freedom"])
			if (src.uses > 0)
				src.uses--
				var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter( H.loc )
				O.imp = new /obj/item/weapon/implant/freedom( O )
				src.temp = "The implant is triggered by chuckling and has a random amount of uses."
		else if (href_list["item_ai_module"])
			if (src.uses > 0)
				src.uses--
				new /obj/item/weapon/aiModule/oxygen( H.loc )
		else if (href_list["lock"])
			// presto chango, a regular radio again! (reset the freq too...)
			usr.machine = null
			usr << browse(null, "window=radio")
			var/obj/item/weapon/radio/T = src.origradio
			var/obj/item/weapon/syndicate_uplink/R = src
			R.loc = T
			T.loc = usr
			// R.layer = initial(R.layer)
			R.layer = 0
			if (usr.client)
				usr.client.screen -= R
			if (usr.r_hand == R)
				usr.u_equip(R)
				usr.r_hand = T
			else
				usr.u_equip(R)
				usr.l_hand = T
			R.loc = T
			T.layer = 20
			T.freq = initial(T.freq)
			T.attack_self(usr)
			return
		else if (href_list["selfdestruct"])
			src.temp = text("<A href='?src=\ref[];selfdestruct2=1'>Self-Destruct</A>", src)
		else if (href_list["selfdestruct2"])
			src.selfdestruct = 1
			spawn( 100 )
				explode()
				return
		else
			if (href_list["temp"])
				src.temp = null
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return

/obj/item/weapon/sword/attack(target as mob, mob/user as mob)
	..()

/obj/item/weapon/sword/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		user << "\blue The sword is now active."
		src.force = 40
		src.icon_state = "sword1"
		src.w_class = 4
	else
		user << "\blue The sword can now be concealed."
		src.force = 3
		src.icon_state = "sword0"
		src.w_class = 2
	src.add_fingerprint(user)
	return

/obj/item/weapon/shield/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		user << "\blue The shield is now active."
		src.icon_state = "shield1"
	else
		user << "\blue The shield is now inactive."
		src.icon_state = "shield0"
	src.add_fingerprint(user)
	return

/obj/item/weapon/cloaking_device/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		user << "\blue The cloaking device is now active."
		src.icon_state = "shield1"
	else
		user << "\blue The cloaking device is now inactive."
		src.icon_state = "shield0"
	src.add_fingerprint(user)
	return

/obj/item/weapon/ammo/proc/update_icon()
	return

/obj/item/weapon/ammo/a357/update_icon()
	src.icon_state = text("357-[]", src.amount_left)
	src.desc = text("There are [] bullet\s left!", src.amount_left)
	return

/obj/item/weapon/gun/revolver/examine()
	set src in usr

	src.desc = text("There are [] bullet\s left! Uses 357.", src.bullets)
	..()
	return

/obj/item/weapon/gun/revolver/attackby(obj/item/weapon/ammo/a357/A as obj, mob/user as mob)

	if (istype(A, /obj/item/weapon/ammo/a357))
		if (src.bullets >= 7)
			user << "\blue It's already fully loaded!"
			return 1
		if (A.amount_left <= 0)
			user << "\red There is no more bullets!"
			return 1
		if (A.amount_left < (7 - src.bullets))
			src.bullets += A.amount_left
			user << text("\red You reload [] bullet\s!", A.amount_left)
			A.amount_left = 0
		else
			user << text("\red You reload [] bullet\s!", 7 - src.bullets)
			A.amount_left -= 7 - src.bullets
			src.bullets = 7
		A.update_icon()
		return 1
	return

/obj/item/weapon/gun/revolver/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if (flag)
		return
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	src.add_fingerprint(user)
	if (src.bullets < 1)
		user.show_message("\red *click* *click*", 2)
		return
	src.bullets--
	for(var/mob/O in viewers(user, null))
		O.show_message(text("\red <B>[] fires a revolver at []!</B>", user, target), 1, "\red You hear a gunshot", 2)
	var/turf/T = user.loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)
	if ((!( U ) || !( T )))
		return
	while(!( istype(U, /turf) ))
		U = U.loc
	if (!( istype(T, /turf) ))
		return
	if (U == T)
		user.las_act("bullet")
		return
	var/obj/bullet/A = new /obj/bullet( user.loc )
	if (!istype(U, /turf))
		del(A)
		return
	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	user.next_move = world.time + 4
	spawn( 0 )
		A.process()
		return
	return

/obj/item/weapon/gun/revolver/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	var/mob/human/H = M

// ******* Check

	if ((istype(H, /mob/human) && istype(H, /obj/item/weapon/clothing/head) && H.flags & 8 && prob(80)))
		M << "\red The helmet protects you from being hit hard in the head!"
		return
	if ((user.a_intent == "hurt" && src.bullets > 0))
		if (prob(20))
			if (M.paralysis < 10)
				M.paralysis = 10
		else
			if (M.weakened < 10)
				M.weakened = 10
		src.bullets--
		src.force = 90
		..()
		src.force = 60
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			if(O.client)	O.show_message(text("\red <B>[] has been shot point-blank by []!</B>", M, user), 1, "\red You hear someone fall", 2)
	else
		if (prob(50))
			if (M.paralysis < 60)
				M.paralysis = 60
		else
			if (M.weakened < 60)
				M.weakened = 60
		src.force = 30
		..()
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			if (O.client)	O.show_message(text("\red <B>[] has been pistol whipped by []!</B>", M, user), 1, "\red You hear someone fall", 2)
	return

/obj/item/weapon/gun/energy/proc/update_icon()
	var/ratio = src.charges / 10
	ratio = round(ratio, 0.25) * 100
	src.icon_state = text("gun[]", ratio)
	return

/obj/item/weapon/gun/energy/laser_gun/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if (flag)
		return
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	src.add_fingerprint(user)

	if(src.charges < 1)
		user << "\red *click* *click*"
		return

	src.charges--
	update_icon()

	var/turf/T = user.loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

	if(!U || !T)
		return
	while(U && !istype(U, /turf))
		U = U.loc
	if(!istype(T, /turf))
		return
	if(U == T)
		user.las_act()
		return
	if(!istype(U, /turf))
		return

	var/obj/beam/a_laser/A = new /obj/beam/a_laser( user.loc )

	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x

	user.next_move = world.time + 4
	A.process()
	return

/obj/item/weapon/gun/energy/laser_gun/attack(mob/M as mob, mob/user as mob)
	..()
	src.add_fingerprint(user)
	if ((prob(30) && M.stat < 2))
		var/mob/human/H = M

// ******* Check
		if ((istype(H, /mob/human) && istype(H, /obj/item/weapon/clothing/head) && H.flags & 8 && prob(80)))
			M << "\red The helmet protects you from being hit hard in the head!"
			return
		var/time = rand(10, 120)
		if (prob(90))
			if (M.paralysis < time)
				M.paralysis = time
		else
			if (M.weakened < time)
				M.weakened = time
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			if(O.client)	O.show_message(text("\red <B>[] has been knocked unconscious!</B>", M), 1, "\red You hear someone fall", 2)
		M.show_message(text("\red <B>This was a []% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>", time * 100 / 120))
	return

/obj/item/weapon/gun/energy/taser_gun/update_icon()
	var/ratio = src.charges / maximum_charges
	ratio = round(ratio, 0.25) * 100
	src.icon_state = text("t_gun[]", ratio)

/obj/item/weapon/gun/energy/taser_gun/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if(flag)
		return
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	src.add_fingerprint(user)

	if(src.charges < 1)
		user << "\red *click* *click*";
		return

	src.charges--
	update_icon()

	var/turf/T = user.loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

	if(!U || !T)
		return
	while(U && !istype(U,/turf))
		U = U.loc
	if(!istype(T, /turf))
		return
	if (U == T)
		user.las_act(1)
		return
	if(!istype(U, /turf))
		return

	var/obj/bullet/electrode/A = new /obj/bullet/electrode(user.loc)

	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x

	A.process()

/obj/item/weapon/gun/energy/taser_gun/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	var/mob/human/H = M
	if ((istype(H, /mob/human) && istype(H, /obj/item/weapon/clothing/head) && H.flags & 8 && prob(80)))
		M << "\red The helmet protects you from being hit hard in the head!"
		return
	if(src.charges >= 1)
		if (user.a_intent == "hurt")
			if (prob(20))
				if (M.paralysis < 10)
					M.paralysis = 10
			else if (M.weakened < 10)
				M.weakened = 10
			if (M.stuttering < 10)
				M.stuttering = 10
			..()
			if(M.stat != 2)	M.stat = 1
			for(var/mob/O in viewers(M, null))
				O.show_message("\red <B>[M] has been knocked unconscious!</B>", 1, "\red You hear someone fall", 2)
		else
			if (prob(50))
				if (M.paralysis < 60)
					M.paralysis = 60
			else
				if (M.weakened < 60)
					M.weakened = 60
			if (M.stuttering < 60)
				M.stuttering = 60
			if(M.stat != 2)	M.stat = 1
			for(var/mob/O in viewers(M, null))
				if (O.client)	O.show_message("\red <B>[M] has been stunned with the taser gun by [user]!</B>", 1, "\red You hear someone fall", 2)
		src.charges--
		update_icon()
	else // no charges in the gun, so they just wallop the target with it
		..()

/obj/item/weapon/baton/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	var/mob/human/H = M

	if ((istype(H, /mob/human) && istype(H, /obj/item/weapon/clothing/head) && H.flags & 8 && prob(80)))
		M << "\red The helmet protects you from being hit hard in the head!"
		return
	flick("baton_active", src)
	if (user.a_intent == "hurt")
		if (M.weakened < 5)
			M.weakened = 5
		if (M.stuttering < 5)
			M.stuttering = 5
		..()
		if (M.stunned < 7)
			M.stunned = 7
	else
		if (M.weakened < 20)
			M.weakened = 20
		if (M.stuttering < 20)
			M.stuttering = 20
		if (M.stunned < 20)
			M.stunned = 20
	for(var/mob/O in viewers(M))
		if (O.client)	O.show_message("\red <B>[M] has been stunned with the stun baton by [user]!</B>", 1, "\red You hear someone fall", 2)

/obj/item/weapon/pill_canister/New()
	..()
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)
	return

/obj/item/weapon/pill_canister/placebo/New()
	..()
	spawn( 2 )
		var/obj/item/weapon/m_pill/P = new /obj/item/weapon/m_pill( src )
		P.amount = 30
		return
	return

/obj/item/weapon/pill_canister/antitoxin/New()
	..()
	spawn( 2 )
		var/obj/item/weapon/m_pill/antitoxin/P = new /obj/item/weapon/m_pill/antitoxin( src )
		P.amount = 30
		return
	return

/obj/item/weapon/pill_canister/Tourette/New()
	..()
	spawn( 2 )
		var/obj/item/weapon/m_pill/Tourette/P = new /obj/item/weapon/m_pill/Tourette( src )
		P.amount = 30
		return
	return

/obj/item/weapon/pill_canister/sleep/New()
	..()
	spawn( 2 )
		var/obj/item/weapon/m_pill/sleep/P = new /obj/item/weapon/m_pill/sleep( src )
		P.amount = 30
		return
	return

/obj/item/weapon/pill_canister/epilepsy/New()

	..()
	spawn( 2 )
		var/obj/item/weapon/m_pill/epilepsy/P = new /obj/item/weapon/m_pill/epilepsy( src )
		P.amount = 30
		return
	return

/obj/item/weapon/pill_canister/cough/New()
	..()
	spawn( 2 )
		var/obj/item/weapon/m_pill/cough/P = new /obj/item/weapon/m_pill/cough( src )
		P.amount = 30
		return
	return

/obj/item/weapon/pill_canister/examine()
	set src in view(1)

	..()
	if (src.contents.len)
		var/pills = 0
		for(var/obj/item/weapon/m_pill/M in src)
			pills += M.amount
			//Foreach goto(39)
		usr << text("\blue There are [] pills inside!", pills)
	else
		usr << "\blue It looks empty!"
	return

/obj/item/weapon/pill_canister/attack_paw(mob/user as mob)
	if ((ticker && ticker.mode.name == "monkey"))
		return src.attack_hand(user)
	return

/obj/item/weapon/pill_canister/attack_hand(mob/user as mob)
	if ((user.r_hand == src || user.l_hand == src) && src.contents && src.contents.len)
		var/obj/item/weapon/m_pill/P = pick(src.contents)
		if (P)
			P.amount--
			var/obj/item/weapon/m_pill/W = new P.type( user )
			if (user.hand)
				user.l_hand = W
			else
				user.r_hand = W
			W.layer = 20
			if (P.amount <= 0)
				//P = null
				del(P)
			W.add_fingerprint(user)
			src.add_fingerprint(user)
	else
		return ..()
	return

/obj/item/weapon/pill_canister/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/m_pill))
		var/pills = 0
		for(var/obj/item/weapon/m_pill/M in src)
			pills += M.amount
		if (pills > 30)
			usr << "\blue There are too many pills inside!"
			return
		for(var/obj/item/weapon/m_pill/M in src)
			if (M.type == W.type)
				M.amount += W:amount
				//W = null
				del(W)
				return
		if (W)
			user.drop_item()
			W.loc = src
			src.add_fingerprint(user)
			W.add_fingerprint(user)
	if (istype(W, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if (user.equipped() != W)
			return
		if (src.loc != user)
			return
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		if (t)
			src.name = text("Pill Canister- '[]'", t)
		else
			src.name = "Pill Canister"
	return

/obj/item/weapon/m_pill/proc/ingest(mob/M as mob)
	src.amount--
	if (src.amount <= 0)
		del(src)
		return
	return

/obj/item/weapon/m_pill/attack_hand(mob/user as mob)
	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/m_pill/F = new src.type( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			del(src)
			return
	else
		..()
	return

/obj/item/weapon/m_pill/attack(mob/M as mob, mob/user as mob)
	var/mob/human/H = M
	if (istype(M, /mob/human) && ((H.head && H.head.flags & HEADCOVERSMOUTH) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSMOUTH)))
		user << "\blue You're going to have to remove that mask/helmet first."
		return

	if ((user != M && istype(M, /mob/human)))
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red [] is forcing [] to swallow the []", user, M, src), 1)
		var/obj/equip_e/human/O = new /obj/equip_e/human(  )
		O.source = user
		O.target = M
		O.item = src
		O.s_loc = user.loc
		O.t_loc = M.loc
		O.place = "pill"
		M.requests += O
		spawn( 0 )
			O.process()
			return
	else
		src.add_fingerprint(user)
		ingest(M)
	return

/obj/item/weapon/m_pill/superpill/ingest(mob/M as mob)
	if(istype(M, /mob/human))
		var/mob/human/H = M
		for(var/A in H.organs)
			var/obj/item/weapon/organ/external/affecting = null
			if(!H.organs[A])	continue
			affecting = H.organs[A]
			if(!istype(affecting, /obj/item/weapon/organ/external))	continue
			affecting.heal_damage(1000, 1000)	//fixes getting hit after ingestion, killing you when game updates organ health
		H.UpdateDamageIcon()
	M.fireloss = 0
	M.toxloss = 0
	M.bruteloss = 0
	M.oxyloss = 0
	M.paralysis = 3
	M.stunned = 4
	M.weakened = 5
	M.updatehealth()
	M.stat = 1
	..()
	return

/obj/item/weapon/m_pill/sleep/ingest(mob/M as mob)
	if (M.drowsyness < 600)
		M.drowsyness += 600
		M.drowsyness = min(M.drowsyness, 1800)
	if (prob(25))
		M.paralysis += 60
	else if (prob(50))
		M.paralysis += 30
	..()
	return

/obj/item/weapon/m_pill/cyanide/ingest(mob/M as mob)
	if (M.health > -50.0)
		M.toxloss += M.health + 50
	M.updatehealth()
	..()
	return

/obj/item/weapon/m_pill/antitoxin/ingest(mob/M as mob)
	if ((prob(50) && M.drowsyness < 600))
		M.drowsyness += 60
		M.drowsyness = min(M.drowsyness, 600)
	if (M.health >= 0)
		if (M.toxloss <= 20)
			M.toxloss = 0
		else
			M.toxloss -= 20
	M.antitoxs += 600
	M.updatehealth()
	..()
	return

/obj/item/weapon/m_pill/cough/ingest(mob/M as mob)
	if ((prob(75) && M.drowsyness < 600))
		M.drowsyness += 60
		M.drowsyness = min(M.drowsyness, 600)
	M.r_ch_cou += 1200
	..()
	return

/obj/item/weapon/m_pill/epilepsy/ingest(mob/M as mob)
	if (M.drowsyness < 600)
		M.drowsyness += rand(2, 3) * 60
		M.drowsyness = min(M.drowsyness, 600)
	M.r_epil += 1200
	..()
	return

/obj/item/weapon/m_pill/Tourette/ingest(mob/M as mob)
	if (M.drowsyness < 600)
		M.drowsyness += rand(3, 5) * 60
		M.drowsyness = min(M.drowsyness, 600)
	M.r_Tourette += 1200
	..()
	return

/obj/item/weapon/m_pill/examine()
	set src in view(1)
	..()
	usr << text("\blue There are [] pills left on the stack!", src.amount)
	return

/obj/item/weapon/m_pill/attackby(obj/item/weapon/m_pill/W as obj, mob/user as mob)

	if (!( istype(W, src.type) ))
		return
	if (W.amount == 5)
		return
	if (W.amount + src.amount > 5)
		src.amount = W.amount + src.amount - 5
		W.amount = 5
	else
		W.amount += W.amount
		del(src)
		return
	return

/obj/item/weapon/handcuffs/attack(mob/M as mob, mob/user as mob)
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	if (istype(M, /mob/human))
		var/obj/equip_e/human/O = new /obj/equip_e/human(  )
		O.source = user
		O.target = M
		O.item = user.equipped()
		O.s_loc = user.loc
		O.t_loc = M.loc
		O.place = "handcuff"
		M.requests += O
		spawn( 0 )
			O.process()
			return
	else
		var/obj/equip_e/monkey/O = new /obj/equip_e/monkey(  )
		O.source = user
		O.target = M
		O.item = user.equipped()
		O.s_loc = user.loc
		O.t_loc = M.loc
		O.place = "handcuff"
		M.requests += O
		spawn( 0 )
			O.process()
			return
	return

/obj/item/weapon/examine()
	set src in view()

	var/t
	switch(src.w_class)
		if(1.0)
			t = "tiny"
		if(2.0)
			t = "small"
		if(3.0)
			t = "normal-sized"
		if(4.0)
			t = "bulky"
		if(5.0)
			t = "huge"
		else
	usr << text("This is a \icon[][]. It is a [] item.", src, src.name, t)
	..()
	return

/obj/item/weapon/attack_hand(mob/user as mob)
	if (istype(src.loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if (M.s_active == src.loc)
				if (M.client)
					M.client.screen -= src
	src.throwing = 0
	if (src.loc == user)
		user.u_equip(src)
	if (user.hand)
		user.l_hand = src
	else
		user.r_hand = src
	src.loc = user
	src.layer = 20
	add_fingerprint(user)
	user.UpdateClothing()
	return

/obj/item/weapon/attack_paw(mob/user as mob)

	if (istype(src.loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if (M.s_active == src.loc)
				if (M.client)
					M.client.screen -= src
	src.throwing = 0
	if (src.loc == user)
		user.u_equip(src)
	if (user.hand)
		user.l_hand = src
	else
		user.r_hand = src
	src.loc = user
	src.layer = 20
	user.UpdateClothing()
	return

/obj/item/weapon/wire/proc/update()
	if (src.amount > 1)
		src.icon_state = "spool_wire"
		src.desc = text("This is just spool of regular insulated wire. It consists of about [] unit\s of wire.", src.amount)
	else
		src.icon_state = "item_wire"
		src.desc = "This is just a simple piece of regular insulated wire."
	return

/obj/item/weapon/wire/attack_self(mob/user as mob)
	if (src.laying)
		src.laying = 0
		user << "\blue You're done laying wire!"
	else
		user << "\blue You are not using this to lay wire..."
	return

/obj/item/weapon/card/data/verb/label(t as text)
	set src in usr

	if (t)
		src.name = text("Data Disk- '[]'", t)
	else
		src.name = "Data Disk"
	src.add_fingerprint(usr)
	return

/obj/item/weapon/card/id/attack_self(mob/user as mob)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("[] shows you: \icon[] []: assignment: []", user, src, src.name, src.assignment), 1)

	src.add_fingerprint(user)
	return

/obj/item/weapon/card/id/verb/read()
	set src in usr

	usr << text("\icon[] []: The current assignment on the card is [].", src, src.name, src.assignment)
	return

/obj/item/weapon/rods/attack_hand(mob/user as mob)
	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/rods/F = new /obj/item/weapon/rods( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
	else
		..()
	return

/obj/item/weapon/rods/attackby(obj/item/weapon/rods/W as obj, mob/user as mob)
	if (!( istype(W, /obj/item/weapon/rods) ))
		return
	if (W.amount == 6)
		return
	if (W.amount + src.amount > 6)
		src.amount = W.amount + src.amount - 6
		W.amount = 6
	else
		W.amount += src.amount
		//SN src = null
		del(src)
		return
	return

/obj/item/weapon/rods/examine()
	set src in view(1)

	..()
	usr << text("There are [] rod\s left on the stack.", src.amount)
	return

/obj/item/weapon/rods/attack_self(mob/user as mob)
	if (locate(/obj/grille, usr.loc))
		for(var/obj/grille/G in usr.loc)
			if (G.destroyed)
				G.health = 10
				G.density = 1
				G.destroyed = 0
				G.icon_state = "grille"
				src.amount--
			else
	else
		if (src.amount < 2)
			return
		src.amount -= 2
		new /obj/grille( usr.loc )
	if (src.amount < 1)
		del(src)
		return
	src.add_fingerprint(user)
	return

/obj/item/weapon/sheet/glass/attack_hand(mob/user as mob)
	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/sheet/glass/F = new /obj/item/weapon/sheet/glass( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
	else
		..()
	src.force = 5
	return

/obj/item/weapon/sheet/glass/attackby(obj/item/weapon/W, mob/user)
	if ( istype(W, /obj/item/weapon/sheet/glass) )
		var/obj/item/weapon/sheet/glass/G = W
		if (G.amount >= 5)
			return
		if (G.amount + src.amount > 5)
			src.amount = G.amount + src.amount - 5
			G.amount = 5
		else
			G.amount += src.amount
			//SN src = null
			del(src)
			return
		return
	else if( istype(W, /obj/item/weapon/rods) )

		var/obj/item/weapon/rods/V  = W
		var/obj/item/weapon/sheet/rglass/R = new /obj/item/weapon/sheet/rglass(user.loc)
		R.loc = user.loc
		R.add_fingerprint(user)


		if(V.amount == 1)

			if(user.client)
				user.client.screen -= V

			user.u_equip(W)
			del(W)
		else
			V.amount--


		if(src.amount == 1)

			if(user.client)
				user.client.screen -= src

			user.u_equip(src)
			del(src)
		else
			src.amount--
			return



/obj/item/weapon/sheet/glass/examine()
	set src in view(1)

	..()
	usr << text("There are [] glass sheet\s on the stack.", src.amount)
	return

/obj/item/weapon/sheet/glass/attack_self(mob/user as mob)

	if (!( istype(usr.loc, /turf/simulated) ))
		return
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	switch(alert("Sheet-Glass", "Would you like full tile glass or one direction?", "one direct", "full (2 sheets)", "cancel", null))
		if("one direct")
			var/obj/window/W = new /obj/window( usr.loc )
			W.anchored = 0
			if (src.amount < 1)
				return
			src.amount--
		if("full (2 sheets)")
			if (src.amount < 2)
				return
			src.amount -= 2
			var/obj/window/W = new /obj/window( usr.loc )
			W.dir = SOUTHWEST
			W.ini_dir = SOUTHWEST
			W.anchored = 0
		else
	if (src.amount <= 0)
		user.u_equip(src)
		del(src)
		return
	return

/obj/item/weapon/sheet/rglass/attack_hand(mob/user as mob)
	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/sheet/rglass/F = new /obj/item/weapon/sheet/rglass( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
	else
		..()
	src.force = 5
	return

/obj/item/weapon/sheet/rglass/attackby(obj/item/weapon/sheet/rglass/W as obj, mob/user as mob)
	if (!( istype(W, /obj/item/weapon/sheet/rglass) ))
		return
	if (W.amount >= 5)
		return
	if (W.amount + src.amount > 5)
		src.amount = W.amount + src.amount - 5
		W.amount = 5
	else
		W.amount += src.amount
		del(src)
		return
	return

/obj/item/weapon/sheet/rglass/examine()
	set src in view(1)

	..()
	usr << text("There are [] reinforced glass sheet\s on the stack.", src.amount)
	return

/obj/item/weapon/sheet/rglass/attack_self(mob/user as mob)
	if (!istype(usr.loc, /turf/simulated))
		return
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	switch(alert("Sheet Reinf. Glass", "Would you like full tile glass or one direction?", "one direct", "full (2 sheets)", "cancel", null))
		if("one direct")
			var/obj/window/W = new /obj/window( usr.loc, 1 )
			W.anchored = 0
			W.state = 0
			if (src.amount < 1)
				return
			src.amount--
		if("full (2 sheets)")
			if (src.amount < 2)
				return
			src.amount -= 2
			var/obj/window/W = new /obj/window( usr.loc, 1 )
			W.dir = SOUTHWEST
			W.ini_dir = SOUTHWEST
			W.anchored = 0
			W.state = 0
		else
	if (src.amount <= 0)
		user.u_equip(src)
		//SN src = null
		del(src)
		return
	return


/obj/item/weapon/clipboard/attack_self(mob/user as mob)
	var/dat = "<B>Clipboard</B><BR>"
	if (src.pen)
		dat += text("<A href='?src=\ref[];pen=1'>Remove Pen</A><BR><HR>", src)
	for(var/obj/item/weapon/paper/P in src)
		dat += text("<A href='?src=\ref[];read=\ref[]'>[]</A> <A href='?src=\ref[];write=\ref[]'>Write</A> <A href='?src=\ref[];remove=\ref[]'>Remove</A><BR>", src, P, P.name, src, P, src, P)
	user << browse(dat, "window=clipboard")
	return

/obj/item/weapon/clipboard/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()))
		return
	if (usr.contents.Find(src))
		usr.machine = src
		if (href_list["pen"])
			if (src.pen)
				if ((usr.hand && !( usr.l_hand )))
					usr.l_hand = src.pen
					src.pen.loc = usr
					src.pen.layer = 20
					src.pen = null
					usr.UpdateClothing()
				else
					if (!( usr.r_hand ))
						usr.r_hand = src.pen
						src.pen.loc = usr
						src.pen.layer = 20
						src.pen = null
						usr.UpdateClothing()
				if (src.pen)
					src.pen.add_fingerprint(usr)
				src.add_fingerprint(usr)
		if (href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if ((P && P.loc == src))
				if ((usr.hand && !( usr.l_hand )))
					usr.l_hand = P
					P.loc = usr
					P.layer = 20
					usr.UpdateClothing()
				else
					if (!( usr.r_hand ))
						usr.r_hand = P
						P.loc = usr
						P.layer = 20
						usr.UpdateClothing()
				P.add_fingerprint(usr)
				src.add_fingerprint(usr)
		if (href_list["write"])
			var/obj/item/P = locate(href_list["write"])
			if ((P && P.loc == src))
				if (istype(usr.r_hand, /obj/item/weapon/pen))
					P.attackby(usr.r_hand, usr)
				else
					if (istype(usr.l_hand, /obj/item/weapon/pen))
						P.attackby(usr.l_hand, usr)
					else
						if (istype(src.pen, /obj/item/weapon/pen))
							P.attackby(src.pen, usr)
			src.add_fingerprint(usr)
		if (href_list["read"])
			var/obj/item/weapon/paper/P = locate(href_list["read"])
			if ((P && P.loc == src))
				if (!( istype(usr, /mob/human) ))
					usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, stars(P.info)), text("window=[]", P.name))
				else
					usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, P.info), text("window=[]", P.name))
		if (ismob(src.loc))
			var/mob/M = src.loc
			if (M.machine == src)
				spawn( 0 )
					src.attack_self(M)
					return
	return

/obj/item/weapon/clipboard/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/clipboard/attack_hand(mob/user as mob)

	if ((locate(/obj/item/weapon/paper, src) && (!( user.equipped() ) && (user.l_hand == src || user.r_hand == src))))
		var/obj/item/weapon/paper/P
		for(P in src)
			break
		if (P)
			if (user.hand)
				user.l_hand = P
			else
				user.r_hand = P
			P.loc = user
			P.layer = 20
			P.add_fingerprint(user)
			user.UpdateClothing()
		src.add_fingerprint(user)
	else
		if (user.contents.Find(src))
			spawn( 0 )
				src.attack_self(user)
				return
		else
			return ..()
	return

/obj/item/weapon/clipboard/attackby(obj/item/weapon/P as obj, mob/user as mob)

	if (istype(P, /obj/item/weapon/paper))
		if (src.contents.len < 15)
			user.drop_item()
			P.loc = src
		else
			user << "\blue Not enough space!!!"
	else
		if (istype(P, /obj/item/weapon/pen))
			if (!src.pen)
				user.drop_item()
				P.loc = src
				src.pen = P
		else
			return
	src.update()
	spawn(0)
		attack_self(user)
		return
	return

/obj/item/weapon/clipboard/proc/update()
	src.icon_state = text("clipboard[][]", (locate(/obj/item/weapon/paper, src) ? "1" : "0"), (locate(/obj/item/weapon/pen, src) ? "1" : "0"))
	return

/obj/item/weapon/fcardholder/attack_self(mob/user as mob)
	var/dat = "<B>Clipboard</B><BR>"
	for(var/obj/item/weapon/f_card/P in src)
		dat += text("<A href='?src=\ref[];read=\ref[]'>[]</A> <A href='?src=\ref[];remove=\ref[]'>Remove</A><BR>", src, P, P.name, src, P)
	user << browse(dat, "window=fcardholder")
	return

/obj/item/weapon/fcardholder/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()))
		return
	if (usr.contents.Find(src))
		usr.machine = src
		if (href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if ((P && P.loc == src))
				if ((usr.hand && !( usr.l_hand )))
					usr.l_hand = P
					P.loc = usr
					P.layer = 20
					usr.UpdateClothing()
				else
					if (!( usr.r_hand ))
						usr.r_hand = P
						P.loc = usr
						P.layer = 20
						usr.UpdateClothing()
				src.add_fingerprint(usr)
				P.add_fingerprint(usr)
			src.update()
		if (href_list["read"])
			var/obj/item/weapon/f_card/P = locate(href_list["read"])
			if ((P && P.loc == src))
				if (!( istype(usr, /mob/human) ))
					usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, P.display()), text("window=[]", P.name))
				else
					usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, P.display()), text("window=[]", P.name))
			src.add_fingerprint(usr)
		if (ismob(src.loc))
			var/mob/M = src.loc
			if (M.machine == src)
				spawn( 0 )
					src.attack_self(M)
					return
	return

/obj/item/weapon/fcardholder/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/fcardholder/attack_hand(mob/user as mob)
	if (user.contents.Find(src))
		spawn( 0 )
			src.attack_self(user)
			return
		src.add_fingerprint(user)
	else
		return ..()
	return

/obj/item/weapon/fcardholder/attackby(obj/item/weapon/P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/f_card))
		if (src.contents.len < 30)
			user.drop_item()
			P.loc = src
			add_fingerprint(user)
			src.add_fingerprint(user)
		else
			user << "\blue Not enough space!!!"
	else
		if (istype(P, /obj/item/weapon/pen))
			var/t = input(user, "Holder Label:", text("[]", src.name), null)  as text
			if (user.equipped() != P)
				return
			if ((get_dist(src, usr) > 1 && src.loc != user))
				return
			t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
			if (t)
				src.name = text("FPCase- '[]'", t)
			else
				src.name = "Finger Print Case"
		else
			return
	src.update()
	spawn( 0 )
		attack_self(user)
		return
	return

/obj/item/weapon/fcardholder/proc/update()
	var/i = 0
	for(var/obj/item/weapon/f_card/F in src)
		i = 1
		break
	src.icon_state = text("fcardholder[]", (i ? "1" : "0"))
	return

/obj/item/weapon/extinguisher/examine()
	set src in usr

	usr << text("\icon[] [] contains [] units of water left!", src, src.name, src.waterleft)
	..()
	return

/obj/item/weapon/extinguisher/afterattack(atom/target, mob/user , flag)

	if (src.icon_state == "fire_extinguisher1")
		if (src.waterleft < 1)
			return
		if (world.time < src.last_use + 20)
			return
		src.last_use = world.time
		if (istype(target, /area))
			return
		var/cur_loc = get_turf(user)
		var/tar_loc = (isturf(target) ? target : get_turf(target))


		if (get_dist(tar_loc, cur_loc) > 1)
			var/list/close = list(  )
			var/list/far = list(  )
			for(var/T in oview(2, tar_loc))
				if (get_dist(T, tar_loc) <= 1)
					close += T
				else
					far += T
			close += tar_loc
			var/t = null
			t = 1
			while(t <= 14)
				var/obj/effects/water/W = new /obj/effects/water( cur_loc )
				if (rand(1, 3) != 1)
					walk_towards(W, pick(close), null)
				else
					walk_towards(W, pick(far), null)
				sleep(1)
				t++
			src.waterleft--
			src.last_use = world.time
		else
			if (cur_loc == tar_loc)
				new /obj/effects/water( cur_loc )
				src.waterleft -= 0.25
				src.last_use = 1
			else
				var/list/possible = list(  )
				for(var/T in oview(1, tar_loc))
					possible += T
				possible += tar_loc
				var/t = null
				t = 1
				while(t <= 7)
					var/obj/effects/water/W = new /obj/effects/water( cur_loc )
					walk_towards(W, pick(possible), null)
					sleep(1)
					t++
				src.waterleft -= 0.5
				src.last_use = world.time

					// propulsion
		if(istype(cur_loc, /turf/space))
			user.Move(get_step(user, get_dir(target, user) ))
		//

	else
		return ..()
	return

/obj/item/weapon/extinguisher/attack_self(mob/user as mob)

	if (src.icon_state == "fire_extinguisher0")
		src.icon_state = "fire_extinguisher1"
		src.desc = "The safety is off."
	else
		src.icon_state = "fire_extinguisher0"
		src.desc = "The safety is on."
	return

/obj/item/weapon/pen/sleepypen/attack_paw(mob/user as mob)

	return src.attack_hand(user)
	return

/obj/item/weapon/pen/sleepypen/New()

	src.chem = new /obj/substance/chemical(  )
	src.chem.maximum = 5
	var/datum/chemical/s_tox/C = new /datum/chemical/s_tox( null )
	C.moles = C.density * 5 / C.molarmass
	src.chem.chemicals[text("[]", C.name)] = C
	..()
	return

/obj/item/weapon/pen/sleepypen/attack(mob/M as mob, mob/user as mob)

	if (!( istype(M, /mob) ))
		return
	if (src.desc == "It's a normal black ink pen.")
		return ..()
	if (user)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red [] has been stabbed with [] by [].", M, src, user), 1)
			//Foreach goto(57)
		var/amount = src.chem.transfer_mob(M, src.chem.maximum)
		user.show_message(text("\red You inject [] units into the [].", amount, M))
		src.desc = "It's a normal black ink pen."
	return

/obj/item/weapon/paint/attack_self(mob/user as mob)

	var/t1 = input(user, "Please select a color:", "Locking Computer", null) in list( "red", "blue", "green", "yellow", "black", "white", "neutral" )
	if ((user.equipped() != src || user.stat || user.restrained()))
		return
	src.color = t1
	src.icon_state = text("paint_[]", t1)
	add_fingerprint(user)
	return

/obj/item/weapon/paper/burn(fi_amount)

	spawn( 0 )
		var/t = src.icon_state
		src.icon_state = ""
		src.icon = 'icons/ss13/b_items.dmi'
		flick(text("[]", t), src)
		spawn( 14 )
			//SN src = null
			del(src)
			return
			return
		return
	return

/obj/item/weapon/paper/photograph/New()

	..()
	src.pixel_y = 0
	src.pixel_x = 0
	return

/obj/item/weapon/paper/photograph/attack_self(mob/user as mob)

	var/n_name = input(user, "What would you like to label the photo?", "Paper Labelling", null)  as text
	n_name = copytext(n_name, 1, 32)
	if ((src.loc == user && user.stat == 0))
		src.name = text("photo[]", (n_name ? text("- '[]'", n_name) : null))
	src.add_fingerprint(user)
	return

/obj/item/weapon/paper/photograph/examine()
	set src in view()

	..()
	return

/obj/item/weapon/paper/New()

	..()
	src.pixel_y = rand(1, 16)
	src.pixel_x = rand(1, 16)
	return

/obj/item/weapon/paper/attack_self(mob/user as mob)

	var/n_name = input(user, "What would you like to label the paper?", "Paper Labelling", null)  as text
	n_name = copytext(n_name, 1, 32)
	if ((src.loc == user && user.stat == 0))
		src.name = text("paper[]", (n_name ? text("- '[]'", n_name) : null))
	src.add_fingerprint(user)
	return

/obj/item/weapon/paper/attack_ai(var/mob/ai/user as mob)
	if (get_dist(src, user.current) < 2)
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, src.info), text("window=[]", src.name))
	else
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, stars(src.info)), text("window=[]", src.name))
	return

/obj/item/weapon/paper/attackby(obj/item/weapon/P as obj, mob/user as mob)

	if (istype(P, /obj/item/weapon/pen))
		var/t = input(user, "What text do you wish to add?", text("[]", src.name), null)  as message
		if ((get_dist(src, usr) > 1 && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
			return
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		t = dd_replacetext(t, "\n", "<BR>")
		t = dd_replacetext(t, "\[b\]", "<B>")
		t = dd_replacetext(t, "\[/b\]", "</B>")
		t = dd_replacetext(t, "\[i\]", "<I>")
		t = dd_replacetext(t, "\[/i\]", "</I>")
		t = dd_replacetext(t, "\[u\]", "<U>")
		t = dd_replacetext(t, "\[/u\]", "</U>")
		t = dd_replacetext(t, "\[sign\]", text("<font face=vivaldi>[]</font>", user.rname))
		t = text("<font face=calligrapher>[]</font>", t)
		src.info += t
	else
		if (istype(P, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/W = P
			if ((W.welding && W.weldfuel > 0))
				for(var/mob/O in viewers(user, null))
					O.show_message(text("\red [] burns [] with the welding tool!", user, src), 1, "\red You hear a small burning noise", 2)
					//Foreach goto(323)
				spawn( 0 )
					src.burn(1800000.0)
					return
		else
			if (istype(P, /obj/item/weapon/igniter))
				for(var/mob/O in viewers(user, null))
					O.show_message(text("\red [] burns [] with the igniter!", user, src), 1, "\red You hear a small burning noise", 2)
					//Foreach goto(406)
				spawn( 0 )
					src.burn(1800000.0)
					return
			else
				if (istype(P, /obj/item/weapon/wirecutters))
					for(var/mob/O in viewers(user, null))
						O.show_message(text("\red [] starts cutting []!", user, src), 1)
						//Foreach goto(489)
					sleep(50)
					if (((src.loc == src || get_dist(src, user) <= 1) && (!( user.stat ) && !( user.restrained() ))))
						for(var/mob/O in viewers(user, null))
							O.show_message(text("\red [] cuts [] to pieces!", user, src), 1)
							//Foreach goto(580)
						//SN src = null
						del(src)
						return
	src.add_fingerprint(user)
	return

/obj/item/weapon/paper/examine()
	set src in view()

	..()
	if (!( istype(usr, /mob/human) ))
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, stars(src.info)), text("window=[]", src.name))
	else
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, src.info), text("window=[]", src.name))
	return

/* /obj/item/weapon/paper/Map/examine()
	set src in view()

	..()

	usr << browse_rsc(map_graphic)
	if (!( istype(usr, /mob/human) ))
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, stars(src.info)), text("window=[]", src.name))
	else
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, src.info), text("window=[]", src.name))
	return*/


/obj/item/weapon/f_card/examine()
	set src in view(2)

	..()
	usr << text("\blue There are [] on the stack!", src.amount)
	usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, display()), text("window=[]", src.name))
	return

/obj/item/weapon/f_card/proc/display()

	if (src.fingerprints)
		var/dat = "<B>Fingerprints on Card</B><HR>"
		var/L = params2list(src.fingerprints)
		for(var/i in L)
			dat += text("[]<BR>", i)
			//Foreach goto(41)
		return dat
	else
		return "<B>There are no fingerprints on this card.</B>"
	return

/obj/item/weapon/f_card/attack_hand(mob/user as mob)

	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
	else
		..()
	return

/obj/item/weapon/f_card/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/f_card))
		if ((src.fingerprints || W.fingerprints))
			return
		if (src.amount == 10)
			return
		if (W:amount + src.amount > 10)
			src.amount = 10
			W:amount = W:amount + src.amount - 10
		else
			src.amount += W:amount
			//W = null
			del(W)
		src.add_fingerprint(user)
		if (W)
			W.add_fingerprint(user)
	else
		if (istype(W, /obj/item/weapon/pen))
			var/t = input(user, "Card Label:", text("[]", src.name), null)  as text
			if (user.equipped() != W)
				return
			if ((get_dist(src, usr) > 1 && src.loc != user))
				return
			t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
			if (t)
				src.name = text("FPrintC- '[]'", t)
			else
				src.name = "Finger Print Card"
			W.add_fingerprint(user)
			src.add_fingerprint(user)
	return

/obj/item/weapon/f_card/add_fingerprint()

	..()
	if (!istype(usr, /mob/ai))
		if (src.fingerprints)
			if (src.amount > 1)
				var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card( (ismob(src.loc) ? src.loc.loc : src.loc) )
				F.amount = --src.amount
				src.amount = 1
			src.icon_state = "f_print_card1"
	return

/obj/item/weapon/f_print_scanner/attackby(obj/item/weapon/f_card/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/f_card))
		if (W.fingerprints)
			return
		if (src.amount == 20)
			return
		if (W.amount + src.amount > 20)
			src.amount = 20
			W.amount = W.amount + src.amount - 20
		else
			src.amount += W.amount
			//W = null
			del(W)
		src.add_fingerprint(user)
		if (W)
			W.add_fingerprint(user)
	return

/obj/item/weapon/f_print_scanner/attack_self(mob/user as mob)

	src.printing = !( src.printing )
	src.icon_state = text("f_print_scanner[]", src.printing)
	add_fingerprint(user)
	return

/obj/item/weapon/f_print_scanner/attack(mob/human/M as mob, mob/user as mob)

	if ((!( ismob(M) ) || !( istype(M.primary, /obj/dna) ) || !( istype(M, /mob/human) ) || M.gloves))
		user << text("\blue Unable to locate any fingerprints on []!", M)
		return 0
	else
		if ((src.amount < 1 && src.printing))
			user << text("\blue Fingerprints scanned on []. Need more cards to print.", M)
			src.printing = 0
	src.icon_state = text("f_print_scanner[]", src.printing)
	if (src.printing)
		src.amount--
		var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card( user.loc )
		F.amount = 1
		F.fingerprints = md5(M.primary.uni_identity)
		F.icon_state = "f_print_card1"
		F.name = text("FPrintC- '[]'", M.name)
		user << "\blue Done printing."
	user << text("\blue []'s Fingerprints: []", M, md5(M.primary.uni_identity))
	return

/obj/item/weapon/f_print_scanner/afterattack(atom/A as mob|obj|turf|area, mob/user as mob)

	src.add_fingerprint(user)
	if (!( A.fingerprints ))
		user << "\blue Unable to locate any fingerprints!"
		return 0
	else
		if ((src.amount < 1 && src.printing))
			user << "\blue Fingerprints found. Need more cards to print."
			src.printing = 0
	src.icon_state = text("f_print_scanner[]", src.printing)
	if (src.printing)
		src.amount--
		var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card( user.loc )
		F.amount = 1
		F.fingerprints = A.fingerprints
		F.icon_state = "f_print_card1"
		user << "\blue Done printing."
	var/list/L = params2list(A.fingerprints)
	user << text("\blue Isolated [] fingerprints.", L.len)
	for(var/i in L)
		user << text("\blue \t []", i)
		//Foreach goto(186)
	return

/obj/item/weapon/healthanalyzer/attack(mob/M as mob, mob/user as mob)

	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	for(var/mob/O in viewers(M, null))
		O.show_message(text("\red [] has analyzed []'s vitals!", user, M), 1)
		//Foreach goto(67)
	user.show_message(text("\blue Analyzing Results for []:\n\t Overall Status: []", M, (M.stat > 1 ? "dead" : text("[]% healthy", M.health))), 1)
	user.show_message(text("\blue \t Damage Specifics: []-[]-[]-[]", M.oxyloss, M.toxloss, M.fireloss, M.bruteloss), 1)
	user.show_message("\blue Key: Suffocation/Toxin/Burns/Brute", 1)
	user.show_message("\blue Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)", 1)
	if (M.rejuv)
		user.show_message(text("\blue Bloodstream Analysis located [] units of rejuvenation chemicals.", M.rejuv), 1)
	src.add_fingerprint(user)
	return

/obj/item/weapon/analyzer/attack_self(mob/user as mob)

	if(user.stat)
		return

	var/turf/T = user.loc

	if(!isturf(T))
		return

	user.show_message("\blue Results:", 1)

	var/obj/substance/gas/gas = T.gas

	user.show_message("\blue Air Pressure: [round(gas.pressure/1000)] kPa", 1)
	user.show_message("\blue Nitrogen: [round(gas.n2/gas.total_moles*100, 0.1)] %", 1)
	user.show_message("\blue Oxygen: [round(gas.o2/gas.total_moles*100, 0.1)] %", 1)
	user.show_message("\blue Plasma: [round(gas.plasma/gas.total_moles*100, 0.1)] %", 1)
	user.show_message("\blue CO2: [round(gas.co2/gas.total_moles*100, 0.1)] %", 1)
	user.show_message("\blue N2O: [round(gas.n2o/gas.total_moles*100, 0.1)] %", 1)
	for(var/mg_path in gas.minor)
		var/obj/minor_gas/mg = gas.minor[mg_path]
		user.show_message("\blue [mg.name]: [round(mg.amount/gas.total_moles*100, 0.1)] %", 1)

	user.show_message("\blue Temperature: [gas.temperature] K", 1)

	src.add_fingerprint(user)

/obj/item/weapon/storage/proc/return_inv()

	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/weapon/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in ticker.killer.contents)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()
	return L

/obj/item/weapon/storage/proc/show_to(mob/user as mob)

	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	user.client.screen += src.boxes
	user.client.screen += src.closer
	user.client.screen += src.contents
	user.s_active = src
	return

/obj/item/weapon/storage/proc/hide_from(mob/user as mob)

	if(!user.client)
		return
	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	return

/obj/item/weapon/storage/proc/close(mob/user as mob)

	src.hide_from(user)
	user.s_active = null
	return

/obj/item/weapon/storage/proc/orient_objs(tx, ty, mx, my)

	var/cx = tx
	var/cy = ty
	src.boxes.screen_loc = text("[],[] to [],[]", tx, ty, mx, my)
	for(var/obj/O in src.contents)
		O.screen_loc = text("[],[]", cx, cy)
		O.layer = 20
		cx++
		if (cx > mx)
			cx = tx
			cy--
		//Foreach goto(56)
	src.closer.screen_loc = text("[],[]", mx, my)
	return

/obj/item/weapon/storage/proc/orient2hud(mob/user as mob)

	if (src == user.l_hand)
		src.orient_objs(3, 11, 3, 4)
	else
		if (src == user.r_hand)
			src.orient_objs(1, 11, 1, 4)
		else
			if (src == user.back)
				src.orient_objs(4, 10, 4, 3)
			else
				src.orient_objs(7, 8, 10, 7)
	return

/obj/item/weapon/storage/lglo_kit/New()

	new /obj/item/weapon/clothing/gloves/latex( src )
	new /obj/item/weapon/clothing/gloves/latex( src )
	new /obj/item/weapon/clothing/gloves/latex( src )
	new /obj/item/weapon/clothing/gloves/latex( src )
	new /obj/item/weapon/clothing/gloves/latex( src )
	new /obj/item/weapon/clothing/gloves/latex( src )
	new /obj/item/weapon/clothing/gloves/latex( src )
	..()
	return

/obj/item/weapon/storage/flashbang_kit/New()

	new /obj/item/weapon/flashbang( src )
	new /obj/item/weapon/flashbang( src )
	new /obj/item/weapon/flashbang( src )
	new /obj/item/weapon/flashbang( src )
	new /obj/item/weapon/flashbang( src )
	new /obj/item/weapon/flashbang( src )
	new /obj/item/weapon/flashbang( src )
	..()
	return

/obj/item/weapon/storage/stma_kit/New()

	new /obj/item/weapon/clothing/mask/surgical( src )
	new /obj/item/weapon/clothing/mask/surgical( src )
	new /obj/item/weapon/clothing/mask/surgical( src )
	new /obj/item/weapon/clothing/mask/surgical( src )
	new /obj/item/weapon/clothing/mask/surgical( src )
	new /obj/item/weapon/clothing/mask/surgical( src )
	new /obj/item/weapon/clothing/mask/surgical( src )
	..()
	return

/obj/item/weapon/storage/gl_kit/New()

	new /obj/item/weapon/clothing/glasses/regular( src )
	new /obj/item/weapon/clothing/glasses/regular( src )
	new /obj/item/weapon/clothing/glasses/regular( src )
	new /obj/item/weapon/clothing/glasses/regular( src )
	new /obj/item/weapon/clothing/glasses/regular( src )
	new /obj/item/weapon/clothing/glasses/regular( src )
	new /obj/item/weapon/clothing/glasses/regular( src )
	..()
	return

/obj/item/weapon/storage/trackimp_kit/New()

	new /obj/item/weapon/implantcase/tracking( src )
	new /obj/item/weapon/implantcase/tracking( src )
	new /obj/item/weapon/implantcase/tracking( src )
	new /obj/item/weapon/implantcase/tracking( src )
	new /obj/item/weapon/implanter( src )
	new /obj/item/weapon/implantpad( src )
	new /obj/item/weapon/locator( src )
	..()
	return

/obj/item/weapon/storage/fcard_kit/New()

	new /obj/item/weapon/f_card( src )
	new /obj/item/weapon/f_card( src )
	new /obj/item/weapon/f_card( src )
	new /obj/item/weapon/f_card( src )
	new /obj/item/weapon/f_card( src )
	new /obj/item/weapon/f_card( src )
	new /obj/item/weapon/f_card( src )
	..()
	return

/obj/item/weapon/storage/id_kit/New()

	new /obj/item/weapon/card/id( src )
	new /obj/item/weapon/card/id( src )
	new /obj/item/weapon/card/id( src )
	new /obj/item/weapon/card/id( src )
	new /obj/item/weapon/card/id( src )
	new /obj/item/weapon/card/id( src )
	new /obj/item/weapon/card/id( src )
	..()
	return

/obj/item/weapon/storage/handcuff_kit/New()

	new /obj/item/weapon/handcuffs( src )
	new /obj/item/weapon/handcuffs( src )
	new /obj/item/weapon/handcuffs( src )
	new /obj/item/weapon/handcuffs( src )
	new /obj/item/weapon/handcuffs( src )
	new /obj/item/weapon/handcuffs( src )
	new /obj/item/weapon/handcuffs( src )
	..()
	return

/obj/item/weapon/storage/disk_kit/disks/New()

	new /obj/item/weapon/card/data( src )
	new /obj/item/weapon/card/data( src )
	new /obj/item/weapon/card/data( src )
	new /obj/item/weapon/card/data( src )
	new /obj/item/weapon/card/data( src )
	new /obj/item/weapon/card/data( src )
	new /obj/item/weapon/card/data( src )
	..()
	return

/obj/item/weapon/storage/disk_kit/disks2/New()

	spawn( 2 )
		for(var/obj/item/weapon/card/data/D in src.loc)
			D.loc = src
			//Foreach goto(23)
		return
	..()
	return

/obj/item/weapon/storage/backpack/New()

	new /obj/item/weapon/storage/box( src )
	..()
	return

/obj/item/weapon/storage/backpack/MouseDrop(obj/over_object as obj)

	if (src.loc != usr)
		return
	if ((istype(usr, /mob/human) || (ticker && ticker.mode.name == "monkey")))
		var/mob/M = usr
		if (!( istype(over_object, /obj/screen) ))
			return ..()
		if ((!( M.restrained() ) && !( M.stat ) && M.back == src))
			if (over_object.name == "r_hand")
				if (!( M.r_hand ))
					M.u_equip(src)
					M.r_hand = src
			else
				if (over_object.name == "l_hand")
					if (!( M.l_hand ))
						M.u_equip(src)
						M.l_hand = src
			M.UpdateClothing()
			src.add_fingerprint(usr)
	return

/obj/item/weapon/storage/backpack/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (src.contents.len >= 7)
		return
	if (W.w_class > 3)
		return
	var/t
	for(var/obj/item/weapon/O in src)
		t += O.w_class
		//Foreach goto(46)
	t += W.w_class
	if (t > 20)
		user << "You cannot fit the item inside. (Remove larger classed items)"
		return
	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped()
	add_fingerprint(user)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("\blue [] has added [] to []!", user, W, src), 1)
		//Foreach goto(206)
	return

/obj/item/weapon/storage/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (src.contents.len >= 7)
		return
	if ((W.w_class >= 3 || istype(W, /obj/item/weapon/storage)))
		return
	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped()
	add_fingerprint(user)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("\blue [] has added [] to []!", user, W, src), 1)
		//Foreach goto(139)
	return

/obj/item/weapon/storage/dropped(mob/user as mob)

	src.orient_objs(7, 8, 10, 7)
	return

/obj/item/weapon/storage/MouseDrop(over_object, src_location, over_location)

	..()
	if ((over_object == usr && (get_dist(src, usr) <= 1 || usr.contents.Find(src))))
		if (usr.s_active)
			usr.s_active.close(usr)
		src.show_to(usr)
	return

/obj/item/weapon/storage/attack_paw(mob/user as mob)

	return src.attack_hand(user)
	return

/obj/item/weapon/storage/attack_hand(mob/user as mob)

	if (src.loc == user)
		if (user.s_active)
			user.s_active.close(user)
		src.show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)
			//Foreach goto(76)
		src.orient2hud(user)
	src.add_fingerprint(user)
	return

/obj/item/weapon/storage/New()
	. = ..()

	src.boxes = new /obj/screen/storage(  )
	src.boxes.name = "storage"
	src.boxes.master = src
	src.boxes.icon_state = "block"
	src.boxes.screen_loc = "7,7 to 10,8"
	src.boxes.layer = 19
	src.closer = new /obj/screen/close(  )
	src.closer.master = src
	src.closer.icon_state = "x"
	src.closer.layer = 20
	spawn( 5 )
		src.orient_objs(7, 8, 10, 7)
		return
	return

/obj/item/weapon/storage/toolbox/mechanical/New()
	. = ..()
	new /obj/item/weapon/wirecutters( src )
	new /obj/item/weapon/screwdriver( src )
	new /obj/item/weapon/crowbar( src )
	new /obj/item/weapon/wrench( src )
	new /obj/item/weapon/weldingtool( src )
	new /obj/item/weapon/analyzer( src )

/obj/item/weapon/storage/toolbox/emergency/New()
	. = ..()
	new /obj/item/weapon/flashlight( src )
	new /obj/item/weapon/crowbar( src )
	new /obj/item/weapon/extinguisher( src )
	new /obj/item/weapon/radio( src )

/obj/item/weapon/storage/toolbox/electrical/New()
	. = ..()
	new /obj/item/weapon/screwdriver( src )
	new /obj/item/weapon/wirecutters( src )
	new /obj/item/weapon/t_scanner( src )
	new /obj/item/weapon/crowbar( src )
	new /obj/item/weapon/cable_coil( src )
	new /obj/item/weapon/cable_coil( src )
	new /obj/item/weapon/cable_coil( src )

/obj/item/weapon/storage/toolbox/attack(mob/M as mob, mob/user as mob)
	..()
	if ((prob(30) && M.stat < 2))
		var/mob/H = M

		// ******* Check

		if ((istype(H, /mob/human) && istype(H, /obj/item/weapon/clothing/head) && H.flags & 8 && prob(80)))
			M << "\red The helmet protects you from being hit hard in the head!"
			return
		var/time = rand(10, 120)
		if (prob(90))
			if (M.paralysis < time)
				M.paralysis = time
		else
			if (M.stunned < time)
				M.stunned = time
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] has been knocked unconscious!</B>", M), 1, "\red You hear someone fall.", 2)
		M.show_message(text("\red <B>This was a []% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>", time * 100 / 120))
	return

/obj/item/weapon/storage/firstaid/fire/New()
	..()
	new /obj/item/weapon/ointment( src )
	new /obj/item/weapon/ointment( src )
	new /obj/item/weapon/ointment( src )
	new /obj/item/weapon/ointment( src )
	new /obj/item/weapon/healthanalyzer( src )
	var/obj/item/weapon/syringe/S = new /obj/item/weapon/syringe( src )
	var/datum/chemical/rejuv/C = new /datum/chemical/rejuv( null )
	C.moles = C.density * 15 / C.molarmass
	S.chem.chemicals[text("[]", C.name)] = C
	S.icon_state = "syringe_15"
	return

/obj/item/weapon/storage/firstaid/syringes/New()
	..()
	new /obj/item/weapon/syringe( src )
	new /obj/item/weapon/syringe( src )
	new /obj/item/weapon/syringe( src )
	new /obj/item/weapon/syringe( src )
	new /obj/item/weapon/syringe( src )
	new /obj/item/weapon/syringe( src )
	new /obj/item/weapon/syringe( src )
	return

/obj/item/weapon/storage/firstaid/regular/New()

	..()
	new /obj/item/weapon/brutepack( src )
	new /obj/item/weapon/brutepack( src )
	new /obj/item/weapon/brutepack( src )
	new /obj/item/weapon/ointment( src )
	new /obj/item/weapon/ointment( src )
	new /obj/item/weapon/healthanalyzer( src )
	var/obj/item/weapon/syringe/S = new /obj/item/weapon/syringe( src )
	var/datum/chemical/rejuv/C = new /datum/chemical/rejuv( null )
	C.moles = C.density * 15 / C.molarmass
	S.chem.chemicals[text("[]", C.name)] = C
	S.icon_state = "syringe_15"
	return

/obj/item/weapon/storage/firstaid/toxin/New()

	..()
	new /obj/item/weapon/pill_canister/antitoxin( src )
	new /obj/item/weapon/pill_canister/antitoxin( src )
	var/t = null
	t = 1
	while(t <= 4)
		var/obj/item/weapon/syringe/S = new /obj/item/weapon/syringe( src )
		var/datum/chemical/pl_coag/C = new /datum/chemical/pl_coag( null )
		C.moles = C.density * 15 / C.molarmass
		S.chem.chemicals[text("[]", C.name)] = C
		S.icon_state = "syringe_15"
		t++
	new /obj/item/weapon/healthanalyzer( src )
	return

/obj/item/weapon/storage/firstaid/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (src.contents.len >= 7)
		return
	if ((W.w_class >= 2 || istype(W, /obj/item/weapon/storage)))
		return
	..()
	return

/obj/item/weapon/tile/New()

	src.pixel_x = rand(1, 14)
	src.pixel_y = rand(1, 14)
	return

/obj/item/weapon/tile/attack_hand(mob/user as mob)

	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/tile/F = new /obj/item/weapon/tile( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
	else
		..()
	return

/obj/item/weapon/tile/proc/build(turf/S as turf)
	var/turf/simulated/floor/W = S.ReplaceWithFloor()

	W.burnt = 1
	W.intact = 0
	W.buildlinks()
	W.levelupdate()
	W.icon_state = "Floor1"
	W.health = 100
	return

/obj/item/weapon/tile/attack_self(mob/user as mob)

	if (usr.stat)
		return
	var/T = user.loc
	if (!( istype(T, /turf) ))
		user << "\blue You must be on the ground!"
		return
	else
		var/S = T
		if (!( istype(S, /turf/space) ))
			user << "You cannot build on or repair this turf!"
			return
		else
			src.build(S)
			src.amount--
	if (src.amount < 1)
		user.u_equip(src)
		//SN src = null
		del(src)
		return
	src.add_fingerprint(user)
	return

/obj/item/weapon/tile/attackby(obj/item/weapon/tile/W as obj, mob/user as mob)

	if (!( istype(W, /obj/item/weapon/tile) ))
		return
	if (W.amount == 10)
		return
	W.add_fingerprint(user)
	if (W.amount + src.amount > 10)
		src.amount = W.amount + src.amount - 10
		W.amount = 10
	else
		W.amount += src.amount
		//SN src = null
		del(src)
		return
	return

/obj/item/weapon/tile/examine()
	set src in view(1)

	..()
	usr << text("There are [] tile\s left on the stack.", src.amount)
	return

/obj/item/weapon/igniter/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if ((istype(W, /obj/item/weapon/radio/signaler) && !( src.status )))
		var/obj/item/weapon/radio/signaler/S = W
		if (!( S.b_stat ))
			return
		var/obj/item/weapon/assembly/rad_ignite/R = new /obj/item/weapon/assembly/rad_ignite( user )
		S.loc = R
		R.part1 = S
		S.layer = initial(S.layer)
		if (user.client)
			user.client.screen -= S
		if (user.r_hand == S)
			user.u_equip(S)
			user.r_hand = R
		else
			user.u_equip(S)
			user.l_hand = R
		S.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part2 = src
		R.layer = 20
		R.loc = user
		src.add_fingerprint(user)

	else if ((istype(W, /obj/item/weapon/prox_sensor) && !( src.status )))

		var/obj/item/weapon/assembly/prox_ignite/R = new /obj/item/weapon/assembly/prox_ignite( user )
		W.loc = R
		R.part1 = W
		W.layer = initial(W.layer)
		if (user.client)
			user.client.screen -= W
		if (user.r_hand == W)
			user.u_equip(W)
			user.r_hand = R
		else
			user.u_equip(W)
			user.l_hand = R
		W.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part2 = src
		R.layer = 20
		R.loc = user
		src.add_fingerprint(user)

	else if ((istype(W, /obj/item/weapon/timer) && !( src.status )))

		var/obj/item/weapon/assembly/time_ignite/R = new /obj/item/weapon/assembly/time_ignite( user )
		W.loc = R
		R.part1 = W
		W.layer = initial(W.layer)
		if (user.client)
			user.client.screen -= W
		if (user.r_hand == W)
			user.u_equip(W)
			user.r_hand = R
		else
			user.u_equip(W)
			user.l_hand = R
		W.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part2 = src
		R.layer = 20
		R.loc = user
		src.add_fingerprint(user)


	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The igniter is ready!")
	else
		user.show_message("\blue The igniter can now be attached!")
	src.add_fingerprint(user)
	return

/obj/item/weapon/igniter/attack_self(mob/user as mob)

	src.add_fingerprint(user)
	spawn( 5 )
		ignite()
		return
	return

/obj/item/weapon/igniter/proc/ignite()

	if (src.status)
		var/turf/T = src.loc
		if (src.master)
			T = src.master.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		if (!( istype(T, /turf) ))
			return
		if (T.firelevel < 900000.0)
			T.firelevel = T.gas.plasma + T.gas.o2
	return

/obj/item/weapon/igniter/examine()
	set src in view()

	..()
	if ((get_dist(src, usr) <= 1 || src.loc == usr))
		if (src.status)
			usr.show_message("The igniter is ready!")
		else
			usr.show_message("The igniter can be attached!")
	return

/obj/item/weapon/radio/electropack/examine()
	set src in view()

	..()
	if ((get_dist(src, usr) <= 1 || src.loc == usr))
		if (src.e_pads)
			usr << "\blue The electric pads are exposed!"
	return

/obj/item/weapon/radio/electropack/attack_paw(mob/user as mob)

	return src.attack_hand(user)
	return

/obj/item/weapon/radio/electropack/attack_hand(mob/user as mob)

	if (src == user.back)
		user << "\blue You need help taking this off!"
		return
	else
		..()
	return

/obj/item/weapon/radio/electropack/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/screwdriver))
		src.e_pads = !( src.e_pads )
		if (src.e_pads)
			user.show_message("\blue The electric pads have been exposed!")
		else
			user.show_message("\blue The electric pads have been reinserted!")
		src.add_fingerprint(user)
	else
		if (istype(W, /obj/item/weapon/clothing/head/helmet))
			var/obj/item/weapon/assembly/shock_kit/A = new /obj/item/weapon/assembly/shock_kit( user )
			W.loc = A
			A.part1 = W
			W.layer = initial(W.layer)
			if (user.client)
				user.client.screen -= W
			if (user.r_hand == W)
				user.u_equip(W)
				user.r_hand = A
			else
				user.u_equip(W)
				user.l_hand = A
			W.master = A
			src.master = A
			src.layer = initial(src.layer)
			user.u_equip(src)
			if (user.client)
				user.client.screen -= src
			src.loc = A
			A.part2 = src
			A.layer = 20
			src.add_fingerprint(user)
			A.add_fingerprint(user)
	return

/obj/item/weapon/radio/electropack/Topic(href, href_list)
	//..()
	if (usr.stat || usr.restrained())
		return
	if (((istype(usr, /mob/human) && ((!( ticker ) || (ticker && ticker.mode != "monkey")) && usr.contents.Find(src))) || (usr.contents.Find(src.master) || (get_dist(src, usr) <= 1 && istype(src.loc, /turf)))))
		usr.machine = src
		if (href_list["freq"])
			src.freq += text2num(href_list["freq"])
			if (round(src.freq * 10, 1) % 2 == 0)
				src.freq += 0.1
			src.freq = min(148.9, src.freq)
			src.freq = max(144.1, src.freq)
		else
			if (href_list["code"])
				src.code += text2num(href_list["code"])
				src.code = round(src.code)
				src.code = min(100, src.code)
				src.code = max(1, src.code)
			else
				if (href_list["power"])
					src.on = !( src.on )
					src.icon_state = text("electropack[]", src.on)
		if (!( src.master ))
			if (istype(src.loc, /mob))
				attack_self(src.loc)
			else
				for(var/mob/M in viewers(1, src))
					if (M.client)
						src.attack_self(M)
					//Foreach goto(308)
		else
			if (istype(src.master.loc, /mob))
				src.attack_self(src.master.loc)
			else
				for(var/mob/M in viewers(1, src.master))
					if (M.client)
						src.attack_self(M)
					//Foreach goto(384)
	else
		usr << browse(null, "window=radio")
		return
	return

/obj/item/weapon/radio/electropack/accept_rad(obj/item/weapon/radio/signaler/R as obj, message)

	if ((istype(R, /obj/item/weapon/radio/signaler) && R.freq == src.freq && R.code == src.code))
		return 1
	else
		return null
	return

/obj/item/weapon/radio/electropack/r_signal()

	//*****
	//world << "electropack \ref[src] got signal: [src.loc] [on]"
	if ((ismob(src.loc) && src.on))

		var/mob/M = src.loc
		var/turf/T = M.loc
		if(istype(T, /turf))
			if (M.moved_recently && M.last_move)
				step(M, M.last_move)
		M.show_message("\red <B>You feel a sharp shock!</B>")


		if (M.weakened < 10)
			M.weakened = 10

	if ((src.master && src.wires & 1))
		src.master:r_signal(1)
	return

/obj/item/weapon/radio/electropack/attack_self(mob/user as mob, flag1)

	if (!( istype(user, /mob/human) ))
		return
	user.machine = src
	var/dat = text("<TT><A href='?src=\ref[];power=1'>[]</A><BR>\n<B>Frequency/Code</B> for electropack:<BR>\nFrequency: <A href='?src=\ref[];freq=-1'>-</A><A href='?src=\ref[];freq=-0.2'>-</A> [] <A href='?src=\ref[];freq=0.2'>+</A><A href='?src=\ref[];freq=1'>+</A><BR>\nCode: <A href='?src=\ref[];code=-5'>-</A><A href='?src=\ref[];code=-1'>-</A> [] <A href='?src=\ref[];code=1'>+</A><A href='?src=\ref[];code=5'>+</A><BR>\n</TT>", src, (src.on ? "Turn Off" : "Turn On"), src, src, src.freq, src, src, src, src, src.code, src, src)
	user << browse(dat, "window=radio")
	return

/obj/item/weapon/radio/proc/accept_rad(obj/item/weapon/radio/R as obj, message)

	if ((R.freq == src.freq && message))
		return 1
	else
		return null
	return

/obj/item/weapon/radio/proc/r_signal()

	return

/obj/item/weapon/radio/proc/send_crackle()

	if ((src.listening && src.wires & 2))
		return hearers(3, src.loc)
	return

/obj/item/weapon/radio/proc/sendm(msg)
	if(last_transmission && world.time < (last_transmission + TRANSMISSION_DELAY))
		return
	last_transmission = world.time
	if ((src.listening && src.wires & 2))
		return hearers(1, src.loc)
	return

/obj/item/weapon/radio/examine()
	set src in view()

	..()
	if ((get_dist(src, usr) <= 1 || src.loc == usr))
		if (src.b_stat)
			usr.show_message("\blue The radio can be attached and modified!")
		else
			usr.show_message("\blue The radio can not be modified or attached!")
	return

/obj/item/weapon/radio/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.machine = src
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.b_stat = !( src.b_stat )
	if (src.b_stat)
		user.show_message("\blue The radio can now be attached and modified!")
	else
		user.show_message("\blue The radio can no longer be modified or attached!")
	for(var/mob/M in viewers(1, src))
		if (M.client)
			src.attack_self(M)
		//Foreach goto(83)
	src.add_fingerprint(user)
	return

/obj/item/weapon/radio/beacon/hear_talk()
	return

/obj/item/weapon/radio/beacon/sendm()
	return null

/obj/item/weapon/radio/beacon/send_crackle()
	return null

/obj/item/weapon/radio/beacon/verb/alter_signal(t as text)
	set src in usr

	if ((usr.canmove && !( usr.restrained() )))
		src.code = t
	if (!( src.code ))
		src.code = "beacon"
	src.add_fingerprint(usr)
	return

/obj/item/weapon/radio/signaler/accept_rad(obj/item/weapon/radio/signaler/R as obj, message)
	if ((istype(R, /obj/item/weapon/radio/signaler) && R.freq == src.freq && R.code == src.code))
		return 1
	else
		return null
	return

/obj/item/weapon/radio/signaler/examine()
	set src in view()

	..()
	if ((get_dist(src, usr) <= 1 || src.loc == usr))
		if (src.b_stat)
			usr.show_message("\blue The signaler can be attached and modified!")
		else
			usr.show_message("\blue The signaler can not be modified or attached!")
	return

/obj/item/weapon/radio/signaler/attack_self(mob/user as mob, flag1)
	user.machine = src
	var/t1
	if ((src.b_stat && !( flag1 )))
		t1 = text("-------<BR>\nGreen Wire: []<BR>\nRed Wire:   []<BR>\nBlue Wire:  []<BR>\n", (src.wires & 4 ? text("<A href='?src=\ref[];wires=4'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=4'>Mend Wire</A>", src)), (src.wires & 2 ? text("<A href='?src=\ref[];wires=2'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=2'>Mend Wire</A>", src)), (src.wires & 1 ? text("<A href='?src=\ref[];wires=1'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=1'>Mend Wire</A>", src)))
	else
		t1 = "-------"
	var/dat = text("<TT>Speaker: []<BR>\n<A href='?src=\ref[];send=1'>Send Signal</A><BR>\n<B>Frequency/Code</B> for signaler:<BR>\nFrequency: <A href='?src=\ref[];freq=-1'>-</A><A href='?src=\ref[];freq=-0.2'>-</A> [] <A href='?src=\ref[];freq=0.2'>+</A><A href='?src=\ref[];freq=1'>+</A><BR>\nCode: <A href='?src=\ref[];code=-5'>-</A><A href='?src=\ref[];code=-1'>-</A> [] <A href='?src=\ref[];code=1'>+</A><A href='?src=\ref[];code=5'>+</A><BR>\n[]</TT>", (src.listening ? text("<A href='?src=\ref[];listen=0'>Engaged</A>", src) : text("<A href='?src=\ref[];listen=1'>Disengaged</A>", src)), src, src, src, src.freq, src, src, src, src, src.code, src, src, t1)
	user << browse(dat, "window=radio")
	return

/obj/item/weapon/radio/signaler/hear_talk()
	return

/obj/item/weapon/radio/signaler/sendm()
	return

/obj/item/weapon/radio/signaler/send_crackle()
	return

/obj/item/weapon/radio/signaler/r_signal(signal)
	if (!( src.wires & 2 ))
		return
	if(istype(src.loc, /obj/machinery/door/airlock) && src.airlock_wire && src.wires & 1)
//		world << "/obj/.../signaler/r_signal([signal]) has master = [src.master] and type [(src.master?src.master.type : "none")]"
//		world << "[src.airlock_wire] - [src] - [usr] - [signal]"
		var/obj/machinery/door/airlock/A = src.loc
		A.pulse(src.airlock_wire)
//		src.master:r_signal(signal)
	if(src.master && src.wires & 1)
		src.master:r_signal()
	for(var/mob/O in hearers(1, src.loc))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	return

/obj/item/weapon/radio/signaler/proc/s_signal(signal)
	if(last_transmission && world.time < (last_transmission + TRANSMISSION_DELAY))
		return
	last_transmission = world.time
	if (signal == null)
		signal = 1
	if (!( src.wires & 4 ))
		return

	var/time = time2text(world.realtime,"hh:mm:ss")

	lastsignalers.Add("[time] <B>:</B> [usr] used [src] @ location ([src.loc.x],[src.loc.y],[src.loc.z]) <B>:</B> [freq]/[code]")

	for(var/obj/item/weapon/radio/R in world)
		if (R.accept_rad(src))
			spawn( 0 )
				if (R)
					R.r_signal(signal)
				return
	return

/obj/item/weapon/radio/signaler/Topic(href, href_list)
	//..()
	if (usr.stat)
		return
	if ((usr.contents.Find(src) || (usr.contents.Find(src.master) || (get_dist(src, usr) <= 1 && istype(src.loc, /turf)))))
		usr.machine = src
		if (href_list["freq"])
			..()
			return
		else
			if (href_list["code"])
				src.code += text2num(href_list["code"])
				src.code = round(src.code)
				src.code = min(100, src.code)
				src.code = max(1, src.code)
			else
				if (href_list["send"])
					var/t1 = round(text2num(href_list["send"]))
					spawn( 0 )
						src.s_signal(t1)
						return
				else
					if (href_list["listen"])
						src.listening = text2num(href_list["listen"])
					else
						if (href_list["wires"])
							var/t1 = text2num(href_list["wires"])
							if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
								return
							if ((!( src.b_stat ) && !( src.master )))
								return
							if (t1 & 1)
								if (src.wires & 1)
									src.wires &= 65534
								else
									src.wires |= 1
							else
								if (t1 & 2)
									if (src.wires & 2)
										src.wires &= 65533
									else
										src.wires |= 2
								else
									if (t1 & 4)
										if (src.wires & 4)
											src.wires &= 65531
										else
											src.wires |= 4
		src.add_fingerprint(usr)
		if (!src.master)
			if (istype(src.loc, /mob))
				attack_self(src.loc)
			else
				for(var/mob/M in viewers(1, src))
					if (M.client)
						src.attack_self(M)
		else
			if (istype(src.master.loc, /mob))
				src.attack_self(src.master.loc)
			else
				for(var/mob/M in viewers(1, src.master))
					if (M.client)
						src.attack_self(M)
	else
		usr << browse(null, "window=radio")
		return
	return

/obj/item/weapon/radio/intercom/attack_ai(mob/user as mob)
	src.add_fingerprint(user)
	spawn( 0 )
		attack_self(user)
		return
	return

/obj/item/weapon/radio/intercom/attack_paw(mob/user as mob)

	if ((ticker && ticker.mode.name == "monkey"))
		return src.attack_hand(user)
	return

/obj/item/weapon/radio/intercom/attack_hand(mob/user as mob)

	src.add_fingerprint(user)
	spawn( 0 )
		attack_self(user)
		return
	return

/obj/item/weapon/radio/intercom/send_crackle()

	if (src.listening)
		return list(  )
	return

/obj/item/weapon/radio/intercom/sendm(msg)

	if (src.listening)
		return hearers(7, src.loc)
	return

/obj/item/weapon/radio/attack_self(mob/user as mob)
	user.machine = src
	var/t1
	if (src.b_stat)
		t1 = text("-------<BR>\nGreen Wire: []<BR>\nRed Wire:   []<BR>\nBlue Wire:  []<BR>\n", (src.wires & 4 ? text("<A href='?src=\ref[];wires=4'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=4'>Mend Wire</A>", src)), (src.wires & 2 ? text("<A href='?src=\ref[];wires=2'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=2'>Mend Wire</A>", src)), (src.wires & 1 ? text("<A href='?src=\ref[];wires=1'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=1'>Mend Wire</A>", src)))
	else
		t1 = "-------"
	var/dat = text("<TT>Microphone: []<BR>\nSpeaker: []<BR>\nFrequency: <A href='?src=\ref[];freq=-1'>-</A><A href='?src=\ref[];freq=-0.2'>-</A> [] <A href='?src=\ref[];freq=0.2'>+</A><A href='?src=\ref[];freq=1'>+</A><BR>\n[]</TT>", (src.broadcasting ? text("<A href='?src=\ref[];talk=0'>Engaged</A>", src) : text("<A href='?src=\ref[];talk=1'>Disengaged</A>", src)), (src.listening ? text("<A href='?src=\ref[];listen=0'>Engaged</A>", src) : text("<A href='?src=\ref[];listen=1'>Disengaged</A>", src)), src, src, src.freq, src, src, t1)
	user << browse(dat, "window=radio")
	return

/obj/item/weapon/radio/Topic(href, href_list)
	//..()
	if (usr.stat)
		return
	if ((usr.contents.Find(src) || get_dist(src, usr) <= 1 && istype(src.loc, /turf)) || (istype(usr, /mob/ai)))
		usr.machine = src
		if (href_list["freq"])
			src.freq += text2num(href_list["freq"])
			if (round(src.freq * 10, 1) % 2 == 0)
				src.freq += 0.1
			src.freq = min(148.9, src.freq)
			src.freq = max(144.1, src.freq)
			if (src.traitorfreq && round(src.freq * 10, 1) == round(src.traitorfreq * 10, 1))
				usr.machine = null
				usr << browse(null, "window=radio")
				// now transform the regular radio, into a (disguised)syndicate uplink!
				var/obj/item/weapon/syndicate_uplink/T = src.traitorradio
				var/obj/item/weapon/radio/R = src
				R.loc = T
				T.loc = usr
				R.layer = 0
				if (usr.client)
					usr.client.screen -= R
				if (usr.r_hand == R)
					usr.u_equip(R)
					usr.r_hand = T
				else
					usr.u_equip(R)
					usr.l_hand = T
				R.loc = T
				T.layer = 20
				T.attack_self(usr)
				return
		else
			if (href_list["talk"])
				src.broadcasting = text2num(href_list["talk"])
			else
				if (href_list["listen"])
					src.listening = text2num(href_list["listen"])
				else
					if (href_list["wires"])
						var/t1 = text2num(href_list["wires"])
						if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
							return
						if (t1 & 1)
							if (src.wires & 1)
								src.wires &= 65534
							else
								src.wires |= 1
						else
							if (t1 & 2)
								if (src.wires & 2)
									src.wires &= 65533
								else
									src.wires |= 2
							else
								if (t1 & 4)
									if (src.wires & 4)
										src.wires &= 65531
									else
										src.wires |= 4
		if (!( src.master ))
			if (istype(src.loc, /mob))
				attack_self(src.loc)
			else
				src.updateDialog()
		else
			if (istype(src.master.loc, /mob))
				src.attack_self(src.master.loc)
			else
				src.updateDialog()
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=radio")
		return
	return

/obj/item/weapon/radio/talk_into(mob/M as mob, msg)
	if (!( src.wires & 4 ))
		return
	var/list/receive = list(  )
	var/list/crackle = list(  )
	for(var/obj/item/weapon/radio/R in world)
		if (((src.freq == 0 || R.accept_rad(src, msg)) && src.freq != 5))
			for(var/i in R.sendm(msg))
				receive -= i
				receive += i
			for(var/i in R.send_crackle())
				crackle -= i
				crackle += i
	for(var/i in receive)
		crackle -= i
	for(var/mob/O in crackle)
		O.show_message(text("\icon[] <I>Crackle,Crackle</I>", src), 2)
	if (istype(M, /mob/human) || (istype(M, /mob/ai)))
		for(var/mob/O in receive)
			if (istype(O, /mob/human) || (istype(O, /mob/ai)))
				O.show_message(text("<B>[]-\icon[]\[[]\]-broadcasts</B>: <I>[]</I>", M.rname, src, src.freq, msg), 2)
			else
				O.show_message(text("<B>[]-\icon[]\[[]\]-broadcasts</B>: <I>[]</I>", M.rname, src, src.freq, stars(msg)), 2)
		if (src.freq == 5)
			for(var/mob/O in receive)
				if (istype(O, /mob/human) || (istype(O, /mob/ai)))
					O.show_message(text("<B>[]-\icon[]\[[]\]-broadcasts (over PA)</B>: <I>[]</I>", M.rname, src, src.freq, msg), 2)
				else
					O.show_message(text("<B>[]-\icon[]\[[]\]-broadcasts (over PA)</B>: <I>[]</I>", M.rname, src, src.freq, stars(msg)), 2)
	else
		for(var/mob/O in receive)
			if (istype(O, M))
				O.show_message(text("<B>The monkey-\icon[]\[[]\]-broadcasts</B>: <I>[]</I>", src, src.freq, msg), 2)
			else
				O.show_message(text("<B>The monkey-\icon[]\[[]\]-broadcasts</B>: chimpering", src, src.freq), 2)
		if (src.freq == 5)
			for(var/mob/O in receive)
				if (istype(O, M))
					O.show_message(text("<B>The monkey-\icon[]\[[]\]-broadcasts (over PA)</B>: <I>[]</I>", src, src.freq, msg), 2)
				else
					O.show_message(text("<B>The monkey-\icon[]\[[]\]-broadcasts (over PA)</B>: chimpering", src, src.freq), 2)
	return

/obj/item/weapon/radio/hear_talk(mob/M as mob, msg)
	if (src.broadcasting)
		talk_into(M, msg)
	return

/obj/item/weapon/shard/Bump()

	spawn( 0 )
		if (prob(20))
			src.force = 15
		else
			src.force = 4
		..()
		return
	return

/obj/item/weapon/shard/New()

	//****RM
	//world<<"New shard at [x],[y],[z]"

	src.icon_state = pick("large", "medium", "small")
	switch(src.icon_state)
		if("small")
			src.pixel_x = rand(1, 18)
			src.pixel_y = rand(1, 18)
		if("medium")
			src.pixel_x = rand(1, 16)
			src.pixel_y = rand(1, 16)
		if("large")
			src.pixel_x = rand(1, 10)
			src.pixel_y = rand(1, 5)
		else
	return

/obj/item/weapon/shard/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (!( istype(W, /obj/item/weapon/weldingtool) ))
		return
	new /obj/item/weapon/sheet/glass( user.loc )
	//SN src = null
	del(src)
	return

/obj/item/weapon/Bump(mob/M as mob)
	spawn( 0 )
		..()
		if (src.throwing)
			src.throwing = 0
			src.density = 0
			if (istype(M, /obj))
				var/obj/O = M
				for(var/mob/B in viewers(M, null))
					B.show_message(text("\red [] has been hit by [].", M, src), 1)
				O.hitby(src)
			if (!( istype(M, /mob) ))
				return
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] has been hit by [].", M, src), 1)
			if (M.health > -100.0)
				if (istype(M, /mob/human))
					var/mob/human/H = M
					var/dam_zone = pick("chest", "diaper", "head")
					if (H.organs[text("[]", dam_zone)])
						var/obj/item/weapon/organ/external/affecting = H.organs[text("[]", dam_zone)]
						if (affecting.take_damage(src.throwforce, 0))
							H.UpdateDamageIcon()
						else
							H.UpdateDamage()
				else
					M.bruteloss += src.throwforce
				M.updatehealth()
		return
	return

/obj/item/weapon/wrench/New()
	if (prob(75))
		src.pixel_x = rand(0, 16)
	return

/obj/item/weapon/screwdriver/New()
	if (prob(75))
		src.pixel_y = rand(0, 16)
	return

/obj/item/weapon/screwdriver/attack(mob/M as mob, mob/user as mob)
	if(!istype(M, /mob))
		return

	src.add_fingerprint(user)
	if(!(user.zone_sel.selecting == ("eyes" || "head")))
		return ..()
	var/mob/human/H = M
	if(istype(M, /mob/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		user << "\blue You're going to need to remove that mask/helmet/glasses first."
		return
	for(var/mob/O in viewers(M, null))
		if(O == (user || M))	continue
		if(M == user)	O.show_message(text("\red [] has stabbed themself with []!", user, src), 1)
		else	O.show_message(text("\red [] has been stabbed in the eye with [] by [].", M, src, user), 1)
	if(M != user)
		M << "\red [user] stabs you in the eye with [src]!"
		user << "\red You stab [M] in the eye with [src]!"
	else
		user << "\red You stab yourself in the eyes with [src]!"
	if(istype(M, /mob/human))
		var/obj/item/weapon/organ/external/affecting = M.organs["head"]
		affecting.take_damage(7)
	else
		M.bruteloss += 7
	M.eye_blurry += rand(3,4)
	M.eye_stat += rand(2,4)
	if (M.eye_stat >= 10)
		M << "\red Your eyes start to bleed profusely!"
		M.eye_blurry += 15+(0.1*M.eye_blurry)
		M.disabilities |= 1
		if(M.stat == 2)	return
		if(prob(50))
			M << "\red You drop what you're holding and clutch at your eyes!"
			M.eye_blurry += 10
			M.paralysis += 1
			M.weakened += 4
			M.drop_item()
		if (prob(M.eye_stat - 10 + 1))
			M << "\red You go blind!"
			M.sdisabilities |= 1
	return

/obj/item/weapon/dropper/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/dropper/attack_hand()
	..()
	src.update_is()
	return

/obj/item/weapon/dropper/proc/update_is()
	var/t1 = round(src.chem.volume())
	if (istype(src.loc, /mob))
		if (src.mode == "inject")
			src.icon_state = text("dropper_[]_I", t1)
		else
			src.icon_state = text("dropper_[]_d", t1)
	else
		src.icon_state = text("dropper_[]", t1)
	src.s_istate = "dropper"
	return

/obj/item/weapon/dropper/dropped()
	..()
	src.update_is()
	return

/obj/item/weapon/dropper/attack_self()
	if (src.mode == "inject")
		src.mode = "draw"
	else
		src.mode = "inject"
	src.update_is()
	return

/obj/item/weapon/dropper/New()

	src.chem = new /obj/substance/chemical(  )
	src.chem.maximum = 5
	..()
	return

/obj/item/weapon/dropper/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob))
		return
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return
	if(!src.chem.volume())
		user << "\red The dropper is empty!"
		return
	if (user)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red [] has been eyedropped with [] by [].", M, src, user), 1)
		var/amount = src.chem.dropper_mob(M, 1)
		src.update_is()
		user.show_message(text("\red You drop [] units into []'s eyes. The dropper contains [] millimeters.", amount, M, src.chem.volume()))
		src.add_fingerprint(user)
	return

/obj/item/weapon/implantcase/proc/update()
	if (src.imp)
		src.icon_state = text("implantcase-[]", src.imp.color)
	else
		src.icon_state = "implantcase-0"
	return

/obj/item/weapon/implantcase/attackby(obj/item/weapon/I as obj, mob/user as mob)
	if (istype(I, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if (user.equipped() != I)
			return
		if ((get_dist(src, usr) > 1 && src.loc != user))
			return
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		if (t)
			src.name = text("Glass Case- '[]'", t)
		else
			src.name = "Glass Case"
	else
		if (!( istype(I, /obj/item/weapon/implanter) ))
			return
	if (I:imp)
		if ((src.imp || I:imp.implanted))
			return
		I:imp.loc = src
		src.imp = I:imp
		I:imp = null
		src.update()
		I:update()
	else
		if (src.imp)
			if (I:imp)
				return
			src.imp.loc = I
			I:imp = src.imp
			src.imp = null
			update()
			I:update()
	return

/obj/item/weapon/implantcase/tracking/New()

	src.imp = new /obj/item/weapon/implant/tracking( src )
	..()
	return

/obj/item/weapon/implantpad/proc/update()

	if (src.case)
		src.icon_state = "implantpad-1"
	else
		src.icon_state = "implantpad-0"
	return

/obj/item/weapon/implantpad/attack_hand(mob/user as mob)

	if ((src.case && (user.l_hand == src || user.r_hand == src)))
		if (user.hand)
			user.l_hand = src.case
		else
			user.r_hand = src.case
		src.case.loc = user
		src.case.layer = 20
		src.case.add_fingerprint(user)
		src.case = null
		user.UpdateClothing()
		src.add_fingerprint(user)
		update()
	else
		if (user.contents.Find(src))
			spawn( 0 )
				src.attack_self(user)
				return
		else
			return ..()
	return

/obj/item/weapon/implantpad/attackby(obj/item/weapon/implantcase/C as obj, mob/user as mob)

	if (istype(C, /obj/item/weapon/implantcase))
		if (!( src.case ))
			user.drop_item()
			C.loc = src
			src.case = C
	else
		return
	src.update()
	return

/obj/item/weapon/implantpad/attack_self(mob/user as mob)

	user.machine = src
	var/dat = "<B>Implant Mini-Computer:</B><HR>"
	if (src.case)
		if (src.case.imp)
			if (istype(src.case.imp, /obj/item/weapon/implant/tracking))
				var/obj/item/weapon/implant/tracking/T = src.case.imp
				dat += text("<b>Implant Specifications:</b><BR>\n<b>Name:</b> Tracking Beacon<BR>\n<b>Zone:</b> Spinal Column> 2-5 vertebrae<BR>\n<b>Power Source:</b> Nervous System Ion Withdrawl Gradient<BR>\n<b>Life:</b> 10 minutes after death of host<BR>\n<b>Important Notes:</b> None<BR>\n<HR>\n<b>Implant Details:</b> <BR>\n<b>Function:</b> Continuously transmits low power signal on frequency- Useful for tracking.<BR>\nRange: 35-40 meters<BR>\n<b>Special Features:</b><BR>\n<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if\na malfunction occurs thereby securing safety of subject. The implant will melt and\ndisintegrate into bio-safe elements.<BR>\n<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the\ncircuitry. As a result neurotoxins can cause massive damage.<HR>\nImplant Specifics:\nFrequency (144.1-148.9): <A href='?src=\ref[];freq=-1'>-</A><A href='?src=\ref[];freq=-0.2'>-</A> [] <A href='?src=\ref[];freq=0.2'>+</A><A href='?src=\ref[];freq=1'>+</A><BR>\nID (1-100): <A href='?src=\ref[];id=-10'>-</A><A href='?src=\ref[];id=-1'>-</A> [] <A href='?src=\ref[];id=1'>+</A><A href='?src=\ref[];id=10'>+</A><BR>", src, src, T.freq, src, src, src, src, T.id, src, src)
			else
				if (istype(src.case.imp, /obj/item/weapon/implant/freedom))
					dat += "<b>Implant Specifications:</b><BR>\n<b>Name:</b> Freedom Beacon<BR>\n<b>Zone:</b> Right Hand> Near wrist<BR>\n<b>Power Source:</b> Lithium Ion Battery<BR>\n<b>Life:</b> optimum 5 uses<BR>\n<b>Important Notes: <font color='red'>Illegal</font></b><BR>\n<HR>\n<b>Implant Details:</b> <BR>\n<b>Function:</b> Transmits a specialized cluster of signals to override handcuff locking\nmechanisms<BR>\n<b>Special Features:</b><BR>\n<i>Neuro-Scan</i>- Analyzes certain shadow signals in the nervous system along the dark\njoy sectors which respond mainly to chuckling<BR>\n<b>Integrity:</b> The battery is extremely weak and commonly after injection its\nlife can drive down to only 1 use.<HR>\nNo Implant Specifics"
				else
					dat += "Implant ID not in database"
		else
			dat += "The implant casing is empty."
	else
		dat += "Please insert an implant casing!"
	user << browse(dat, "window=implantpad")
	return

/obj/item/weapon/implantpad/Topic(href, href_list)
	..()
	if (usr.stat)
		return
	if ((usr.contents.Find(src) || (get_dist(src, usr) <= 1 && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["freq"])
			if ((istype(src.case, /obj/item/weapon/implantcase) && istype(src.case.imp, /obj/item/weapon/implant/tracking)))
				var/obj/item/weapon/implant/tracking/T = src.case.imp
				T.freq += text2num(href_list["freq"])
				if (round(T.freq * 10, 1) % 2 == 0)
					T.freq += 0.1
				T.freq = min(148.9, T.freq)
				T.freq = max(144.1, T.freq)
		if (href_list["id"])
			if ((istype(src.case, /obj/item/weapon/implantcase) && istype(src.case.imp, /obj/item/weapon/implant/tracking)))
				var/obj/item/weapon/implant/tracking/T = src.case.imp
				T.id += text2num(href_list["id"])
				T.id = min(100, T.id)
				T.id = max(1, T.id)
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
				//Foreach goto(290)
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=implantpad")
		return
	return

/obj/item/weapon/implant/proc/trigger(emote, source as mob)

	return

/obj/item/weapon/implant/freedom/New()

	src.uses = rand(1, 5)
	..()
	return

/obj/item/weapon/implant/freedom/trigger(emote, mob/source as mob)

	if (src.uses < 1)
		return 0
	if (emote == "chuckle")
		src.uses--
		if (source.handcuffed)
			var/obj/item/weapon/W = source.handcuffed
			source.handcuffed = null
			if (source.client)
				source.client.screen -= W
			if (W)
				W.loc = source.loc
				dropped(source)
				if (W)
					W.layer = initial(W.layer)
	return

/obj/item/weapon/implanter/proc/update()

	if (src.imp)
		src.icon_state = "implanter1"
	else
		src.icon_state = "implanter0"
	return

/obj/item/weapon/implanter/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob))
		return
	if (user && src.imp)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red [] has been implanted by [].", M, user), 1)
			//Foreach goto(48)
		src.imp.loc = M
		src.imp.implanted = 1
		src.imp = null
		user.show_message(text("\red You implanted the implant into the [].", M))
		src.icon_state = "implanter0"
	return

/obj/item/weapon/syringe/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/syringe/attack_hand()
	..()
	src.update_is()
	return

/obj/item/weapon/syringe/proc/update_is()
	var/t1 = round(src.chem.volume(), 5)
	if (istype(src.loc, /mob))
		if (src.mode == "inject")
			src.icon_state = text("syringe_[]_I", t1)
		else
			src.icon_state = text("syringe_[]_d", t1)
	else
		src.icon_state = text("syringe_[]", t1)
	src.s_istate = text("syringe_[]", t1)
	return

/obj/item/weapon/syringe/proc/inject(mob/M as mob)
	var/amount = 5
	var/volume = src.chem.volume()
	if (volume < 0.01)
		return
	else
		if (volume < 5.01)
			amount = volume - 0.01
	amount = src.chem.transfer_mob(M, amount)
	src.update_is()
	return amount

/obj/item/weapon/syringe/dropped()
	..()
	src.update_is()
	return

/obj/item/weapon/syringe/attack_self()
	if (src.mode == "inject")
		src.mode = "draw"
	else
		src.mode = "inject"
	src.update_is()
	return

/obj/item/weapon/syringe/New()
	src.chem = new /obj/substance/chemical(  )
	src.chem.maximum = 15
	..()
	return

/obj/item/weapon/syringe/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob))
		return
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return
	if (!src.chem.volume())
		user << "\red The syringe is empty!"
		return
	if (user)
		if (istype(M, /mob/human))
			var/obj/equip_e/human/O = new /obj/equip_e/human(  )
			O.source = user
			O.target = M
			O.item = src
			O.s_loc = user.loc
			O.t_loc = M.loc
			O.place = "syringe"
			M.requests += O
			spawn( 0 )
				O.process()
				return
		else
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] has been injected with [] by [].", M, src, user), 1)
				//Foreach goto(192)
			var/amount = src.chem.transfer_mob(M, 5)
			src.update_is()

			user.show_message(text("\red You inject [] units into the []. The syringe contains [] millimeters.", amount, M, src.chem.volume()))
	return

/obj/item/weapon/brutepack/attack_hand(mob/user as mob)

	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/brutepack/F = new /obj/item/weapon/brutepack( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
	else
		..()
	return

/obj/item/weapon/brutepack/attack(mob/M as mob, mob/user as mob)

	if (M.health < 0)
		return
	if (!(istype(user, /mob/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	if (user)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red [] has been applied with [] by []", M, src, user), 1)
	if (istype(M, /mob/human))
		var/mob/human/H = M
		var/obj/item/weapon/organ/external/affecting = H.organs["chest"]
		if (istype(user, /mob/human))
			var/mob/human/user2 = user
			var/t = user2.zone_sel.selecting
			if ((t in list( "hair", "eyes", "mouth", "neck" )))
				t = "head"
			if (H.organs[text("[]", t)])
				affecting = H.organs[text("[]", t)]
		else
			if ((!( istype(affecting, /obj/item/weapon/organ/external) ) || affecting:burn_dam <= 0))
				affecting = H.organs["head"]
				if ((!( istype(affecting, /obj/item/weapon/organ/external) ) || affecting:burn_dam <= 0))
					affecting = H.organs["diaper"]
		if (affecting.heal_damage(60, 0))
			H.UpdateDamageIcon()
		else
			H.UpdateDamage()
	M.updatehealth()
	src.amount--
	return

/obj/item/weapon/brutepack/examine()
	set src in view(1)

	..()
	usr << text("\blue there are [] bruise pack\s left on the stack!", src.amount)
	if (src.amount <= 0)
		//SN src = null
		del(src)
		return
	return

/obj/item/weapon/brutepack/attackby(obj/item/weapon/brutepack/W as obj, mob/user as mob)

	if (!( istype(W, /obj/item/weapon/brutepack) ))
		return
	if (src.amount == 5)
		return
	if (W.amount + src.amount > 5)
		src.amount = 5
		W.amount = W.amount + src.amount - 5
	else
		src.amount += W.amount
		//W = null
		del(W)
	return

/obj/item/weapon/hand_tele/attack_self(mob/user as mob)
	var/list/L = list(  )
	for(var/obj/machinery/teleport/hub/R in world)
		var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(R.x - 2, R.y, R.z))
		if (istype(com, /obj/machinery/computer/teleporter) && com.locked)
			if(R.icon_state == "tele1")
				L["[com.id] (Active)"] = com.locked
			else
				L["[com.id] (Inactive)"] = com.locked
	var/list/turfs = list(	)
	for(var/turf/T in orange(10))
		if(T.x>world.maxx-4 || T.x<4)	continue	//putting them at the edge is dumb
		if(T.y>world.maxy-4 || T.y<4)	continue
		turfs += T
	if(turfs)	L["None (Dangerous)"] = pick(turfs)
	var/t1 = input(user, "Please select a teleporter to lock in on.", "Hand Teleporter") in L
	if ((user.equipped() != src || user.stat || user.restrained()))
		return
	var/count = 0	//num of portals from this teleport in world
	for(var/obj/portal/PO in world)
		if(PO.creator == src)	count++
	if(count >= 3)
		user.show_message("\red The hand teleporter is recharging!")
		return
	var/T = L[t1]
	for(var/mob/O in hearers(user, null))
		O.show_message("\blue Locked In", 2)
	var/obj/portal/P = new /obj/portal( get_turf(src) )
	P.target = T
	P.creator = src
	src.add_fingerprint(user)
	return

/obj/item/weapon/ointment/attack_hand(mob/user as mob)
	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/ointment/F = new /obj/item/weapon/ointment( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
	else
		..()
	return

/obj/item/weapon/ointment/attack(mob/M as mob, mob/user as mob)

	if (M.health < 0)
		return
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	if (user)
		for(var/mob/O in viewers(M, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red [] has been applied with [] by []", M, src, user), 1)
			//Foreach goto(89)
	if (istype(M, /mob/human))
		var/mob/human/H = M
		var/obj/item/weapon/organ/external/affecting = H.organs["chest"]
		if (istype(user, /mob/human))
			var/mob/user2 = user
			var/t = user2.zone_sel.selecting
			if ((t in list( "hair", "eyes", "mouth", "neck" )))
				t = "head"
			if (H.organs[text("[]", t)])
				affecting = H.organs[text("[]", t)]
		else
			if ((!( istype(affecting, /obj/item/weapon/organ/external) ) || affecting.burn_dam <= 0))
				affecting = H.organs["head"]
				if ((!( istype(affecting, /obj/item/weapon/organ/external) ) || affecting.burn_dam <= 0))
					affecting = H.organs["diaper"]
		if (affecting.heal_damage(0, 40))
			H.UpdateDamageIcon()
		else
			H.UpdateDamage()
	src.amount--
	if (src.amount <= 0)
		//SN src = null
		del(src)
		return
	return

/obj/item/weapon/ointment/examine()
	set src in view(1)

	usr << text("\blue there are [] ointment pack\s left on the stack!", src.amount)
	return

/obj/item/weapon/ointment/attackby(obj/item/weapon/ointment/W as obj, mob/user as mob)

	if (!( istype(W, /obj/item/weapon/ointment) ))
		return
	if (W.amount == 5)
		return
	if (W.amount + src.amount > 5)
		src.amount = W.amount + src.amount - 5
		W.amount = 5
	else
		W.amount += W.amount
		//SN src = null
		del(src)
		return
	return

/obj/item/weapon/bottle/examine()
	set src in usr

	usr << text("\blue The bottle \icon[] contains [] millimeters of chemicals", src, round(src.chem.volume(), 0.1))
	return

/obj/item/weapon/bottle/New()

	src.chem = new /obj/substance/chemical(  )
	..()
	return

/obj/item/weapon/bottle/attackby(obj/item/weapon/B as obj, mob/user as mob)

	if (istype(B, /obj/item/weapon/bottle))
		var/t1 = src.chem.maximum
		var/volume = src.chem.volume()
		if (volume < 0.1)
			return
		else
			t1 = volume - 0.1
		t1 = src.chem.transfer_from(B:chem, t1)
		if (t1)
			user.show_message(text("\blue You pour [] unit\s into the bottle. The bottle now contains [] millimeters.", round(t1, 0.1), round(src.chem.volume(), 0.1)))
	if (istype(B, /obj/item/weapon/syringe))
		if (B:mode == "inject")
			var/t1 = 5
			var/volume = src.chem.volume()
			if (volume < 0.01)
				return
			else
				if (volume < 5.01)
					t1 = volume - 0.01
			t1 = src.chem.transfer_from(B:chem, t1)
			B:update_is()
			if (t1)
				user.show_message(text("\blue You inject [] unit\s into the bottle. The syringe contains [] units.", round(t1, 0.1), round(B:chem.volume(), 0.1)))
		else
			var/t1 = 5
			var/volume = src.chem.volume()
			if (volume < 0.05)
				return
			else
				if (volume < 5.05)
					t1 = volume - 0.05
			t1 = B:chem.transfer_from(src.chem, t1)
			B:update_is()
			if (t1)
				user.show_message(text("\blue You draw [] unit\s from the bottle. The syringe contains [] units.", round(t1, 0.1), round(B:chem.volume(), 0.1)))
		src.add_fingerprint(user)
	else
		if (istype(B, /obj/item/weapon/dropper))
			if (B:mode == "inject")
				var/t1 = 1
				var/volume = src.chem.volume()
				if (volume < 0.0050)
					return
				else
					if (volume < 1.005)
						t1 = volume - 0.0050
				t1 = src.chem.transfer_from(B:chem, t1)
				B:update_is()
				if (t1)
					user.show_message(text("\blue You deposit [] unit\s into the bottle. The dropper contains [] units.", round(t1, 0.1), round(B:chem.volume(), 0.1)))
			else
				var/t1 = 1
				var/volume = src.chem.volume()
				if (volume < 0.0050)
					return
				else
					if (volume < 1.005)
						t1 = volume - 0.0050
				t1 = B:chem.transfer_from(src.chem, t1)
				B:update_is()
				if (t1)
					user.show_message(text("\blue You extract [] unit\s from the bottle. The dropper contains [] units.", round(t1, 0.1), round(B:chem.volume(), 0.1)))
	return

/obj/item/weapon/bottle/toxins/New()

	..()
	src.chem.maximum = 60
	var/datum/chemical/l_plas/C = new /datum/chemical/l_plas( null )
	C.moles = C.density * 50 / C.molarmass
	src.chem.chemicals[text("[]", C.name)] = C
	return

/obj/item/weapon/bottle/antitoxins/New()

	..()
	src.chem.maximum = 60
	var/datum/chemical/pl_coag/C = new /datum/chemical/pl_coag( null )
	C.moles = C.density * 50 / C.molarmass
	src.chem.chemicals[text("[]", C.name)] = C
	return

/obj/item/weapon/bottle/r_epil/New()

	..()
	src.chem.maximum = 60
	var/datum/chemical/epil/C = new /datum/chemical/epil( null )
	C.moles = C.density * 50 / C.molarmass
	src.chem.chemicals[text("[]", C.name)] = C
	return

/obj/item/weapon/bottle/r_ch_cough/New()

	..()
	src.chem.maximum = 60
	var/datum/chemical/ch_cou/C = new /datum/chemical/ch_cou( null )
	C.moles = C.density * 50 / C.molarmass
	src.chem.chemicals[text("[]", C.name)] = C
	return

/obj/item/weapon/bottle/rejuvenators/New()

	..()
	src.chem.maximum = 60
	var/datum/chemical/rejuv/C = new /datum/chemical/rejuv( null )
	C.moles = C.density * 50 / C.molarmass
	src.chem.chemicals[text("[]", C.name)] = C
	return

/obj/item/weapon/bottle/s_tox/New()

	..()
	src.chem.maximum = 60
	var/datum/chemical/s_tox/C = new /datum/chemical/s_tox( null )
	C.moles = C.density * 50 / C.molarmass
	src.chem.chemicals[text("[]", C.name)] = C
	return

/obj/item/weapon/bottle/New()

	..()
	src.pixel_y = rand(-8.0, 8)
	src.pixel_x = rand(-8.0, 8)
	return

// welding tool functions ported from unstable r386

/obj/item/weapon/weldingtool/examine()
	set src in usr

	usr << text("\icon[] [] contains [] units of fuel left!", src, src.name, src.weldfuel)
	return

/obj/item/weapon/weldingtool/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/obj/item/weapon/igniter/I = W
	if (status == 0 && istype(W,/obj/item/weapon/screwdriver))
		status = 1
		user << "\blue The welder can now be attached and modified."
	else if (status == 1 && istype(W,/obj/item/weapon/rods))
		var/obj/item/weapon/rods/R = W
		R.amount = R.amount - 1
		if (R.amount == 0)
			del(R)
		status = 2
		welding = 0
		src.force = 3
		src.damtype = "brute"
		name =  "Welder/Rods Assembly"
		icon_state = "welder2"
		s_istate = "welder"
	else if (status == 2 && istype(I,/obj/item/weapon/igniter) && !I.status)
		del(I)
		status = 3
		name = "Welder/Rods/Igniter Assembly"
		icon_state = "welder3"
	else if (status == 3 && istype(W,/obj/item/weapon/screwdriver))
		var/obj/item/weapon/flamethrower/F = new /obj/item/weapon/flamethrower(user)
		if (user.r_hand == src)
			user.u_equip(src)
			user.r_hand = F
		else
			user.u_equip(src)
			user.l_hand = F
		F.layer = 20
		del(src)
		return

/obj/item/weapon/weldingtool/afterattack(O as obj, mob/user as mob)
	if (src.welding)
		src.weldfuel--
		if (src.weldfuel <= 0)
			usr << "\blue Need more fuel!"
			src.welding = 0
			src.force = 3
			src.damtype = "brute"
			src.icon_state = "welder"
		var/turf/location = user.loc
		if (!istype(location, /turf))
			return
		location.firelevel = location.gas.plasma + 1
	return

/obj/item/weapon/weldingtool/attack_self(mob/user as mob)
	if(status > 1)	return
	src.welding = !( src.welding )
	if (src.welding)
		if (src.weldfuel <= 0)
			user << "\blue Need more fuel!"
			src.welding = 0
			return 0
		user << "\blue You will now weld when you attack."
		src.force = 15
		src.damtype = "fire"
		src.icon_state = "welder1"
		spawn() //start fires while it's lit
			src.process()
	else
		user << "\blue Not welding anymore."
		src.force = 3
		src.damtype = "brute"
		src.icon_state = "welder"
	return

/obj/item/weapon/weldingtool/var/processing = 0

/obj/item/weapon/weldingtool/proc/process()
	if(src.processing) //already doing this
		return
	src.processing = 1

	while(src.welding)
		var/turf/location = src.loc
		if(istype(location, /mob/))
			var/mob/M = location
			if(M.l_hand == src || M.r_hand == src)
				location = M.loc

		if(isturf(location)) //start a fire if possible
			location.firelevel = max(location.firelevel, location.gas.plasma + 1)

		sleep(10)
	processing = 0	//we're done

/obj/manifest/New()

	src.invisibility = 100
	return

/obj/manifest/proc/manifest()
	var/dat = "<B>Crew Manifest</B>:<BR>"
	for(var/mob/human/M in world)
		if (M.start)
			dat += text("    <B>[]</B> -  []<BR>", M.name, (istype(M.wear_id, /obj/item/weapon/card/id) ? text("[]", M.wear_id.assignment) : "Unknown Position"))
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
	P.info = dat
	P.name = "paper- 'Crew Manifest'"
	//SN src = null
	del(src)
	return

/obj/screen/close/DblClick()
	if (src.master)
		src.master:close(usr)
	return

/obj/screen/storage/attackby(W, mob/user as mob)
	src.master.attackby(W, user)
	return

/obj/bedsheetbin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/bedsheet))
		//W = null
		del(W)
		src.amount++
	return

/obj/bedsheetbin/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/bedsheetbin/attack_hand(mob/user as mob)
	if (src.amount >= 1)
		src.amount--
		new /obj/item/weapon/bedsheet( src.loc )
		add_fingerprint(user)
	return

/obj/bedsheetbin/examine()
	set src in oview(1)

	src.amount = round(src.amount)
	if (src.amount <= 0)
		src.amount = 0
		usr << "There are no bed sheets in the bin."
	else
		if (src.amount == 1)
			usr << "There is one bed sheet in the bin."
		else
			usr << text("There are [] bed sheets in the bin.", src.amount)
	return

/obj/table/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		if(3.0)
			if (prob(25))
				src.density = 0
		else
	return

/obj/table/blob_act()

	if(prob(50))
		new /obj/item/weapon/table_parts( src.loc )
		del(src)

/obj/table/hand_p(mob/user as mob)

	return src.attack_paw(user)
	return

/obj/table/attack_paw(mob/user as mob)

	if (!( locate(/obj/table, user.loc) ))
		step(user, get_dir(user, src))
		if (user.loc == src.loc)
			user.layer = TURF_LAYER
			for(var/mob/M in viewers(user, null))
				M.show_message("The monkey hides under the table!", 1)
				//Foreach goto(69)
	return

/obj/table/CheckPass(atom/movable/O as mob|obj, target as turf)

	if ((O.flags & 2 || istype(O, /obj/meteor)))
		return 1
	else
		return 0
	return

/obj/table/MouseDrop_T(obj/O as obj, mob/user as mob)

	if ((!( istype(O, /obj/item/weapon) ) || user.equipped() != O))
		return
	user.drop_item()
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/table/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/weapon/table_parts( src.loc )
		//SN src = null
		del(src)
		return
	user.drop_item()
	if(W && W.loc)	W.loc = src.loc
	return

/obj/rack/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(25))
				src.icon_state = "rackbroken"
				src.density = 0
		else
	return

/obj/rack/blob_act()
	if(prob(50))
		del(src)
		return
	else if(prob(50))
		src.icon_state = "rackbroken"
		src.density = 0
		return

/obj/rack/CheckPass(atom/movable/O as mob|obj, target as turf)
	if (O.flags & 2)
		return 1
	else
		return 0
	return

/obj/rack/MouseDrop_T(obj/O as obj, mob/user as mob)
	if ((!( istype(O, /obj/item/weapon) ) || user.equipped() != O))
		return
	user.drop_item()
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/rack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/weapon/rack_parts( src.loc )
		//SN src = null
		del(src)
		return
	user.drop_item()
	if(W && W.loc)	W.loc = src.loc
	return

/obj/rack/meteorhit(obj/O as obj)
	if(prob(75))
		del(src)
		return
	else
		src.icon_state = "rackbroken"
		src.density = 0
	return

/obj/weldfueltank/meteorhit(obj/O as obj)
	var/turf/T = src.loc
	T.gas.plasma += 1600
	T.gas.o2 += 1600
	T.gas.amt_changed()
	if(T.firelevel < 900000.0)
		T.firelevel = T.gas.plasma
	del(src)

/obj/weldfueltank/attackby(obj/item/weapon/weldingtool/W as obj, mob/user as mob)
	if (!( istype(W, /obj/item/weapon/weldingtool) ))
		return
	W.weldfuel = 20
	W.suffix = text("[][]", (W == src ? "equipped " : ""), W.weldfuel)
	user << "\blue Welder refueled"
	return

/obj/weldfueltank/ex_act(severity)
	switch(severity)
		if(1.0)
			var/turf/T = src.loc
			T.gas.plasma += 1600
			T.gas.o2 += 1600
			T.gas.amt_changed()
			del(src)
		if(2.0)
			if(prob(25))
				var/turf/T = src.loc
				T.gas.plasma += 1600
				T.gas.o2 += 1600
				T.gas.amt_changed()
				del(src)
		if(3.0)
			if(prob(5))
				var/turf/T = src.loc
				T.gas.plasma += 1600
				T.gas.o2 += 1600
				T.gas.amt_changed()
				del(src)

/obj/lattice/blob_act()
	if(prob(75))
		del(src)
		return

/obj/lattice/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			del(src)
			return
		if(3.0)
			return
		else
	return

/obj/watertank/attackby(obj/item/weapon/extinguisher/W as obj, mob/user as mob)
	if (!( istype(W, /obj/item/weapon/extinguisher) ))
		return
	W.waterleft = 20
	W.suffix = text("[][]", (user.equipped() == src ? "equipped " : ""), W.waterleft)
	user << "\blue Extinguisher refueled"
	return

/obj/watertank/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				new /obj/effects/water(src.loc)
				del(src)
				return
		if(3.0)
			if (prob(5))
				new /obj/effects/water(src.loc)
				del(src)
				return
		else
	return

/obj/watertank/blob_act()
	if(prob(25))
		new /obj/effects/water(src.loc)
		del(src)

/obj/d_girders/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/sheet/metal) && isturf(src.loc) && !istype(src.loc, /turf/space))
		if (W:amount < 1)
			del(W)
			return
		var/FloorIcon = src.loc:icon
		var/FloorState = src.loc:icon_state
		var/FloorIntact = src.loc:intact
		var/FloorHealth = src.loc:health
		var/FloorBurnt = src.loc:burnt
		var/FloorName = src.loc:name

		new /turf/simulated/wall/false_wall(src.loc)
		var/turf/simulated/wall/false_wall/FW = src.loc
		FW.setFloorUnderlay(FloorIcon, FloorState, FloorIntact, FloorHealth, FloorBurnt, FloorName)
		W:amount--
		if (W:amount < 1)
			del(W)
		user << "\blue Keep in mind when you open it that it MAY be difficult to slide at first so keep trying."
		del(src)
		return
	else if (istype(W, /obj/item/weapon/sheet/r_metal) && isturf(src.loc) && !istype(src.loc, /turf/space))
		user << "\blue Now constructing reinforced false wall."
		sleep(100)
		del(W)
		var/FloorIcon = src.loc:icon
		var/FloorState = src.loc:icon_state
		var/FloorIntact = src.loc:intact
		var/FloorHealth = src.loc:health
		var/FloorBurnt = src.loc:burnt
		var/FloorName = src.loc:name

		new /turf/simulated/wall/false_rwall(src.loc)
		var/turf/simulated/wall/false_rwall/FRW = src.loc
		FRW.setFloorUnderlay(FloorIcon, FloorState, FloorIntact, FloorHealth, FloorBurnt, FloorName)
		user << "\blue Keep in mind when you open it that it MAY be difficult to slide at first so keep trying."
		del(src)
		return
	else if (istype(W, /obj/item/weapon/screwdriver))
		new /obj/item/weapon/sheet/metal( src.loc )
		del(src)
		return
	else
		return ..()

/obj/barrier/New()
	var/t = 1800
	spawn( t )
		del(src)
		return

/obj/portal/Bumped(mob/M as mob|obj)
	spawn(0)
		src.teleport(M)
		return
	return

/obj/portal/HasEntered(AM as mob|obj)
	spawn(0)
		src.teleport(AM)
		return
	return

/obj/portal/New()
	spawn(300)
		del(src)
		return
	return

/obj/portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effects)) //sparks don't teleport
		return
	if (M.anchored)
		return
	if (src.icon_state == "portal1")
		return
	if (!( src.target ))
		del(src)
		return
	if (istype(M, /atom/movable))
		if(prob(5)) //oh dear a problem, put em in deep space
			src.icon_state = "portal1"
			do_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), 3), 2)
		else
			do_teleport(M, src.target, 2)

/obj/effects/water/New()
	..()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.firelevel = 0
	spawn( 70 )
		del(src)
		return
	return

/obj/effects/water/Del()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.firelevel = 0
	..()
	return

/obj/effects/water/Move(turf/newloc)
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.firelevel = 0
	if (--src.life < 1)
		//SN src = null
		del(src)
	if(newloc.density)
		return 0
	.=..()

/mob/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/shielded = 0
	for(var/obj/item/weapon/shield/S in src)
		if (S.active)
			shielded = 1
		else
	if (locate(/obj/item/weapon/grab, src))
		var/mob/safe = null
		if (istype(src.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.l_hand
			if ((G.state == 3 && get_dir(src, user) == src.dir))
				safe = G.affecting
		if (istype(src.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.r_hand
			if ((G.state == 3 && get_dir(src, user) == src.dir))
				safe = G.affecting
		if (safe)
			return safe.attackby(W, user)
	if ((!( shielded ) || !( W.flags ) & 32))
		spawn( 0 )
			W.attack(src, user)
			return
	return

/atom/proc/MouseDrop_T()
	return

/atom/proc/attack_hand(mob/user as mob)
	return

/atom/proc/attack_paw(mob/user as mob)
	return

/atom/proc/attack_ai(mob/user as mob)
	return

/atom/proc/hand_h(mob/user as mob)
	return

/atom/proc/hand_p(mob/user as mob)
	return

/atom/proc/hand_a(mob/user as mob)
	return

/atom/proc/hitby(obj/item/weapon/W as obj)
	return

/atom/proc/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/f_print_scanner))
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("\red [] has been scanned by [] with the []", src, user, W)
	else
		if (!( istype(W, /obj/item/weapon/grab) ))
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O << text("\red <B>[] has been hit by [] with []</B>", src, user, W)
	return

/atom/proc/add_fingerprint(mob/human/M as mob)
	if ((!( istype(M, /mob/human) ) || !( istype(M.primary, /obj/dna) )))
		return 0
	if (!(src.flags) & 256) // obvious bug...but lots of things probably depend on this
		return
	if (M.gloves)
		return 0
	if (!( src.fingerprints ))
		src.fingerprints = text("[]", md5(M.primary.uni_identity))
	else
		var/list/L = params2list(src.fingerprints)
		L -= md5(M.primary.uni_identity)
		while(L.len >= 3)
			L -= L[1]
		L += md5(M.primary.uni_identity)
		src.fingerprints = list2params(L)
	return

/atom/MouseDrop(atom/over_object as mob|obj|turf|area)
	spawn( 0 )
		if (istype(over_object, /atom))
			over_object.MouseDrop_T(src, usr)
		return
	..()
	return

/atom/Click()
	//world << "atom.Click() on [src] by [usr] : src.type is [src.type]"
	return DblClick()

/atom/DblClick()
	if (world.time <= usr:lastDblClick+2)
		//world << "BLOCKED atom.DblClick() on [src] by [usr] : src.type is [src.type]"
		return
	else
		//world << "atom.DblClick() on [src] by [usr] : src.type is [src.type]"
		usr:lastDblClick = world.time

	..()
	if(usr.in_throw_mode)
		return usr.throw_item(src)
	var/obj/item/weapon/W = usr.equipped()
	if (W == src && usr.stat == 0)
		spawn W.attack_self(usr)
		return
	if ((!usr.canmove && !istype(usr, /mob/ai)) || usr.stat != 0)
		return

	// wtf
	if (!(src in usr.contents) && ((!isturf(src) && !isturf(src.loc) && src.loc && !isturf(src.loc.loc)) || !isturf(usr.loc)) && src.loc != usr.loc && !istype(src, /obj/screen) && !usr.contents.Find(src.loc))
		return

	var/t5 = (get_dist(src, usr) <= 1 || src.loc == usr)
	if (istype(usr, /mob/ai))
		t5 = 1
	if ((istype(src, /obj/item/weapon/organ) && src in usr.contents))
		var/mob/human/H = usr
		usr << "Betchya think you're really smart trying to remove your own body parts aren't ya!"
		if (istype(H, /mob/human))
			if (!( (src == H.l_store || src == H.r_store) ))
				return
		else
			return

	if (((t5 || (W && (W.flags & 16))) && !( istype(src, /obj/screen) )))
		if (usr.next_move < world.time)
			usr.prev_move = usr.next_move
			usr.next_move = world.time + 10
		else
			return
		if ((src.loc && (get_dist(src, usr) < 2 || src.loc == usr.loc)))
			var/direct = get_dir(usr, src)
			var/obj/item/weapon/dummy/D = new /obj/item/weapon/dummy( usr.loc )
			var/ok = 0
			if ( (direct - 1) & direct)
				var/turf/T
				switch(direct)
					if(5.0)
						T = get_step(usr, NORTH)
						if (T.Enter(D, src))
							D.loc = T
							T = src.loc
							if (T.Enter(D, src))
								ok = 1
						else
							T = get_step(usr, EAST)
							if (T.Enter(D, src))
								D.loc = T
								T = src.loc
								if (T.Enter(D, src))
									ok = 1
					if(6.0)
						T = get_step(usr, SOUTH)
						if (T.Enter(D, src))
							D.loc = T
							T = src.loc
							if (T.Enter(D, src))
								ok = 1
						else
							T = get_step(usr, EAST)
							if (T.Enter(D, src))
								D.loc = T
								T = src.loc
								if (T.Enter(D, src))
									ok = 1
					if(9.0)
						T = get_step(usr, NORTH)
						if (T.Enter(D, src))
							D.loc = T
							T = src.loc
							if (T.Enter(D, src))
								ok = 1
						else
							T = get_step(usr, WEST)
							if (T.Enter(D, src))
								D.loc = T
								T = src.loc
								if (T.Enter(D, src))
									ok = 1
					if(10.0)
						T = get_step(usr, SOUTH)
						if (T.Enter(D, src))
							D.loc = T
							T = src.loc
							if (T.Enter(D, src))
								ok = 1
						else
							T = get_step(usr, WEST)
							if (T.Enter(D, src))
								D.loc = T
								T = src.loc
								if (T.Enter(D, src))
									ok = 1
					else
			else
				if (src.loc.Enter(D, src))
					ok = 1
				else
					if ((src.flags & 512 && get_dir(src, usr) & src.dir))
						ok = 1
						if (usr.loc != src.loc)
							for(var/atom/A as mob|obj|turf|area in usr.loc)
								if ((!( A.CheckExit(usr, src.loc) ) && A != usr))
									ok = 0
			//D = null
			del(D)
			if (!( ok ))
				return 0

		if (!( usr.restrained() ))
			if (W)
				if (t5)
					src.attackby(W, usr)
				if (W)
					W.afterattack(src, usr, (t5 ? 1 : 0))
			else
				if (istype(usr, /mob/human))
					src.attack_hand(usr, usr.hand)
				else
					if (istype(usr, /mob/monkey))
						src.attack_paw(usr, usr.hand)
					else
						if (istype(usr, /mob/ai))
							src.attack_ai(usr, usr.hand)
		else
			if (istype(usr, /mob/human))
				src.hand_h(usr, usr.hand)
			else
				if (istype(usr, /mob/monkey))
					src.hand_p(usr, usr.hand)
				else
					if (istype(usr, /mob/ai))
						src.hand_a(usr, usr.hand)

	else
		if (istype(src, /obj/screen))
			usr.prev_move = usr.next_move
			if (usr.next_move < world.time)
				usr.next_move = world.time + 10
			else
				return
			if (!( usr.restrained() ))
				if ((W && !( istype(src, /obj/screen) )))
					src.attackby(W, usr)

					if (W)
						W.afterattack(src, usr)
				else
					if (istype(usr, /mob/human))
						src.attack_hand(usr, usr.hand)
					else
						if (istype(usr, /mob/monkey))
							src.attack_paw(usr, usr.hand)
			else
				if (istype(usr, /mob/human))
					src.hand_h(usr, usr.hand)
				else
					if (istype(usr, /mob/monkey))
						src.hand_p(usr, usr.hand)
	return


/obj/proc/updateUsrDialog()
	var/list/nearby = viewers(1, src)
	for(var/mob/M in nearby)
		if ((M.client && M.machine == src))
			src.attack_hand(M)
	if (istype(usr, /mob/ai))
		if (!(usr in nearby))
			if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
				src.attack_ai(usr)

/obj/proc/updateDialog()
	var/list/nearby = viewers(1, src)
	for(var/mob/M in nearby)
		if ((M.client && M.machine == src))
			src.attack_hand(M)
	AutoUpdateAI(src)
