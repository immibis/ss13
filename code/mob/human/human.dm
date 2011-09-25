/mob/human/New()
	spawn(1)
		var/obj/item/weapon/organ/external/chest/chest = new /obj/item/weapon/organ/external/chest( src )
		chest.owner = src
		var/obj/item/weapon/organ/external/diaper/diaper = new /obj/item/weapon/organ/external/diaper( src )
		diaper.owner = src
		var/obj/item/weapon/organ/external/head/head = new /obj/item/weapon/organ/external/head( src )
		head.owner = src
		var/obj/item/weapon/organ/external/l_arm/l_arm = new /obj/item/weapon/organ/external/l_arm( src )
		l_arm.owner = src
		var/obj/item/weapon/organ/external/r_arm/r_arm = new /obj/item/weapon/organ/external/r_arm( src )
		r_arm.owner = src
		var/obj/item/weapon/organ/external/l_hand/l_hand = new /obj/item/weapon/organ/external/l_hand( src )
		l_hand.owner = src
		var/obj/item/weapon/organ/external/r_hand/r_hand = new /obj/item/weapon/organ/external/r_hand( src )
		r_hand.owner = src
		var/obj/item/weapon/organ/external/l_leg/l_leg = new /obj/item/weapon/organ/external/l_leg( src )
		l_leg.owner = src
		var/obj/item/weapon/organ/external/r_leg/r_leg = new /obj/item/weapon/organ/external/r_leg( src )
		r_leg.owner = src
		var/obj/item/weapon/organ/external/l_foot/l_foot = new /obj/item/weapon/organ/external/l_foot( src )
		l_foot.owner = src
		var/obj/item/weapon/organ/external/r_foot/r_foot = new /obj/item/weapon/organ/external/r_foot( src )
		r_foot.owner = src
		src.organs["chest"] = chest
		src.organs["diaper"] = diaper
		src.organs["head"] = head
		src.organs["l_arm"] = l_arm
		src.organs["r_arm"] = r_arm
		src.organs["l_hand"] = l_hand
		src.organs["r_hand"] = r_hand
		src.organs["l_leg"] = l_leg
		src.organs["r_leg"] = r_leg
		src.organs["l_foot"] = l_foot
		src.organs["r_foot"] = r_foot
		if ((src.gender != "male" && src.gender != "female"))
			src.gender = "male"
		src.stand_icon = new /icon( 'icons/ss13/human.dmi', text("[]", src.gender) )
		src.lying_icon = new /icon( 'icons/ss13/human.dmi', text("[]-d", src.gender) )
		src.icon = src.stand_icon
		src << "\blue Your icons have been generated!"

		UpdateClothing()
		return
	return

/mob/human/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if ((!( yes ) || src.now_pushing))
			return
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!src.now_pushing)
			src.now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				step(AM, t)
			src.now_pushing = null
		return
	return

/mob/human/m_delay()
	var/tally = 0
	if(src.wear_suit)
		if(istype(src.wear_suit, /obj/item/weapon/clothing/suit/straight_jacket))
			tally += 15
		if(istype(src.wear_suit, /obj/item/weapon/clothing/suit/firesuit))	//	firesuits slow you down a bit
			tally += 1.45
		if(istype(src.wear_suit, /obj/item/weapon/clothing/suit/black_firesuit))	//	firesuits slow you down a bit
			tally += 1.45
		if(istype(src.wear_suit, /obj/item/weapon/clothing/suit/sp_suit) && !istype(src.loc, /turf/space))		//	space suits slow you down a bit unless in space
			tally += 1.45
	if (istype(src.shoes, /obj/item/weapon/clothing/shoes))
		if (src.shoes.chained)
			tally += 15
		else
			tally += -1.0
	if (src.bodytemperature < 283.222)
		tally += (283.222 - src.bodytemperature) / 10 * 1.75
	return tally

/mob/human/burn(fi_amount)	//burn() burns items worn, check_burning() burns the player. check_burning is called here
//	var/ok = 0
//	var/obj/item/weapon/organ/external/temp
	if (src.r_hand)
		src.r_hand.burn(fi_amount)
	if (src.l_hand)
		src.l_hand.burn(fi_amount)
	if (src.back)
		src.back.burn(fi_amount)
	if (src.belt)
		src.belt.burn(fi_amount)
	var/still_burning = 127
	if (src.wear_suit)
		if (src.wear_suit.burn(fi_amount))
			still_burning &=  ~src.wear_suit.fire_protect
	if (still_burning & 46)
		if (src.w_uniform)
			if (src.w_uniform.burn(fi_amount))
				still_burning &=  ~src.w_uniform.fire_protect
	if (still_burning & 16)
		if (src.gloves)
			if (src.gloves.burn(fi_amount))
				still_burning &=  ~src.gloves.fire_protect
	if (still_burning & 64)
		if (src.shoes)
			if (src.shoes.burn(fi_amount))
				still_burning &=  ~src.shoes.fire_protect
	if (still_burning & 1)
		if (src.head)
			if (src.head.burn(fi_amount))
				still_burning &=  ~src.head.fire_protect
	if (still_burning & 1)
		if (src.wear_mask)
			if (src.wear_mask.burn(fi_amount))
				still_burning &=  ~src.wear_mask.fire_protect
	if(src.check_burning() && src.stat < 2)
		flick("fire1", src.fire)
//		if ((src.fire && src.stat != 2))
//			flick("fire1", src.fire)
	if (still_burning & 1)
		if (src.glasses)
			src.glasses.burn(fi_amount)
		if (src.ears)
			src.ears.burn(fi_amount)
		if (src.w_radio)
			src.w_radio.burn(fi_amount)
//		temp = null
//		if (src.organs["head"])
//			temp = src.organs["head"]
//			if (istype(temp, /obj/item/weapon/organ/external))
//				ok += temp.take_damage(0, 5)
	if (still_burning & 2)
		if (src.wear_id)
			src.wear_id.burn(fi_amount)
//		temp = null
/*		if (src.organs["chest"])
			temp = src.organs["chest"]
			if (istype(temp, /obj/item/weapon/organ/external))
				ok += temp.take_damage(0, 5)
	if (still_burning & 4)
		temp = null
		if (src.organs["diaper"])
			temp = src.organs["diaper"]
			if (istype(temp, /obj/item/weapon/organ/external))
				ok += temp.take_damage(0, 5)
	if (still_burning & 8)
		temp = null
		if (src.organs["l_arm"])
			temp = src.organs["l_arm"]
			if (istype(temp, /obj/item/weapon/organ/external))
				ok += temp.take_damage(0, 5)
		temp = null
		if (src.organs["r_arm"])
			temp = src.organs["r_arm"]
			if (istype(temp, /obj/item/weapon/organ/external))
				ok += temp.take_damage(0, 5)
	if (still_burning & 32)
		temp = null
		if (src.organs["l_leg"])
			temp = src.organs["l_leg"]
			if (istype(temp, /obj/item/weapon/organ/external))
				ok += temp.take_damage(0, 5)
		temp = null
		if (src.organs["r_leg"])
			temp = src.organs["r_leg"]
			if (istype(temp, /obj/item/weapon/organ/external))
				ok += temp.take_damage(0, 5)
	if (still_burning & 64)
		temp = null
		if (src.organs["l_foot"])
			temp = src.organs["l_foot"]
			if (istype(temp, /obj/item/weapon/organ/external))
				ok += temp.take_damage(0, 5)
		temp = null
		if (src.organs["r_foot"])
			temp = src.organs["r_foot"]
			if (istype(temp, /obj/item/weapon/organ/external))
				ok += temp.take_damage(0, 5)
	if (still_burning & 16)
		temp = null
		if (src.organs["l_hand"])
			temp = src.organs["l_hand"]
			if (istype(temp, /obj/item/weapon/organ/external))
				ok += temp.take_damage(0, 5)
		temp = null
		if (src.organs["r_hand"])
			temp = src.organs["r_hand"]
			if (istype(temp, /obj/item/weapon/organ/external))
				ok += temp.take_damage(0, 5)
*/
//	if (ok)
//		src.UpdateDamageIcon()
//	else
//		src.UpdateDamage()
	return

