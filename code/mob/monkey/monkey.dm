/mob/monkey/New()
	spawn(1)
		if (!src.primary)
			var/t1 = rand(1000, 1500)
			dna_ident += t1
			if (dna_ident > 65536.0)
				dna_ident = rand(1, 1500)
			src.primary = new /obj/dna( null )
			src.primary.uni_identity = text("[]", dna_ident)
			while(length(src.primary.uni_identity) < 4)
				src.primary.uni_identity = text("0[]", src.primary.uni_identity)
			var/t2 = text("[]", rand(1, 256))
			if (length(t2) < 2)
				src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
			else
				src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
			t2 = text("[]", rand(1, 256))
			if (length(t2) < 2)
				src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
			else
				src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
			t2 = text("[]", rand(1, 256))
			if (length(t2) < 2)
				src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
			else
				src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
			t2 = text("[]", rand(1, 256))
			if (length(t2) < 2)
				src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
			else
				src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
			t2 = (src.gender == "male" ? text("[]", rand(1, 124)) : text("[]", rand(127, 250)))
			if (length(t2) < 2)
				src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
			else
				src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
			src.primary.spec_identity = "2B6696D2B127E5A4"
			src.primary.struc_enzyme = "CDEAF5B90AADBC6BA8033DB0A7FD613FA"
			src.primary.use_enzyme = "C8FFFE7EC09D80AEDEDB9A5A0B4085B61"
			src.primary.n_chromo = 16
			if(src.gender == NEUTER)
				src.gender = pick(MALE, FEMALE)
			if(src.name == "monkey")
				src.name = text("monkey ([])", copytext(md5(src.primary.uni_identity), 2, 6))
		return
	..()
	return

/mob/monkey/m_delay()
	var/tally = 0
	if (src.bodytemperature < 283.222)
		tally += (283.222 - src.bodytemperature) / 10 * 1.75
	return tally

/mob/monkey/Bump(atom/movable/AM as mob|obj, yes)

	spawn( 0 )
		if ((!( yes ) || src.now_pushing))
			return
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( src.now_pushing ))
			src.now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				step(AM, t)
			src.now_pushing = null
		return
	return

/mob/monkey/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		src.machine = null
		src << browse(null, t1)
	if ((href_list["item"] && !( usr.stat ) && !( usr.restrained() ) && get_dist(src, usr) <= 1))
		var/obj/equip_e/monkey/O = new /obj/equip_e/monkey(  )
		O.source = usr
		O.target = src
		O.item = usr.equipped()
		O.s_loc = usr.loc
		O.t_loc = src.loc
		O.place = href_list["item"]
		src.requests += O
		spawn( 0 )
			O.process()
			return
	..()
	return

/mob/monkey/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (src.health > 0)
		var/shielded = 0
		for(var/obj/item/weapon/shield/S in src)
			if (S.active)
				shielded = 1
			else
		src.bruteloss += 30
		if ((O.icon_state == "flaming" && !( shielded )))
			src.fireloss += 40
		src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
	return

/mob/monkey/las_act(flag)

	if (flag == "bullet")
		if (src.stat != 2)
			src.bruteloss += 60
			src.updatehealth()
			src.weakened = 10
	if (flag)
		if (prob(75))
			src.stunned = 15
		else
			src.weakened = 15
	else
		if (src.stat != 2)
			src.bruteloss += 20
			src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
			if (prob(25))
				src.stunned = 1
	return

/mob/monkey/hand_p(mob/M as mob)
	if ((M.a_intent == "hurt" && !( istype(src.wear_mask, /obj/item/weapon/clothing/mask/muzzle) )))
		if ((prob(75) && src.health > 0))
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>The monkey has bit []!</B>", src), 1)
			var/damage = rand(1, 5)
			src.bruteloss += damage
			src.updatehealth()
		else
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>The monkey has attempted to bite []!</B>", src), 1)
	return

/mob/monkey/attack_paw(mob/M as mob)

	if (M.a_intent == "help")
		src.sleeping = 0
		src.resting = 0
		for(var/mob/O in viewers(src, null))
			O.show_message("\blue The monkey shakes the monkey trying to wake him up!", 1)
	else
		if ((M.a_intent == "hurt" && !( istype(src.wear_mask, /obj/item/weapon/clothing/mask/muzzle) )))
			if ((prob(75) && src.health > 0))
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>The monkey has bit the monkey!</B>", 1)
				var/damage = rand(1, 5)
				src.bruteloss += damage
				src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
			else
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>The monkey has attempted to bite the monkey!</B>", 1)
	return

