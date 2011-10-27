/mob/monkey/Life()
	set invisibility = 0
	set background = 1

	var/turf/T = src.loc
	var/plcheck
	var/oxcheck

	src.updatehealth()
	if (!locate(/obj/table, src.loc))
		src.layer = MOB_LAYER

	if (isturf(T))	//let cryo/sleeper handle adjusting body temp in their respective alter_health procs
		src.bodytemperature = adjustBodyTemp(src.bodytemperature, T.gas.temperature, 0.5)

	if (src.stat != 2)
		src.t_sl_gas = 0
		src.t_n2 = 0
		if (!( src.m_flag ))
			src.moved_recently = 0
		src.m_flag = null
		if (src.mach)
			if (src.machine)
				src.mach.icon_state = "mach1"
			else
				src.mach.icon_state = null
		if (src.disabilities & 2)
			if ((prob(1) && src.paralysis < 10 && src.r_epil < 1))
				src << "\red You have a seizure!"
				src.paralysis = max(10, src.paralysis)
		if (src.disabilities & 4)
			if ((prob(5) && src.paralysis <= 1 && src.r_ch_cou < 1))
				src.drop_item()
				spawn( 0 )
					emote("cough")
					return
		if (src.disabilities & 8)
			if ((prob(10) && src.paralysis <= 1 && src.r_Tourette < 1))
				src.stunned = max(10, src.stunned)
				spawn( 0 )
					emote("twitch")
					return
		if (src.disabilities & 16)
			if (prob(10))
				src.stuttering = max(10, src.stuttering)
		if ((src.internal && !( src.contents.Find(src.internal) )))
			src.internal = null
		if ((!( src.wear_mask ) || !( src.wear_mask.flags | 8 )))
			src.internal = null
		if (src.losebreath > 0)
			src.losebreath--
			if (prob(7))
				spawn(0)
					emote("gasp")
					return
		if (istype(T, /turf))
			var/t = 1.4E-4
			if (src.health < 20)
				t = 5.0E-5
			else
				if (src.health < 40)
					t = 1.0E-4
			var/obj/substance/gas/G = new /obj/substance/gas(  )
			if (src.internal)
				src.internal.process(src, G)
				if (src.wear_mask.flags & HALFMASK)
					var/obj/substance/gas/delta = G.get_frac(0.5)
					G.sub_delta(delta)
					T.gas.add_delta(delta)
					delta = T.gas.get_frac((t / 2 * T.gas.total_moles - G.total_moles) / T.gas.total_moles)
					T.gas.sub_delta(delta)
					G.add_delta(delta)
			else
				var/obj/substance/gas/delta = T.gas.get_frac(t)
				T.gas.sub_delta(delta)
				G.add_delta(delta)
			src.aircheck(G)
			//second pass at body temp
			var/thermal_layers = 1.5
			if ((istype(src.wear_mask, /obj/item/clothing/mask) && !( src.wear_mask.flags & 4 ) && src.wear_mask.flags & 8))
				thermal_layers  += 0.5
			src.bodytemperature = adjustBodyTemp(src.bodytemperature, 310.055, thermal_layers)
			if(src.bodytemperature < 283.222 && prob(2))
				emote("shiver")
			if(src.bodytemperature < 282.591)
				if(src.bodytemperature < 250)
					src.fireloss += 4
					src.updatehealth()
					if(src.paralysis <= 2)	src.paralysis += 2
				else if(prob(3) && !src.paralysis)
					if(src.paralysis <= 5)	src.paralysis += 5
					emote("collapse")
					src << "\red You collapse from the cold!"
			if(src.bodytemperature > 327.444)
				if(src.bodytemperature > 345.444)
					if(!src.eye_blurry)	src << "\red The heat blurs your vision!"
					src.eye_blurry = max(4, src.eye_blurry)
					if(prob(3))	src.fireloss += rand(1,2)
				else if(prob(3) && !src.paralysis)
					src.paralysis += 2
					emote("collapse")
					src << "\red You collapse from heat exhaustion!"
			plcheck = src.t_plasma
			oxcheck = src.t_oxygen
			T.gas.add_delta(G)
//			ficheck = src.firecheck(T)
		else if (istype(T, /obj))
			var/obj/O = T
			O.alter_health(src)
		if (istype(src.loc, /turf/space))
			var/layers = 20

			// ****** Check

			if ((istype(src.wear_mask, /obj/item/clothing/mask) && !( src.wear_mask.flags & 4 ) && src.wear_mask.flags & 8))
				layers -= 5
			if (layers > oxcheck)
				oxcheck = layers
		if ((plcheck && src.health >= 0))
			src.toxloss += (plcheck*1.333)	//monkeys take extra damage
			src.updatehealth()
		if ((oxcheck && src.health >= 0))
			src.oxyloss += oxcheck
			src.updatehealth()
		else
			if (src.health >= 0)
				if (src.oxyloss >= 10)
					var/amount = max(0.15, 1)
					src.oxyloss -= amount
					src.updatehealth()
				else
					src.oxyloss = 0