/mob/human/Stat()
	..()
	statpanel("Status")


	//stat(null, "([x], [y], [z])")

	stat(null, text("Intent: []", src.a_intent))
	stat(null, text("Move Mode: []", src.m_intent))

	if (src.client.statpanel == "Status")
		if (ticker)
			var/timel = ticker.timeleft
			stat(null, text("ETA-[]:[][]", timel / 600 % 60, timel / 100 % 6, timel / 10 % 10))
			if(ticker.mode.name == "Corporate Restructuring" && ticker.target)
				var/icon = ticker.target.name
				var/icon2 = ticker.target.rname
				var/area = get_area(ticker.target)
				stat(null, text("Target: [icon2] (as [icon]) is in [area]"))
		if (src.internal)
			if (!( src.internal.gas ))
				//src.internal = null
				del(src.internal)
			else
				stat(null, text("Internal Atmosphere: []", src.internal))
				stat(null, text("Internal Oxygen: []", src.internal.gas.o2))
				stat(null, text("Internal Plasma: []", src.internal.gas.plasma))


	return

/mob/human/las_act(flag, A as obj)
	var/shielded = 0
	for(var/obj/item/weapon/shield/S in src)
		if (S.active)
			if (flag == "bullet")
				return
			shielded = 1
			S.active = 0
			S.icon_state = "shield0"
	for(var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 1
			S.active = 0
			S.icon_state = "shield0"
	if ((shielded && flag != "bullet"))
		if (!flag)
			src << "\blue Your shield was disturbed by a laser!"
			if(src.paralysis <= 120)	src.paralysis = 120
			src.updatehealth()
	if (locate(/obj/item/weapon/grab, src))
		var/mob/safe = null
		if (istype(src.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.l_hand
			if ((G.state == 3 && get_dir(src, A) == src.dir))
				safe = G.affecting
		if (istype(src.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon.grab/G = src.r_hand
			if ((G.state == 3 && get_dir(src, A) == src.dir))
				safe = G.affecting
		if (safe)
			return safe.las_act(flag, A)
	if (flag == "bullet")
		var/d = 51
		if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/armor))
			if (prob(70))
				show_message("\red Your armor absorbs the hit!", 4)
				return
			else
				if (prob(40))
					show_message("\red Your armor only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 4
		else
			if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/swat_suit))
				if (prob(90))
					show_message("\red Your armor absorbs the blow!", 4)
					return
				else
					if (prob(90))
						show_message("\red Your armor only softens the blow!", 4)
						if (prob(60))
							d = d / 2
						d = d / 5
		if (src.stat != 2)
			var/organ = src.organs[ran_zone("chest")]
			if (istype(organ, /obj/item/weapon/organ/external))
				var/obj/item/weapon/organ/external/temp = organ
				temp.take_damage(d, 0)
			src.UpdateDamageIcon()
			src.updatehealth()
			if (prob(50))
				if(src.weakened <= 5)	src.weakened = 5
		return
	else
		if (flag)
			if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/armor))
				if (prob(5))
					show_message("\red Your armor absorbs the hit!", 4)
					return
			else
				if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/swat_suit))
					if (prob(70))
						show_message("\red Your armor absorbs the hit!", 4)
						return
			if (prob(75) && src.stunned <= 10)
				src.stunned = 10
			else
				src.weakened = 10
			if (src.stuttering < 10)
				src.stuttering = 10
		else
			var/d = 20
			if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/armor))
				if (prob(40))
					show_message("\red Your armor absorbs the hit!", 4)
					return
				else
					if (prob(40))
						show_message("\red Your armor only softens the hit!", 4)
						if (prob(20))
							d = d / 2
						d = d / 2
			else
				if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/swat_suit))
					if (prob(70))
						show_message("\red Your armor absorbs the blow!", 4)
						return
					else
						if (prob(90))
							show_message("\red Your armor only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 2
			if (src.stat != 2)
				var/organ = src.organs[ran_zone("chest")]
				if (istype(organ, /obj/item/weapon/organ/external))
					var/obj/item/weapon/organ/external/temp = organ
					temp.take_damage(d, 0)
				src.UpdateDamageIcon()
				src.updatehealth()
				if (prob(25))
					src.stunned = 1
	return

/mob/human/ex_act(severity)
	flick("flash", src.flash)
	var/shielded = 0
	for(var/obj/item/weapon/shield/S in src)
		if (S.active)
			shielded = 1
		else
	var/b_loss = null
	var/f_loss = null
	switch(severity)
		if(1.0)
			b_loss += 100
			f_loss += 100
		if(2.0)
			if (!shielded)
				b_loss += 60
			f_loss += 60
			if (!istype(src.ears, /obj/item/weapon/clothing/ears/earmuffs))
				src.ear_damage += 30
				src.ear_deaf += 120
		if(3.0)
			b_loss += 30
			if (prob(50) && !shielded)
				src.paralysis += 10
			if (!istype(src.ears, /obj/item/weapon/clothing/ears/earmuffs))
				src.ear_damage += 15
				src.ear_deaf += 60
		else
	for(var/organ in src.organs)
		var/obj/item/weapon/organ/external/temp = src.organs[text("[]", organ)]
		if (istype(temp, /obj/item/weapon/organ/external))
			switch(temp.name)
				if("head")
					temp.take_damage(b_loss * 0.2, f_loss * 0.2)
				if("chest")
					temp.take_damage(b_loss * 0.4, f_loss * 0.4)
				if("diaper")
					temp.take_damage(b_loss * 0.1, f_loss * 0.1)
				if("l_arm")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("r_arm")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("l_hand")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("r_hand")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("l_leg")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("r_leg")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("l_foot")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("r_foot")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
	src.UpdateDamageIcon()
	return

/mob/human/blob_act()
	if (src.stat == 2)
		return
	var/shielded = 0
	for(var/obj/item/weapon/shield/S in src)
		if (S.active)
			shielded = 1
	var/damage = null
	if (src.stat != 2)
		damage = rand(1,20)

	if(shielded)
		damage /= 4

		//src.paralysis += 1

	src.show_message("\red The blob attacks you!")

	var/list/zones = list("head","chest","chest", "diaper", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")

	var/zone = pick(zones)

	var/obj/item/weapon/organ/external/temp = src.organs["[zone]"]

	switch(zone)
		if ("head")
			if ((((src.head && src.head.brute_protect & 1) || (src.wear_mask && src.wear_mask.brute_protect & 1)) && prob(99)))
				if (prob(20))
					temp.take_damage(damage, 0)
				else
					src.show_message("\red You have been protected from a hit to the head.")
				return
			if (damage > 4.9)
				if (src.weakened < 10)
					src.weakened = rand(10, 15)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>The blob has weakened []!</B>", src), 1, "\red You hear someone fall.", 2)
			temp.take_damage(damage)
		if ("chest")
			if ((((src.wear_suit && src.wear_suit.brute_protect & 2) || (src.w_uniform && src.w_uniform.brute_protect & 2)) && prob(85)))
				src.show_message("\red You have been protected from a hit to the chest.")
				return
			if (damage > 4.9)
				if (prob(50))
					if (src.weakened < 5)
						src.weakened = 5
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The blob has knocked down []!</B>", src), 1, "\red You hear someone fall.", 2)
				else
					if (src.stunned < 5)
						src.stunned = 5
					for(var/mob/O in viewers(src, null))
						if(O.client)	O.show_message(text("\red <B>The blob has stunned []!</B>", src), 1)
				if(src.stat != 2)	src.stat = 1
			temp.take_damage(damage)
		if ("diaper")
			if ((((src.wear_suit && src.wear_suit.brute_protect & 4) || (src.w_uniform && src.w_uniform.brute_protect & 4)) && prob(75)))
				src.show_message("\red You have been protected from a hit to the chest.")
				return
			else
				temp.take_damage(damage, 0)


		if("l_arm")
			temp.take_damage(damage, 0)
		if("r_arm")
			temp.take_damage(damage, 0)
		if("l_hand")
			temp.take_damage(damage, 0)
		if("r_hand")
			temp.take_damage(damage, 0)
		if("l_leg")
			temp.take_damage(damage, 0)
		if("r_leg")
			temp.take_damage(damage, 0)
		if("l_foot")
			temp.take_damage(damage, 0)
		if("r_foot")
			temp.take_damage(damage, 0)

	src.UpdateDamageIcon()
	return

/mob/human/u_equip(obj/item/weapon/W as obj)

	if (W == src.wear_suit)
		src.wear_suit = null
	else if (W == src.w_uniform)
		W = src.r_store
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = src.l_store
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = src.wear_id
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = src.belt
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.layer = initial(W.layer)
		src.w_uniform = null
	else if (W == src.gloves)
		src.gloves = null
	else if (W == src.glasses)
		src.glasses = null
	else if (W == src.head)
		src.head = null
	else if (W == src.ears)
		src.ears = null
	else if (W == src.shoes)
		src.shoes = null
	else if (W == src.belt)
		src.belt = null
	else if (W == src.wear_mask)
		src.wear_mask = null
	else if (W == src.w_radio)
		src.w_radio = null
	else if (W == src.wear_id)
		src.wear_id = null
	else if (W == src.r_store)
		src.r_store = null
	else if (W == src.l_store)
		src.l_store = null
	else if (W == src.back)
		src.back = null
	else if (W == src.handcuffed)
		src.handcuffed = null
	else if (W == src.r_hand)
		src.r_hand = null
	else if (W == src.l_hand)
		src.l_hand = null
	return

/mob/human/db_click(text, t1)

	var/obj/item/weapon/W = src.equipped()
	var/emptyHand = (W == null)
	if ((!emptyHand) && (!istype(W, /obj/item/weapon)))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3	//permit the double-click redirection to proceed.
	switch(text)
		if("mask")
			if (src.wear_mask)
				if (emptyHand)
					src.wear_mask.DblClick()
				return
			if (!( istype(W, /obj/item/weapon/clothing/mask) ))
				return
			src.u_equip(W)
			src.wear_mask = W
		if("back")
			if (src.back)
				if (emptyHand)
					src.back.DblClick()
				return
			if (!istype(W, /obj/item/weapon))
				return
			if (!( W.flags & 1 ))
				return
			src.u_equip(W)
			src.back = W
		if("headset")
			if (src.w_radio)
				if (emptyHand)
					src.w_radio.DblClick()
				return
			if (!( istype(W, /obj/item/weapon/radio/headset) ))
				return
			src.u_equip(W)
			src.w_radio = W
		if("o_clothing")
			if (src.wear_suit)
				if (emptyHand)
					src.wear_suit.DblClick()
				return
			if (!( istype(W, /obj/item/weapon/clothing/suit) ))
				return
			src.u_equip(W)
			src.wear_suit = W
		if("gloves")
			if (src.gloves)
				if (emptyHand)
					src.gloves.DblClick()
				return
			if (!( istype(W, /obj/item/weapon/clothing/gloves) ))
				return
			src.u_equip(W)
			src.gloves = W
		if("shoes")
			if (src.shoes)
				if (emptyHand)
					src.shoes.DblClick()
				return
			if (!( istype(W, /obj/item/weapon/clothing/shoes) ))
				return
			src.u_equip(W)
			src.shoes = W
		if("belt")
			if (src.belt)
				if (emptyHand)
					src.belt.DblClick()
				return
			if (!W || !W.flags || !( W.flags & ONBELT ))
				return
			src.u_equip(W)
			src.belt = W
		if("eyes")
			if (src.glasses)
				if (emptyHand)
					src.glasses.DblClick()
				return
			if (!( istype(W, /obj/item/weapon/clothing/glasses) ))
				return
			src.u_equip(W)
			src.glasses = W
		if("head")
			if (src.head)
				if (emptyHand)
					src.head.DblClick()
				return
			if (!( istype(W, /obj/item/weapon/clothing/head) ))
				return
			src.u_equip(W)
			src.head = W
		if("ears")
			if (src.ears)
				if (emptyHand)
					src.ears.DblClick()
				return
			if (!( istype(W, /obj/item/weapon/clothing/ears) ))
				return
			src.u_equip(W)
			src.ears = W
		if("i_clothing")
			if (src.w_uniform)
				if (emptyHand)
					src.w_uniform.DblClick()
				return
			if (!( istype(W, /obj/item/weapon/clothing/under) ))
				return
			src.u_equip(W)
			src.w_uniform = W
		if("id")
			if (src.wear_id)
				if (emptyHand)
					src.wear_id.DblClick()
				return
			if (!src.w_uniform)
				return
			if (!( istype(W, /obj/item/weapon/card/id) ))
				return
			src.u_equip(W)
			src.wear_id = W
		if("storage1")
			if (src.l_store)
				if (emptyHand)
					src.l_store.DblClick()
				return
			if ((!( istype(W, /obj/item/weapon) ) || W.w_class >= 3 || !( src.w_uniform )))
				return
			src.u_equip(W)
			src.l_store = W
		if("storage2")
			if (src.r_store)
				if (emptyHand)
					src.r_store.DblClick()
				return
			if ((!( istype(W, /obj/item/weapon) ) || W.w_class >= 3 || !( src.w_uniform )))
				return
			src.u_equip(W)
			src.r_store = W
		else
	return

/mob/human/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit with by []", src, O), 1)
	if (src.health > 0)
		var/dam_zone = pick("chest", "chest", "chest", "head", "diaper")
		if (istype(src.organs[text("[]", dam_zone)], /obj/item/weapon/organ/external))
			var/obj/item/weapon/organ/external/temp = src.organs[text("[]", dam_zone)]
			temp.take_damage((istype(O, /obj/meteor/small) ? 20 : 50), 30)
			src.UpdateDamageIcon()
		src.updatehealth()
	return

/mob/human/Move(a, b, flag)

	if (src.buckled)
		return
	if (src.restrained())
		src.pulling = null
	var/t7 = 1
	if (src.restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (src.pulling && ((get_dist(src, src.pulling) <= 1 || src.pulling.loc == src.loc) && (src.client && src.client.moving)))))
		var/turf/T = src.loc
		. = ..()
		if (src.pulling && src.pulling.loc)
			if(!( isturf(src.pulling.loc) ))
				src.pulling = null
				return
			else
				if(Debug)
					world.log <<"src.pulling disappeared? at __LINE__ in mob.dm - src.pulling = [src.pulling]"
					world.log <<"REPORT THIS"

		/////
		if(src.pulling && src.pulling.anchored)
			src.pulling = null
			return

		if (!src.restrained())
			var/diag = get_dir(src, src.pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, src.pulling) > 1 || diag))
				if (ismob(src.pulling))
					var/mob/M = src.pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [] has been pulled from []'s grip by []", G.affecting, G.assailant, src), 1)
								//G = null
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/t = M.pulling
						M.pulling = null
						step(src.pulling, get_dir(src.pulling.loc, T))
						M.pulling = t
				else
					step(src.pulling, get_dir(src.pulling.loc, T))
	else
		src.pulling = null
		. = ..()
	if ((src.s_active && !( s_active in src.contents ) ))
		src.s_active.close(src)
	return