/mob/monkey/attack_hand(mob/M as mob)

	if (M.a_intent == "help")
		src.sleeping = 0
		src.resting = 0
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\blue [] shakes the monkey trying to wake him up!", M), 1)
	else
		if (M.a_intent == "hurt")
			if ((prob(75) && src.health > 0))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has punched the monkey!</B>", M), 1)
				var/damage = rand(5, 10)
				if (prob(40))
					damage = rand(10, 15)
					if (src.paralysis < 5)
						src.paralysis = rand(10, 15)
						spawn( 0 )
							for(var/mob/O in viewers(src, null))
								if ((O.client && !( O.blinded )))
									O.show_message(text("\red <B>[] has knocked out the monkey!</B>", M), 1)
							return
				src.bruteloss += damage
				src.updatehealth()
			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to punch the monkey!</B>", M), 1)
		else
			if (M.a_intent == "grab")
				if (M == src)
					return
				var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
				G.assailant = M
				if (M.hand)
					M.l_hand = G
				else
					M.r_hand = G
				G.layer = 20
				G.affecting = src
				src.grabbed_by += G
				G.synch()
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red [] has grabbed the monkey passively!", M), 1)
			else
				if (!( src.paralysis ))
					if (prob(25))
						src.paralysis = 2
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] has pushed down the monkey!</B>", M), 1)
					else
						drop_item()
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] has disarmed the monkey!</B>", M), 1)
	return


/mob/monkey/Stat()
	..()
	statpanel("Status")
	stat(null, text("Intent: []", src.a_intent))
	stat(null, text("Move Mode: []", src.m_intent))
	return