//		if (ficheck)
//			src.fireloss += ficheck * 10
//			src.updatehealth()
		if (src.health <= -100.0)
			death()
		else
			if ((src.sleeping || src.health < 0))
				if (prob(1))
					if (src.health <= 20)
						spawn( 0 )
							emote("gasp")
							return
					else
						spawn( 0 )
							emote("snore")
							return
				if (src.health < 0)
					if (src.rejuv <= 0)
						src.oxyloss++
						src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
				if(src.stat != 2)	src.stat = 1
				if (src.paralysis < 5)
					src.paralysis = 5
			else
				if (src.resting)
					if (src.weakened < 5)
						src.weakened = 5
				else
					if (src.health < 20)
						if (prob(5))
							if (prob(1))
								if (src.health <= 20)
									spawn( 0 )
										emote("gasp")
										return
							if(src.stat != 2)	src.stat = 1
							if (src.paralysis < 2)
								src.paralysis = 2
		if (src.rejuv > 0)
			src.rejuv--
		if (src.r_epil > 0)
			src.r_epil--
		if (src.r_ch_cou > 0)
			src.r_ch_cou--
		if (src.r_Tourette > 0)
			src.r_Tourette--
		if (src.antitoxs > 0)
			src.antitoxs--
			if (src.plasma > 0)
				src.antitoxs -= 4
		if (src.plasma > 0)
			src.plasma--
		src.blinded = null
		if (src.drowsyness > 0)
			src.drowsyness--
			if (src.paralysis > 1)
				src.drowsyness -= 0.5
			else
				if (src.weakened > 1)
					src.drowsyness -= 0.25
			src.eye_blurry = max(2, src.eye_blurry)
			if (prob(5))
				src.sleeping = 1
				src.paralysis = 5
			if ((src.health > -10.0 && src.drowsyness > 1200))
				if (src.antitoxs < 1)
					src.toxloss += plcheck
					src.updatehealth()
					plcheck = 1
		var/mental_danger = 0
		if (((src.r_epil > 0 && !( src.disabilities & 2 )) || (src.r_Tourette > 0 && !( src.disabilities & 8 ))))
			src.stuttering = max(2, src.drowsyness)
			mental_danger = 1
			src.drowsyness = max(2, src.drowsyness)
			if (!( src.paralysis ))
				if (prob(5))
					src << "\red You have a seizure!"
					src.paralysis = 10
				else
					if (prob(5))
						spawn( 0 )
							emote("twitch")
							return
						src.stunned = 10
					else
						if (prob(30))
							spawn( 0 )
								emote("drool")
								return
		if (src.health > -10.0)
			var/threshold = 45
			if (mental_danger)
				threshold = 15
			if (src.r_ch_cou > 2700)
				if (src.antitoxs < 1)
					src.toxloss += 1
					src.updatehealth()
					plcheck = 1
					if (prob(15))
						spawn( 0 )
							emote("twitch")
							src.stunned = 2
							return
			if (src.r_epil > threshold * 60)
				if (src.antitoxs < 1)
					src.toxloss += 1
					src.updatehealth()
					plcheck = 1
					if (prob(15))
						spawn( 0 )
							emote("twitch")
							src.stunned = 2
							return
			if (src.r_Tourette > threshold * 60)
				if (src.antitoxs < 1)
					src.toxloss += 1
					src.updatehealth()
					plcheck = 1
					if (prob(15))
						spawn( 0 )
							emote("twitch")
							src.stunned = 2
							return
			if (src.antitoxs > 7200)
				src.toxloss += 1
				src.updatehealth()
				plcheck = 1
				if (prob(15))
					spawn( 0 )
						emote("drool")
						return
		if (src.health > -50.0)
			if (src.plasma > 0)
				if (src.antitoxs < 1)
					src.toxloss += 1
					src.updatehealth()
					plcheck = 1
					if (prob(15))
						spawn( 0 )
							emote("moan")
							return
		if (src.stat != 2)
			if (src.paralysis + src.stunned + src.weakened > 0)
				if (src.stunned > 0)
					src.stunned--
					src.stat = 0
				if (src.weakened > 0)
					src.weakened--
					src.lying = 1
					src.stat = 0
				if (src.paralysis > 0)
					src.paralysis--
					src.blinded = 1
					src.lying = 1
					src.stat = 1
				src.canmove = 0
				var/h = src.hand
				src.hand = 0
				drop_item()
				src.hand = 1
				drop_item()
				src.hand = h
			else
				src.canmove = 1
				src.lying = 0
				src.stat = 0
	else
		src.lying = 1
		src.blinded = 1
		src.stat = 2
		src.canmove = 0
	var/add_weight = 0
	if (istype(src.l_hand, /obj/item/grab))
		add_weight += 1250000.0
	if (istype(src.r_hand, /obj/item/grab))
		add_weight += 1250000.0
	if (locate(/obj/item/grab, src.grabbed_by))
		var/a_grabs = 0
		for(var/obj/item/grab/G in src.grabbed_by)
			G.process()
			if (G)
				if (G.state > 1)
					a_grabs++
					if ((G.state > 2 && src.loc == G.assailant.loc))
						src.density = 0
						src.lying = 0
						switch(G.assailant.dir)
							if(1.0)
								src.pixel_y = 8
							if(2.0)
								src.pixel_y = -8.0
							if(4.0)
								src.pixel_x = 8
							if(8.0)
								src.pixel_x = -8.0

		src.weight = ((src.grabbed_by.len - a_grabs) / 2 + 1) * 1250000.0 + (a_grabs * 2500000.0)
	else
		if (src.lying)
			src.weight = add_weight + 2500000.0
		else
			src.weight = add_weight + 1250000.0
	if (src.stuttering > 0)
		src.stuttering--
	if (src.eye_blind > 0)
		src.eye_blind--
		src.blinded = 1
	if (src.ear_deaf > 0)
		src.ear_deaf--
	else
		if (src.ear_damage < 25)
			src.ear_damage -= 0.05
			src.ear_damage = max(src.ear_damage, 0)
	if (src.buckled)
		src.lying = (istype(src.buckled, /obj/stool/bed)) ? 1 : 0
		if(src.lying)
			src.drop_item()
		src.density = 1
	else
		src.density = !src.lying
	if (src.lying)
		src.weight = 5000000.0
	else
		src.weight = 2500000.0
	if (src.sdisabilities & 1)
		src.blinded = 1
	if (src.eye_blurry > 0)
		src.eye_blurry--
		src.eye_blurry = max(0, src.eye_blurry)
	if (src.client)
		src.client.screen -= main_hud1.g_dither
		if (src.stat != 2 && istype(src.wear_mask, /obj/item/clothing/mask/gasmask))
			src.client.screen += main_hud1.g_dither
		if (src.mach)
			if (src.machine)
				src.mach.icon_state = "mach1"
			else
				src.mach.icon_state = "blank"
		if (src.sleep)
			src.sleep.icon_state = text("sleep[]", src.sleeping)
		if (src.rest)
			src.rest.icon_state = text("rest[]", src.resting)
		if (src.healths)
			if (src.stat < 2)
				if (src.health >= 100)
					src.healths.icon_state = "health0"
				else
					if (src.health >= 75)
						src.healths.icon_state = "health1"
					else
						if (src.health >= 50)
							src.healths.icon_state = "health2"
						else
							if (src.health > 20)
								src.healths.icon_state = "health3"
							else
								src.healths.icon_state = "health4"
			else
				src.healths.icon_state = "health5"
		if (src.pullin)
			if (src.pulling)
				src.pullin.icon_state = "pull1"
			else
				src.pullin.icon_state = "pull0"