/mob/human/UpdateClothing()
	..()
	if (src.monkeyizing)
		return
	if (!src.w_uniform)
		var/obj/item/weapon/W = src.r_store
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = src.l_store
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = src.wear_id
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = src.belt
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.layer = initial(W.layer)
	src.overlays = null

	//*****RM
	if(src.zone_sel)
		src.zone_sel.overlays = null
		src.zone_sel.overlays += src.body_standing
		src.zone_sel.overlays += image("icon" = 'icons/ss13/zone_sel.dmi', "icon_state" = text("[]", src.zone_sel.selecting))

	if (src.lying)
		src.icon = src.lying_icon
		if (src.face2)
			src.overlays += src.face2
		src.overlays += src.body_lying
	else
		src.icon = src.stand_icon
		if (src.face)
			src.overlays += src.face
		src.overlays += src.body_standing
	if (src.w_uniform)
		if (istype(src.w_uniform, /obj/item/weapon/clothing/under))


			var/t1 = src.w_uniform.color

			if (!t1)
				t1 = src.icon_state
			src.overlays += image("icon" = 'icons/ss13/uniforms.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)


		src.w_uniform.screen_loc = "2,2"
	if (src.wear_id)
		src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = text("id[]", (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
	if (src.client)
		src.client.screen -= src.hud_used.other
		src.client.screen -= src.hud_used.intents
		src.client.screen -= src.hud_used.mov_int
	if ((src.client && src.other))
		src.client.screen += src.hud_used.other
	if (src.gloves)
		var/t1 = src.gloves.s_istate
		if (!t1)
			t1 = src.gloves.icon_state
		src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		src.gloves.screen_loc = (!src.client || !src.other ? null : SCREEN_GLOVES)
	if (src.glasses)
		var/t1 = src.glasses.s_istate
		if (!t1)
			t1 = src.glasses.icon_state
		src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		src.glasses.screen_loc = (!src.client || !src.other ? null : SCREEN_GLASSES)
	if (src.ears)
		var/t1 = src.ears.s_istate
		if (!t1)
			t1 = src.ears.icon_state
		src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		src.ears.screen_loc = (!src.client || !src.other ? null : SCREEN_EARS)
	if (src.shoes)
		var/t1 = src.shoes.s_istate
		if (!t1)
			t1 = src.shoes.icon_state
		src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		src.shoes.screen_loc = (!src.client || !src.other ? null : SCREEN_SHOES)
	if (src.w_radio)
		if (!src.lying)
			src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = "headset", "layer" = MOB_LAYER)
		else
			src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = "headset2", "layer" = MOB_LAYER)
		src.w_radio.screen_loc = (src.other ? SCREEN_HEADSET : null) // "3,1"
	if (src.wear_mask)
		if (istype(src.wear_mask, /obj/item/weapon/clothing/mask))
			var/t1 = src.wear_mask.s_istate
			if (!t1)
				t1 = src.wear_mask.icon_state
			src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		src.wear_mask.screen_loc = SCREEN_MASK
	if (src.client)
		if (src.i_select)
			if (src.intent)
				src.client.screen += src.hud_used.intents
				src.i_select.screen_loc = src.intent
			else
				src.i_select.screen_loc = null
		if (src.m_select)
			if (src.m_int)
				src.client.screen += src.hud_used.mov_int
				src.m_select.screen_loc = src.m_int
			else
				src.m_select.screen_loc = null
	if (src.wear_suit)
		if (istype(src.wear_suit, /obj/item/weapon/clothing/suit))
			var/t1 = src.wear_suit.s_istate
			if (!t1)
				t1 = src.wear_suit.icon_state
			src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		src.wear_suit.screen_loc = "2,1"
		if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/straight_jacket))
			if (src.handcuffed)
				src.handcuffed.loc = src.loc
				src.handcuffed.layer = initial(src.handcuffed.layer)
				src.handcuffed = null
			if ((src.l_hand || src.r_hand))
				var/h = src.hand
				src.hand = 1
				drop_item()
				src.hand = 0
				drop_item()
				src.hand = h
	if (src.head)
		var/t1 = src.head.s_istate
		if (!t1)
			t1 = src.head.icon_state
		src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		src.head.screen_loc = SCREEN_HEAD
	if (src.belt)
		var/t1 = src.belt.s_istate
		if (!t1)
			t1 = src.belt.icon_state
		src.overlays += image("icon" = 'icons/ss13/belt.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		src.belt.screen_loc = (src.client && src.other ? SCREEN_BELT : null)
	if ((src.wear_mask && !(src.wear_mask.see_face)) || (src.head && !(src.head.see_face))) // can't see the face
		if(src.wear_id && src.wear_id.registered)
			src.name = src.wear_id.registered
		else
			src.name = "Unknown"
	else
		if (src.wear_id && src.wear_id.registered != src.rname)
			src.name = text("[] (as [])", src.rname, src.wear_id.registered)
		else
			src.name = text("[]", src.rname)
	if(src.wear_id)
		src.wear_id.screen_loc = SCREEN_ID
	if (src.l_store)
		src.l_store.screen_loc = "4,1"
	if (src.r_store)
		src.r_store.screen_loc = "5,1"
	if (src.r_hand)

		var/t1 = src.r_hand.s_istate
		if (!t1)
			t1 = src.r_hand.icon_state
		src.overlays += image("icon" = 'icons/goonstation/mob/items_righthand.dmi', "icon_state" = t1, "layer" = MOB_LAYER)



		src.r_hand.screen_loc = SCREEN_R_HAND
	if (src.l_hand)
		var/t1 = src.l_hand.s_istate
		if (!t1)
			t1 = src.l_hand.icon_state
		src.overlays += image("icon" = 'icons/goonstation/mob/items_lefthand.dmi', "icon_state" = t1, "layer" = MOB_LAYER)



		src.l_hand.screen_loc = SCREEN_L_HAND
	if (src.back)
		if (istype(src.back, /obj/item/weapon/radio/electropack))
			if (!src.lying)
				src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = "backe", "layer" = MOB_LAYER)
			else
				src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = "backe2", "layer" = MOB_LAYER)
		else
			if (!src.lying)
				src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = "back", "layer" = MOB_LAYER)
			else
				src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = "back2", "layer" = MOB_LAYER)
		src.back.screen_loc = SCREEN_BACK
	if (src.handcuffed)
		src.pulling = null
		if (!src.lying)
			src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = "handcuff1", "layer" = MOB_LAYER)
		else
			src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = "handcuff2", "layer" = MOB_LAYER)
	if (src.client)
		src.client.screen -= src.contents
		src.client.screen += src.contents
	var/shielded = 0
	for(var/obj/item/weapon/shield/S in src)
		if (S.active)
			shielded = 1
	for(var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 2
	if (shielded == 2)
		src.invisibility = 2
	else
		src.invisibility = 0
	if (shielded)
		src.overlays += image("icon" = 'icons/ss13/mob.dmi', "icon_state" = "shield", "layer" = MOB_LAYER)
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn( 0 )
				src.show_inv(M)
				return
	src.last_b_state = src.stat

/mob/human/hand_p(mob/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (M.a_intent == "hurt")
		if (istype(M.wear_mask, /obj/item/weapon/clothing/mask/muzzle))
			return
		if (src.health > 0)
			if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/sp_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The monkey has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/bio_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The monkey has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/armor))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The monkey has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/swat_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The monkey has attempted to bite []!</B>", src), 1)
					return
			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>The monkey has bit []!</B>", src), 1)
				var/damage = rand(1, 3)
				var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg", "diaper")
				if (istype(src.organs[text("[]", dam_zone)], /obj/item/weapon/organ/external))
					var/obj/item/weapon/organ/external/temp = src.organs[text("[]", dam_zone)]
					if (temp.take_damage(damage, 0))
						src.UpdateDamageIcon()
					else
						src.UpdateDamage()
				src.updatehealth()
				if((ticker && ticker.mode.name == "monkey"))
					src.monkeyize()
	return