/mob/monkey/UpdateClothing()
	..()
	for(var/i in src.overlays)
		src.overlays -= i
	if (!( src.lying ))
		src.icon_state = "monkey1"
	else
		src.icon_state = "monkey0"
	if (src.wear_mask)
		if (istype(src.wear_mask, /obj/item/weapon/clothing/mask))
			var/t1 = src.wear_mask.s_istate
			if (!( t1 ))
				t1 = src.wear_mask.icon_state
			src.overlays += image("icon" = 'icons/ss13/monkey.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = src.layer)
		src.wear_mask.screen_loc = SCREEN_MASK
	if (src.r_hand)
		var/t1 = src.r_hand.s_istate
		if (!( t1 ))
			t1 = src.r_hand.icon_state
		src.overlays += image("icon" = 'icons/goonstation/mob/items_righthand.dmi', "icon_state" = t1, "layer" = src.layer)
		src.r_hand.screen_loc = SCREEN_R_HAND
	if (src.l_hand)
		var/t1 = src.l_hand.s_istate
		if (!( t1 ))
			t1 = src.l_hand.icon_state
		src.overlays += image("icon" = 'icons/goonstation/mob/items_lefthand.dmi', "icon_state" = t1, "layer" = src.layer)
		src.l_hand.screen_loc = SCREEN_L_HAND
	if (src.back)
		if (!( src.lying ))
			src.overlays += image("icon" = 'icons/ss13/monkey.dmi', "icon_state" = "back", "layer" = src.layer)
		else
			src.overlays += image("icon" = 'icons/ss13/monkey.dmi', "icon_state" = "back2", "layer" = src.layer)
		src.back.screen_loc = SCREEN_BACK
	if (src.handcuffed)
		src.pulling = null
		if (!( src.lying ))
			src.overlays += image("icon" = 'icons/ss13/monkey.dmi', "icon_state" = "handcuff1", "layer" = src.layer)
		else
			src.overlays += image("icon" = 'icons/ss13/monkey.dmi', "icon_state" = "handcuff2", "layer" = src.layer)
	if (src.client)
		src.client.screen -= src.contents
		src.client.screen += src.contents
		src.client.screen -= src.hud_used.m_ints
		src.client.screen -= src.hud_used.mov_int
		if (src.i_select)
			if (src.intent)
				src.client.screen += src.hud_used.m_ints
				src.i_select.screen_loc = src.intent
			else
				src.i_select.screen_loc = null
		if (src.m_select)
			if (src.m_int)
				src.client.screen += src.hud_used.mov_int
				src.m_select.screen_loc = src.m_int
			else
				src.m_select.screen_loc = null
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn( 0 )
				src.show_inv(M)
				return
	return

/mob/monkey/Move()
	if ((!( src.buckled ) || src.buckled.loc != src.loc))
		src.buckled = null
	if (src.buckled)
		return
	if (src.restrained())
		src.pulling = null
	var/t7 = 1
	if (src.restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				return 0
	if ((t7 && src.pulling && get_dist(src, src.pulling) <= 1))
		if (src.pulling.anchored)
			src.pulling = null
		var/T = src.loc
		. = ..()
		if (!( isturf(src.pulling.loc) ))
			src.pulling = null
			return
		if (!( src.restrained() ))
			var/diag = get_dir(src, src.pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((ismob(src.pulling) && (get_dist(src, src.pulling) > 1 || diag)))
				if (istype(src.pulling, src.type))
					var/mob/M = src.pulling
					var/mob/t = M.pulling
					M.pulling = null
					step(src.pulling, get_dir(src.pulling.loc, T))
					M.pulling = t
			else
				step(src.pulling, get_dir(src.pulling.loc, T))
	else
		src.pulling = null
		. = ..()
	if ((src.s_active && !( src.contents.Find(src.s_active) )))
		src.s_active.close(src)
	return

/mob/monkey/verb/removeinternal()
	src.internal = null
	return

/mob/monkey/var/co2overloadtime = null
/mob/monkey/var/temperature_resistance = T0C+75

var/const/MONKEY_O2_REQ = 0.001

/mob/monkey/proc/aircheck(obj/substance/gas/G as obj)
	src.t_oxygen = 0
	src.t_plasma = 0
	if(G)
		var/a_oxygen = G.o2 * 0.7
		var/a_plasma = G.plasma
		var/a_sl_gas = G.n2o * 0.7
		var/a_co2 = G.co2

		G.o2 -= a_oxygen
		G.plasma -= a_plasma
		G.n2o -= a_sl_gas

		if (a_oxygen < MONKEY_O2_REQ)
			src.t_oxygen = round( (MONKEY_O2_REQ - a_oxygen) / 5) + 1
		if (G.total_moles && a_co2/G.total_moles > 0.05)
			if(!co2overloadtime)
				co2overloadtime = world.time
			else if(world.time - co2overloadtime > 150)	// 15 seconds for co2 to knock you out (monkeys are detector units for humans)
				src.paralysis = max(src.paralysis,3)
		else
			co2overloadtime = 0
		if (a_plasma > 5)
			src.t_plasma = round(a_plasma / 10) + 1
			if ((src.wear_mask && src.wear_mask.a_filter >= 4))
				src.t_plasma = max(src.t_plasma - 40, 0)
		if(G.temperature > temperature_resistance)
			var/lung_damage = round((G.temperature - temperature_resistance)/20*(AIR_DAMAGE_MODIFIER)+1)
			if(src.wear_mask && src.wear_mask.a_filter >= 4) lung_damage /= 5
			src.fireloss += (lung_damage)
			spawn(0)	flick("oxy0", src.oxygen)
			src << "\red You feel a searing heat in your lungs!"
			if(prob(25))	emote("gasp")
		if (a_sl_gas > 10)
			src.weakened = max(src.weakened, 3)
			if (a_sl_gas > 40)
				src.paralysis = max(src.paralysis, 3)
		src.bodytemperature = adjustBodyTemp(src.bodytemperature, G.temperature, 0.05)	//breathing stuff adjusts your temp but only very VERY slightly
		G.co2 += a_oxygen  // was * 0.6  - changed to increase CO2 output rate of breathing
	return

/mob/monkey/burn(fi_amount)
	..()
	if(src.check_burning() && src.stat < 2)
		flick("fire1", src.fire)
	return

/*
/mob/monkey/proc/firecheck(turf/T as turf)
	if (T.firelevel < 900000.0)
		return 0
	var/total = 0
	if (src.wear_mask)
		if (T.firelevel > src.wear_mask.s_fire)
			total += 0.25
	else
		total += 0.25
	return total
*/

/mob/monkey/ex_act(severity)
	flick("flash", src.flash)
	switch(severity)
		if(1.0)
			if (src.stat != 2)
				src.bruteloss += 200
				src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
		if(2.0)
			if (src.stat != 2)
				src.bruteloss += 60
				src.fireloss += 60
				src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
		if(3.0)
			if (src.stat != 2)
				src.bruteloss += 30
				src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
			if (prob(50))
				src.paralysis += 10
		else
	return

/mob/monkey/blob_act()
	if (src.stat != 2)
		src.bruteloss += 30
		src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
	if (prob(50))
		src.paralysis += 10

/obj/equip_e/monkey/process()
	if (src.item)
		src.item.add_fingerprint(src.source)
	if (!( src.item ))
		switch(src.place)
			if("head")
				if (!( src.target.wear_mask ))
					del(src)
					return
			if("l_hand")
				if (!( src.target.l_hand ))
					del(src)
					return
			if("r_hand")
				if (!( src.target.r_hand ))
					del(src)
					return
			if("back")
				if (!( src.target.back ))
					del(src)
					return
			if("handcuff")
				if (!( src.target.handcuffed ))
					del(src)
					return
			if("internal")
				if ((!( (istype(src.target.wear_mask, /obj/item/weapon/clothing/mask) && istype(src.target.back, /obj/item/weapon/tank) && !( src.target.internal )) ) && !( src.target.internal )))
					del(src)
					return

	if (src.item)
		for(var/mob/O in viewers(src.target, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>[] is trying to put a [] on []</B>", src.source, src.item, src.target), 1)
	else
		var/message = null
		switch(src.place)
			if("l_hand")
				message = text("\red <B>[] is trying to take off a [] from []'s left hand!</B>", src.source, src.target.l_hand, src.target)
			if("r_hand")
				message = text("\red <B>[] is trying to take off a [] from []'s right hand!</B>", src.source, src.target.r_hand, src.target)
			if("back")
				message = text("\red <B>[] is trying to take off a [] from []'s back!</B>", src.source, src.target.back, src.target)
			if("handcuff")
				message = text("\red <B>[] is trying to unhandcuff []!</B>", src.source, src.target)
			if("internal")
				if (src.target.internal)
					message = text("\red <B>[] is trying to remove []'s internals</B>", src.source, src.target)
				else
					message = text("\red <B>[] is trying to set on []'s internals.</B>", src.source, src.target)
			else
		for(var/mob/M in viewers(src.target, null))
			M.show_message(message, 1)
	spawn( 30 )
		src.done()
		return
	return

/obj/equip_e/monkey/done()
	if(!src.source || !src.target)						return
	if(src.source.loc != src.s_loc)						return
	if(src.target.loc != src.t_loc)						return
	if(LinkBlocked(src.s_loc,src.t_loc))				return
	if(src.item && src.source.equipped() != src.item)	return
	if ((src.source.restrained() || src.source.stat))	return
	switch(src.place)
		if("mask")
			if (src.target.wear_mask)
				var/obj/item/weapon/W = src.target.wear_mask
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/weapon/clothing/mask))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.wear_mask = src.item
					src.item.loc = src.target
		if("l_hand")
			if (src.target.l_hand)
				var/obj/item/weapon/W = src.target.l_hand
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/weapon))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.l_hand = src.item
					src.item.loc = src.target
		if("r_hand")
			if (src.target.r_hand)
				var/obj/item/weapon/W = src.target.r_hand
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/weapon))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.r_hand = src.item
					src.item.loc = src.target
		if("back")
			if (src.target.back)
				var/obj/item/weapon/W = src.target.back
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if ((istype(src.item, /obj/item/weapon) && src.item.flags & 1))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.back = src.item
					src.item.loc = src.target
		if("handcuff")
			if (src.target.handcuffed)
				var/obj/item/weapon/W = src.target.handcuffed
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/weapon/handcuffs))
					src.source.drop_item()
					src.target.handcuffed = src.item
					src.item.loc = src.target
		if("internal")
			if (src.target.internal)
				src.target.internal.add_fingerprint(src.source)
				src.target.internal = null
			else
				if (src.target.internal)
					src.target.internal = null
				if (!( istype(src.target.wear_mask, /obj/item/weapon/clothing/mask) ))
					return
				else
					if (istype(src.target.back, /obj/item/weapon/tank))
						src.target.internal = src.target.back
						src.target.internal.add_fingerprint(src.source)
						for(var/mob/M in viewers(src.target, 1))
							if ((M.client && !( M.blinded )))
								M.show_message(text("[] is now running on internals.", src.target), 1)
		else
	src.source.UpdateClothing()
	src.target.UpdateClothing()
	del(src)
	return