//		if (src.fire)
//			if (ficheck)
//				src.fire.icon_state = "fire1"
//			else
//				src.fire.icon_state = "fire0"
		if (src.toxin)
			if (plcheck)
				src.toxin.icon_state = "toxin1"
			else
				src.toxin.icon_state = "toxin0"
		if (src.oxygen)
			if (oxcheck)
				src.oxygen.icon_state = "oxy1"
			else
				src.oxygen.icon_state = "oxy0"
		if (src.bodytemp)	//310.055 optimal body temp
			if(src.bodytemperature >= 345.444)
				src.bodytemp.icon_state = "temp4"
			else if(src.bodytemperature >= 335)
				src.bodytemp.icon_state = "temp3"
			else if(src.bodytemperature >= 327.444)
				src.bodytemp.icon_state = "temp2"
			else if(src.bodytemperature >= 316)
				src.bodytemp.icon_state = "temp1"
			else if(src.bodytemperature >= 300)
				src.bodytemp.icon_state = "temp0"
			else if(src.bodytemperature >= 295)
				src.bodytemp.icon_state = "temp-1"
			else if(src.bodytemperature >= 280)
				src.bodytemp.icon_state = "temp-2"
			else if(src.bodytemperature >= 260)
				src.bodytemp.icon_state = "temp-3"
			else
				src.bodytemp.icon_state = "temp-4"
		src.client.screen -= src.hud_used.blurry
		src.client.screen -= src.hud_used.vimpaired
		if ((src.blind && src.stat != 2))
			if (src.blinded)
				src.blind.layer = 18
			else
				src.blind.layer = 0
				if (src.eye_blurry)
					src.client.screen -= src.hud_used.blurry
					src.client.screen += src.hud_used.blurry
				else
					src.client.screen -= src.hud_used.blurry
		if (src.stat != 2)
			if (src.machine)
				if (!( src.machine.check_eye(src) ))
					src.reset_view(null)
			else
				reset_view(null)

	else
		if ((src.canmove && prob(10) && isturf(src.loc)))
			step(src, pick(NORTH, SOUTH, EAST, WEST))
			if (prob(10))
				src.emote(pick("drool", "chimper", "scratch", "tail", "sit", "jump"))
	if (src.primary)
		src.primary.cleanup()
	src.UpdateClothing()
	src.updatehealth()
	return