/mob/human/attack_paw(mob/M as mob)
	if (M.a_intent == "help")
		src.sleeping = 0
		src.resting = 0
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\blue The monkey shakes [] trying to wake him up!", src), 1)
	else
		if (istype(src.wear_mask, /obj/item/weapon/clothing/mask/muzzle))
			return
		if (src.health > 0)
			if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/sp_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The monkey has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/bio_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The monkey has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/armor))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The monkey has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/swat_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The monkey has attempted to bite []!</B>", src), 1)
					return
			else
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>The monkey has bit []!</B>", src), 1)
				var/damage = rand(1, 3)
				var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg", "diaper")
				if (istype(src.organs[text("[]", dam_zone)], /obj/item/weapon/organ/external))
					var/obj/item/weapon/organ/external/temp = src.organs[text("[]", dam_zone)]
					if (temp.take_damage(damage, 0))
						src.UpdateDamageIcon()
					else
						src.UpdateDamage()
				src.updatehealth()
				if((ticker && ticker.mode.name == "monkey"))
					src.monkeyize()
	return

/mob/human/attack_hand(mob/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(src.loc, /turf) && istype(src.loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	if (M.a_intent == "help")
		if (src.health > 0)
			if (src.w_uniform)
				src.w_uniform.add_fingerprint(M)
			src.sleeping = 0
			src.resting = 0
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\blue [] shakes [] trying to wake [] up!", M, src, src), 1)
		else
			if (M.health >= -75.0)
				if (((M.head && M.head.flags & 4) || ((M.wear_mask && !( M.wear_mask.flags & 32 )) || ((src.head && src.head.flags & 4) || (src.wear_mask && !( src.wear_mask.flags & 32 ))))))
					M << "\blue <B>Remove that mask!</B>"
					return
				var/obj/equip_e/human/O = new /obj/equip_e/human(  )
				O.source = M
				O.target = src
				O.s_loc = M.loc
				O.t_loc = src.loc
				O.place = "CPR"
				src.requests += O
				spawn( 0 )
					O.process()
					return
	else
		if (M.a_intent == "grab")
			if (M == src)
				return
			if (src.w_uniform)
				src.w_uniform.add_fingerprint(M)
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
				O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)
		else
			if (M.a_intent == "hurt")
				if (src.w_uniform)
					src.w_uniform.add_fingerprint(M)
				var/damage = rand(1, 9)
				var/obj/item/weapon/organ/external/affecting = src.organs["chest"]
				var/t = M.zone_sel.selecting
				if ((t in list( "hair", "eyes", "mouth", "neck" )))
					t = "head"
				var/def_zone = ran_zone(t)
				if (src.organs[text("[]", def_zone)])
					affecting = src.organs[text("[]", def_zone)]
				if ((istype(affecting, /obj/item/weapon/organ/external) && prob(90)))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)
					if (def_zone == "head")
						if ((((src.head && src.head.brute_protect & 1) || (src.wear_mask && src.wear_mask.brute_protect & 1)) && prob(99)))
							if (prob(20))
								affecting.take_damage(damage, 0)
							else
								src.show_message("\red You have been protected from a hit to the head.")
							return
						if (damage > 4.9)
							if (src.weakened < 10)
								src.weakened = rand(10, 15)
							for(var/mob/O in viewers(M, null))
								O.show_message(text("\red <B>[] has weakened []!</B>", M, src), 1, "\red You hear someone fall.", 2)
						affecting.take_damage(damage)
					else
						if (def_zone == "chest")
							if ((((src.wear_suit && src.wear_suit.brute_protect & 2) || (src.w_uniform && src.w_uniform.brute_protect & 2)) && prob(85)))
								src.show_message("\red You have been protected from a hit to the chest.")
								return
							if (damage > 4.9)
								if (prob(50))
									if (src.weakened < 5)
										src.weakened = 5
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
								else
									if (src.stunned < 5)
										src.stunned = 5
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
								if(src.stat != 2)	src.stat = 1
							affecting.take_damage(damage)
						else
							if (def_zone == "diaper")
								if ((((src.wear_suit && src.wear_suit.brute_protect & 4) || (src.w_uniform && src.w_uniform.brute_protect & 4)) && prob(75)))
									src.show_message("\red You have been protected from a hit to the lower chest/diaper.")
									return
								if (damage > 4.9)
									if (prob(50))
										if (src.weakened < 3)
											src.weakened = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
									else
										if (src.stunned < 3)
											src.stunned = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
									if(src.stat != 2)	src.stat = 1
								affecting.take_damage(damage)
							else
								affecting.take_damage(damage)

					src.UpdateDamageIcon()

					src.updatehealth()
				else
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)
					return
			else
				if (!( src.lying ))
					if (src.w_uniform)
						src.w_uniform.add_fingerprint(M)
					var/randn = rand(1, 100)
					if (randn <= 25)
						src.weakened = 2
						for(var/mob/O in viewers(src, null))
							O.show_message(text("\red <B>[] has pushed down []!</B>", M, src), 1)
					else
						if (randn <= 60)
							src.drop_item()
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has disarmed []!</B>", M, src), 1)
						else
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has attempted to disarm []!</B>", M, src), 1)
	return

