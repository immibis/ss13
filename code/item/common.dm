
/obj/item
	var/w_class = 3.0
	var/abstract = 0.0
	var/force = null
	var/s_istate = null
	var/damtype = "brute"
	var/throwforce = null
	var/r_speed = 1.0
	var/health = null
	var/burn_point = null
	var/burning = null
	var/obj/item/master = null

	icon = 'icons/goonstation/obj/items.dmi'
	flags = FPRINT | TABLEPASS
	weight = 500000.0
	New()
		. = ..()
		weight = w_class * 100000.0

	examine()
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

	Bump(mob/M)
		. = ..()
		if (src.throwing)
			src.throwing = 0
			src.density = 0
			if(isobj(M))
				var/obj/O = M
				for(var/mob/B in viewers(M, null))
					B.show_message(text("\red [] has been hit by [].", M, src), 1)
				O.hitby(src)
			if(ismob(M))
				for(var/mob/O in viewers(M, null))
					O.show_message(text("\red [] has been hit by [].", M, src), 1)
				if (M.health > -100.0)
					if (istype(M, /mob/human))
						var/mob/human/H = M
						var/dam_zone = pick("chest", "diaper", "head")
						if (H.organs[text("[]", dam_zone)])
							var/obj/item/organ/external/affecting = H.organs[text("[]", dam_zone)]
							if (affecting.take_damage(src.throwforce, 0))
								H.UpdateDamageIcon()
							else
								H.UpdateDamage()
					else
						M.bruteloss += src.throwforce
					M.updatehealth()

	attack_hand(mob/user as mob)
		if (istype(src.loc, /obj/item/storage))
			for(var/mob/M in range(1, src.loc))
				if (M.s_active == src.loc)
					if (M.client)
						M.client.screen -= src
		src.throwing = 0
		if (src.loc == user)
			user.unequip(src)
		if (user.hand)
			user.l_hand = src
		else
			user.r_hand = src
		src.loc = user
		src.layer = 20
		add_fingerprint(user)
		user.UpdateClothing()

	attack_paw(mob/user as mob)

		if (istype(src.loc, /obj/item/storage))
			for(var/mob/M in range(1, src.loc))
				if (M.s_active == src.loc)
					if (M.client)
						M.client.screen -= src
		src.throwing = 0
		if (src.loc == user)
			user.unequip(src)
		if (user.hand)
			user.l_hand = src
		else
			user.r_hand = src
		src.loc = user
		src.layer = 20
		user.UpdateClothing()

	ex_act(severity)
		switch(severity)
			if(1)
				del(src)
			if(2)
				if (prob(50))
					del(src)
			if(3)
				if (prob(5))
					del(src)

	blob_act()
		if(prob(25))
			del(src)

	verb/move_to_top()
		set src in oview(1)

		if(!istype(src.loc, /turf) || usr.stat || usr.restrained() )
			return

		var/turf/T = src.loc

		src.loc = null

		src.loc = T

	proc
		attack_self(mob/user as mob)
		talk_into(mob/user as mob, text)
		moved(mob/user as mob, old_loc as turf)
		dropped(mob/user as mob)
		afterattack(atom/target as mob|obj|turf, mob/user as mob)

	proc/attack(mob/M as mob, mob/user as mob, def_zone)
		for(var/mob/O in viewers(M, null))
			O.show_message("\red <B>[M] has been attacked with \the [src][user ? "by [user]." : "!"] </B>", 1)
		var/power = src.force
		if (istype(M, /mob/human))
			var/mob/human/H = M
			var/obj/item/organ/external/affecting = H.organs["chest"]
			if(istype(user, /mob/human))
				if(!def_zone)
					var/mob/user2 = user
					var/t = user2.zone_sel.selecting
					if(t == "hair" || t == "eyes" || t == "mouth" || t == "neck")
						t = "head"
					def_zone = ran_zone(t)
				if(H.organs[text("[]", def_zone)])
					affecting = H.organs[text("[]", def_zone)]
			if(istype(affecting, /obj/item/organ/external))
				var/b_dam = (src.damtype == "brute" ? src.force : 0)
				var/f_dam = (src.damtype == "fire" ? src.force : 0)
				if(def_zone == "head")
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
						//H.show_message(text("\red <B>This was a []% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>", time * 100 / 120))
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