/mob/human/restrained()
	if (src.handcuffed)
		return 1
	if (istype(src.wear_suit, /obj/item/weapon/clothing/suit/straight_jacket))
		return 1
	return 0

/mob/human/proc/update_body()
	del(src.stand_icon)
	del(src.lying_icon)
	src.stand_icon = new /icon( 'icons/ss13/human.dmi', "blank" )
	src.lying_icon = new /icon( 'icons/ss13/human.dmi', "blank" )
	for(var/t in list( "chest", "head", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot" ))
		src.stand_icon.Blend(new /icon( 'icons/ss13/human.dmi', text("[]", t) ), 3)
		src.lying_icon.Blend(new /icon( 'icons/ss13/human.dmi', text("[]2", t) ), 3)
	if (src.s_tone >= 0)
		src.stand_icon.Blend(rgb(src.s_tone, src.s_tone, src.s_tone), 0)
		src.lying_icon.Blend(rgb(src.s_tone, src.s_tone, src.s_tone), 0)
	else
		src.stand_icon.Blend(rgb( -src.s_tone,  -src.s_tone,  -src.s_tone), 1)
		src.lying_icon.Blend(rgb( -src.s_tone,  -src.s_tone,  -src.s_tone), 1)
	src.stand_icon.Blend(new /icon( 'icons/ss13/human.dmi', "diaper" ), 3)
	src.lying_icon.Blend(new /icon( 'icons/ss13/human.dmi', "diaper2" ), 3)
	if (src.gender == "female")
		src.stand_icon.Blend(new /icon( 'icons/ss13/human.dmi', "f_add" ), 3)
		src.lying_icon.Blend(new /icon( 'icons/ss13/human.dmi', "f_add2" ), 3)
	return

/mob/human/proc/update_face()

	//src.face = null
	del(src.face)
	//src.face2 = null
	del(src.face2)
	var/icon/I = new/icon("icon" = 'icons/ss13/mob.dmi', "icon_state" = "eyes")
	var/icon/I2 = new/icon("icon" = 'icons/ss13/mob.dmi', "icon_state" = "eyes2")
	var/icon/F = new/icon("icon" = 'icons/ss13/mob.dmi', "icon_state" = text("[]", src.h_style_r))
	var/icon/F2 = new/icon("icon" = 'icons/ss13/mob.dmi', "icon_state" = text("[]2", src.h_style_r))
	F.Blend(rgb(src.r_hair, src.g_hair, src.b_hair), 0)
	F2.Blend(rgb(src.r_hair, src.g_hair, src.b_hair), 0)
	I.Blend(rgb(src.r_eyes, src.g_eyes, src.b_eyes), 0)
	I2.Blend(rgb(src.r_eyes, src.g_eyes, src.b_eyes), 0)
	I.Blend(F, 3)
	I2.Blend(F2, 3)
	F = new/icon("icon" = 'icons/ss13/human.dmi', "icon_state" = "mouth")
	F2 = new/icon("icon" = 'icons/ss13/human.dmi', "icon_state" = "mouth2")
	I.Blend(F, 3)
	I2.Blend(F2, 3)
	//F = null
	del(F)
	//F2 = null
	del(F2)
	src.face = new /image(  )
	src.face2 = new /image(  )
	src.face.icon = I
	src.face2.icon = I2
	//I = null
	del(I)
	//I2 = null
	del(I2)
	return

/mob/human/var/co2overloadtime = null
/mob/human/var/temperature_resistance = T0C+75

var/const/HUMAN_O2_REQ = 0.001

/mob/human/proc/aircheck(obj/substance/gas/G as obj)
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
		G.amt_changed()

		if (a_oxygen < HUMAN_O2_REQ)
			src.t_oxygen = round(HUMAN_O2_REQ - a_oxygen,0.01) + 1
		if (G.total_moles && a_co2/G.total_moles > 0.05)
			if(!co2overloadtime)
				co2overloadtime = world.time
			else if(world.time - co2overloadtime > 180)	// 18 seconds for co2 to knock you out (monkeys are detector units for humans)
				src.paralysis = max(src.paralysis,3)
		else
			co2overloadtime = 0
		if (a_plasma > 0.5)
			src.t_plasma = round(a_plasma,0.1) + 1
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
		G.amt_changed()
	return

/obj/equip_e/human/process()
	if (src.item)
		src.item.add_fingerprint(src.source)
	if (!src.item)
		switch(src.place)
			if("mask")
				if (!( src.target.wear_mask ))
					//SN src = null
					del(src)
					return
			if("headset")
				if (!( src.target.w_radio ))
					//SN src = null
					del(src)
					return
			if("l_hand")
				if (!( src.target.l_hand ))
					//SN src = null
					del(src)
					return
			if("r_hand")
				if (!( src.target.r_hand ))
					//SN src = null
					del(src)
					return
			if("suit")
				if (!( src.target.wear_suit ))
					//SN src = null
					del(src)
					return
			if("uniform")
				if (!( src.target.w_uniform ))
					//SN src = null
					del(src)
					return
			if("back")
				if (!( src.target.back ))
					//SN src = null
					del(src)
					return
			if("syringe")
				return
			if("pill")
				return
			if("handcuff")
				if (!( src.target.handcuffed ))
					//SN src = null
					del(src)
					return
			if("id")
				if ((!( src.target.wear_id ) || !( src.target.w_uniform )))
					//SN src = null
					del(src)
					return
			if("internal")
				if ((!( (istype(src.target.wear_mask, /obj/item/weapon/clothing/mask) && istype(src.target.back, /obj/item/weapon/tank) && !( src.target.internal )) ) && !( src.target.internal )))
					//SN src = null
					del(src)
					return

	var/list/L = list( "syringe", "pill" )
	if ((src.item && !( L.Find(src.place) )))
		for(var/mob/O in viewers(src.target, null))
			O.show_message(text("\red <B>[] is trying to put \a [] on []</B>", src.source, src.item, src.target), 1)
	else
		if (src.place == "syringe")
			for(var/mob/O in viewers(src.target, null))
				O.show_message(text("\red <B>[] is trying to inject []!</B>", src.source, src.target), 1)
		else
			if (src.place == "pill")
				for(var/mob/O in viewers(src.target, null))
					O.show_message(text("\red <B>[] is trying to force [] to swallow []!</B>", src.source, src.target, src.item), 1)
			else
				var/message = null
				switch(src.place)
					if("mask")
						message = text("\red <B>[] is trying to take off \a [] from []'s head!</B>", src.source, src.target.wear_mask, src.target)
					if("headset")
						message = text("\red <B>[] is trying to take off \a [] from []'s face!</B>", src.source, src.target.w_radio, src.target)
					if("l_hand")
						message = text("\red <B>[] is trying to take off \a [] from []'s left hand!</B>", src.source, src.target.l_hand, src.target)
					if("r_hand")
						message = text("\red <B>[] is trying to take off \a [] from []'s right hand!</B>", src.source, src.target.r_hand, src.target)
					if("gloves")
						message = text("\red <B>[] is trying to take off the [] from []'s hands!</B>", src.source, src.target.gloves, src.target)
					if("eyes")
						message = text("\red <B>[] is trying to take off the [] from []'s eyes!</B>", src.source, src.target.glasses, src.target)
					if("ears")
						message = text("\red <B>[] is trying to take off the [] from []'s ears!</B>", src.source, src.target.ears, src.target)
					if("head")
						message = text("\red <B>[] is trying to take off the [] from []'s head!</B>", src.source, src.target.head, src.target)
					if("shoes")
						message = text("\red <B>[] is trying to take off the [] from []'s feet!</B>", src.source, src.target.shoes, src.target)
					if("belt")
						message = text("\red <B>[] is trying to take off the [] from []'s belt!</B>", src.source, src.target.belt, src.target)
					if("suit")
						message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", src.source, src.target.wear_suit, src.target)
					if("back")
						message = text("\red <B>[] is trying to take off \a [] from []'s back!</B>", src.source, src.target.back, src.target)
					if("handcuff")
						message = text("\red <B>[] is trying to unhandcuff []!</B>", src.source, src.target)
					if("uniform")
						message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", src.source, src.target.w_uniform, src.target)
					if("pockets")
						message = text("\red <B>[] is trying to empty []'s pockets!!</B>", src.source, src.target)
					if("CPR")
						if (src.target.cpr_time >= world.time + 3)
							//SN src = null
							del(src)
							return
						message = text("\red <B>[] is trying perform CPR on []!</B>", src.source, src.target)
					if("id")
						message = text("\red <B>[] is trying to take off [] from []'s uniform!</B>", src.source, src.target.wear_id, src.target)
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

/obj/equip_e/human/done()
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
		if("headset")
			if (src.target.w_radio)
				var/obj/item/weapon/W = src.target.w_radio
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
			else
				if (istype(src.item, /obj/item/weapon/radio/headset))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.w_radio = src.item
					src.item.loc = src.target
		if("gloves")
			if (src.target.gloves)
				var/obj/item/weapon/W = src.target.gloves
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/weapon/clothing/gloves))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.gloves = src.item
					src.item.loc = src.target
		if("eyes")
			if (src.target.glasses)
				var/obj/item/weapon/W = src.target.glasses
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/weapon/clothing/glasses))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.glasses = src.item
					src.item.loc = src.target
		if("belt")
			if (src.target.belt)
				var/obj/item/weapon/W = src.target.belt
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if ((istype(src.item, /obj) && src.item.flags & 128 && src.target.w_uniform))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.belt = src.item
					src.item.loc = src.target
		if("head")
			if (src.target.head)
				var/obj/item/weapon/W = src.target.head
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/weapon/clothing/head))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.head = src.item
					src.item.loc = src.target
		if("ears")
			if (src.target.ears)
				var/obj/item/weapon/W = src.target.ears
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/weapon/clothing/ears))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.ears = src.item
					src.item.loc = src.target
		if("shoes")
			if (src.target.shoes)
				var/obj/item/weapon/W = src.target.shoes
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/weapon/clothing/shoes))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.shoes = src.item
					src.item.loc = src.target
		if("l_hand")
			if (istype(src.target, /obj/item/weapon/clothing/suit/straight_jacket))
				//SN src = null
				del(src)
				return
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
					src.item.add_fingerprint(src.target)
		if("r_hand")
			if (istype(src.target, /obj/item/weapon/clothing/suit/straight_jacket))
				//SN src = null
				del(src)
				return
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
					src.item.add_fingerprint(src.target)
		if("uniform")
			if (src.target.w_uniform)
				var/obj/item/weapon/W = src.target.w_uniform
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
				W = src.target.l_store
				if (W)
					src.target.u_equip(W)
					if (src.target.client)
						src.target.client.screen -= W
					if (W)
						W.loc = src.target.loc
						W.dropped(src.target)
						W.layer = initial(W.layer)
				W = src.target.r_store
				if (W)
					src.target.u_equip(W)
					if (src.target.client)
						src.target.client.screen -= W
					if (W)
						W.loc = src.target.loc
						W.dropped(src.target)
						W.layer = initial(W.layer)
				W = src.target.wear_id
				if (W)
					src.target.u_equip(W)
					if (src.target.client)
						src.target.client.screen -= W
					if (W)
						W.loc = src.target.loc
						W.dropped(src.target)
						W.layer = initial(W.layer)
			else
				if (istype(src.item, /obj/item/weapon/clothing/under))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.w_uniform = src.item
					src.item.loc = src.target
		if("suit")
			if (src.target.wear_suit)
				var/obj/item/weapon/W = src.target.wear_suit
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/weapon/clothing/suit))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.wear_suit = src.item
					src.item.loc = src.target
		if("id")
			if (src.target.wear_id)
				var/obj/item/weapon/W = src.target.wear_id
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if ((istype(src.item, /obj/item/weapon/card/id) && src.target.w_uniform))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.wear_id = src.item
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
		if("CPR")
			if (src.target.cpr_time >= world.time + 30)
				//SN src = null
				del(src)
				return
			if ((src.target.health >= -75.0 && src.target.health < 0))
				src.target.cpr_time = world.time
				if (src.target.health >= -40.0)
					var/suff = min(src.target.oxyloss, 5)
					src.target.oxyloss -= suff
					src.target.updatehealth()
				if(target.rejuv<10)
					src.target.rejuv += 10		// change
				for(var/mob/O in viewers(src.source, null))
					O.show_message(text("\red [] performs CPR on []!", src.source, src.target), 1)
				src.source << "\red Repeat every 7 seconds AT LEAST."
		if("syringe")
			var/obj/item/weapon/syringe/S = src.item
			src.item.add_fingerprint(src.source)
			if (!( istype(S, /obj/item/weapon/syringe) ))
				//SN src = null
				del(src)
				return
			if (S.s_time >= world.time + 30)
				//SN src = null
				del(src)
				return
			S.s_time = world.time
			var/a = S.inject(src.target)
			for(var/mob/O in viewers(src.source, null))
				O.show_message(text("\red [] injects [] with the syringe!", src.source, src.target), 1)
			src.source << text("\red You inject [] units into []. The syringe contains [] units.", a, src.target, S.chem.volume())
		if("pill")
			var/obj/item/weapon/m_pill/S = src.item
			if (!( istype(S, /obj/item/weapon/m_pill) ))
				//SN src = null
				del(src)
				return
			if (S.s_time >= world.time + 30)
				//SN src = null
				del(src)
				return
			S.s_time = world.time
			var/a = S.name
			S.ingest(src.target)
			for(var/mob/O in viewers(src.source, null))
				O.show_message(text("\red [] forces [] to swallow \a []!", src.source, src.target, a), 1)
		if("pockets")
			if (src.target.l_store)
				var/obj/item/weapon/W = src.target.l_store
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			if (src.target.r_store)
				var/obj/item/weapon/W = src.target.r_store
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
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
						for(var/mob/M in viewers(src.target, 1))
							M.show_message(text("[] is now running on internals.", src.target), 1)
						src.target.internal.add_fingerprint(src.source)
		else
	src.source.UpdateClothing()
	src.target.UpdateClothing()
	//SN src = null
	del(src)
	return

/mob/human/proc/TakeDamage(zone, brute, burn)
	var/obj/item/weapon/organ/external/E = src.organs[text("[]", zone)]
	if (istype(E, /obj/item/weapon/organ/external))
		if (E.take_damage(brute, burn))
			src.UpdateDamageIcon()
		else
			src.UpdateDamage()
	else
		return 0
	return

/mob/human/proc/HealDamage(zone, brute, burn)

	var/obj/item/weapon/organ/external/E = src.organs[text("[]", zone)]
	if (istype(E, /obj/item/weapon/organ/external))
		if (E.heal_damage(brute, burn))
			src.UpdateDamageIcon()
		else
			src.UpdateDamage()
	else
		return 0
	return

/mob/human/proc/UpdateDamage()

	var/list/L = list(  )
	for(var/t in src.organs)
		if (istype(src.organs[text("[]", t)], /obj/item/weapon/organ/external))
			L += src.organs[text("[]", t)]
	src.bruteloss = 0
	src.fireloss = 0
	for(var/obj/item/weapon/organ/external/O in L)
		src.bruteloss += O.brute_dam
		src.fireloss += O.burn_dam
	return

// new damage icon system
// now constructs damage icon for each organ from mask * damage field

/mob/human/proc/UpdateDamageIcon()
	var/list/L = list(  )
	for(var/t in src.organs)
		if (istype(src.organs[text("[]", t)], /obj/item/weapon/organ/external))
			L += src.organs[text("[]", t)]
		//Foreach goto(24)
	//src.body_standing = null
	del(src.body_standing)
	src.body_standing = list(  )
	//src.body_lying = null
	del(src.body_lying)
	src.body_lying = list(  )
	src.bruteloss = 0
	src.fireloss = 0
	for(var/obj/item/weapon/organ/external/O in L)
		src.bruteloss += O.brute_dam
		src.fireloss += O.burn_dam

		var/icon/DI = new /icon('icons/ss13/dam_human.dmi', O.d_i_state)			// the damage icon for whole human
		DI.Blend(new /icon('icons/ss13/dam_mask.dmi', O.r_name),ICON_MULTIPLY)		// mask with this organ's pixels

//		world << "[O.r_name] [O.d_i_state] \icon[DI]"

		body_standing += DI

		DI = new /icon('icons/ss13/dam_human.dmi', "[O.d_i_state]-2")				// repeat for lying icons
		DI.Blend(new /icon('icons/ss13/dam_mask.dmi', "[O.r_name]2"),ICON_MULTIPLY)

//		world << "[O.r_name]2 [O.d_i_state]-2 \icon[DI]"

		body_lying += DI

		//src.body_standing += new /icon( 'dam_zones.dmi', text("[]", O.d_i_state) )
		//src.body_lying += new /icon( 'dam_zones.dmi', text("[]2", O.d_i_state) )

	return

/mob/human/show_inv(mob/user as mob)

	user.machine = src
	var/dat = text("<PRE>\n<B><FONT size=3>[]</FONT></B>\n\t<B>Head(Mask):</B> <A href='?src=\ref[];item=mask'>[]</A>\n\t\t<B>Headset:</B> <A href='?src=\ref[];item=headset'>[]</A>\n\t<B>Left Hand:</B> <A href='?src=\ref[];item=l_hand'>[]</A>\n\t<B>Right Hand:</B> <A href='?src=\ref[];item=r_hand'>[]</A>\n\t<B>Gloves:</B> <A href='?src=\ref[];item=gloves'>[]</A>\n\t<B>Eyes:</B> <A href='?src=\ref[];item=eyes'>[]</A>\n\t<B>Ears:</B> <A href='?src=\ref[];item=ears'>[]</A>\n\t<B>Head:</B> <A href='?src=\ref[];item=head'>[]</A>\n\t<B>Shoes:</B> <A href='?src=\ref[];item=shoes'>[]</A>\n\t<B>Belt:</B> <A href='?src=\ref[];item=belt'>[]</A>\n\t<B>Uniform:</B> <A href='?src=\ref[];item=uniform'>[]</A>\n\t<B>(Exo)Suit:</B> <A href='?src=\ref[];item=suit'>[]</A>\n\t<B>Back:</B> <A href='?src=\ref[];item=back'>[]</A> []\n\t<B>ID:</B> <A href='?src=\ref[];item=id'>[]</A>\n\t[]\n\t[]\n\t<A href='?src=\ref[];item=pockets'>Empty Pockets</A>\n<A href='?src=\ref[];mach_close=mob[]'>Close</A>\n</PRE>", src.name, src, (src.wear_mask ? text("[]", src.wear_mask) : "Nothing"), src, (src.w_radio ? text("[]", src.w_radio) : "Nothing"), src, (src.l_hand ? text("[]", src.l_hand) : "Nothing"), src, (src.r_hand ? text("[]", src.r_hand) : "Nothing"), src, (src.gloves ? text("[]", src.gloves) : "Nothing"), src, (src.glasses ? text("[]", src.glasses) : "Nothing"), src, (src.ears ? text("[]", src.ears) : "Nothing"), src, (src.head ? text("[]", src.head) : "Nothing"), src, (src.shoes ? text("[]", src.shoes) : "Nothing"), src, (src.belt ? text("[]", src.belt) : "Nothing"), src, (src.w_uniform ? text("[]", src.w_uniform) : "Nothing"), src, (src.wear_suit ? text("[]", src.wear_suit) : "Nothing"), src, (src.back ? text("[]", src.back) : "Nothing"), ((istype(src.wear_mask, /obj/item/weapon/clothing/mask) && istype(src.back, /obj/item/weapon/tank) && !( src.internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : ""), src, (src.wear_id ? text("[]", src.wear_id) : "Nothing"), (src.handcuffed ? text("<A href='?src=\ref[];item=handcuff'>Handcuffed</A>", src) : text("<A href='?src=\ref[];item=handcuff'>Not Handcuffed</A>", src)), (src.internal ? text("<A href='?src=\ref[];item=internal'>Remove Internal</A>", src) : ""), src, user, src.name)
	user << browse(dat, text("window=mob[];size=340x480", src.name))
	return