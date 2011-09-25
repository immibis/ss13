/mob/human/proc/emote(act as text)

	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)
	var/muzzled = istype(src.wear_mask, /obj/item/weapon/clothing/mask/muzzle)
	var/m_type = 1
	for(var/obj/item/weapon/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)
	var/message
	switch(act)
		if("blink")
			message = text("<B>[]</B> blinks.", src)
			m_type = 1
		if("blink_r")
			message = text("<B>[]</B> blinks rapidly.", src)
			m_type = 1
		if("bow")
			if (!( src.buckled ))
				var/M = null
				if (param)
					for(var/mob/A in view(null, null))
						if (param == A.name)
							M = A
				if (!( M ))
					param = null
				message = text("<B>[]</B> bows[]", src, (param ? text(" to [].", param) : "."))
			m_type = 1
		if("salute")
			if (!( src.buckled ))
				var/M = null
				if (param)
					for(var/mob/A in view(null, null))
						if (param == A.name)
							M = A
				if (!( M ))
					param = null
				message = text("<B>[]</B> salutes[]", src, (param ? text(" to [].", param) : "."))
			m_type = 1
		if("choke")
			if (!( muzzled ))
				message = text("<B>[]</B> chokes!", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a strong noise.", src)
				m_type = 2
		if("clap")
			if (!( src.restrained() ))
				message = text("<B>[]</B> claps.", src)
				m_type = 2
		if("drool")
			message = text("<B>[]</B> drools.", src)
			m_type = 1
		if("eyebrow")
			message = text("<B>[]</B> raises an eyebrow.", src)
			m_type = 1
		if("chuckle")
			if (!( muzzled ))
				message = text("<B>[]</B> chuckles.", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a noise.", src)
				m_type = 2
		if("twitch")
			message = text("<B>[]</B> twitches violently.", src)
			m_type = 1
		if("twitch_s")
			message = text("<B>[]</B> twitches.", src)
			m_type = 1
		if("faint")
			message = text("<B>[]</B> faints.", src)
			src.sleeping = 1
			m_type = 1
		if("cough")
			if (!( muzzled ))
				message = text("<B>[]</B> coughs!", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a strong noise.", src)
				m_type = 2
		if("frown")
			message = text("<B>[]</B> frowns.", src)
			m_type = 1
		if("nod")
			message = text("<B>[]</B> nods.", src)
			m_type = 1
		if("blush")
			message = text("<B>[]</B> blushes.", src)
			m_type = 1
		if("gasp")
			if (!( muzzled ))
				message = text("<B>[]</B> gasps!", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a weak noise.", src)
				m_type = 2
		if("deathgasp")
			if(src.stat == 2)
				message = text("<B>[]</B> seizes up and falls limp, \his eyes dead and lifeless...", src)
				m_type = 2
		if("giggle")
			if (!( muzzled ))
				message = text("<B>[]</B> giggles.", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a noise.", src)
				m_type = 2
		if("glare")
			var/M = null
			if (param)
				for(var/mob/A in view(null, null))
					if (param == A.name)
						M = A
			if (!( M ))
				param = null
			message = text("<B>[]</B> glares[]", src, (param ? text(" at [].", param) : "."))
		if("stare")
			var/M = null
			if (param)
				for(var/mob/A in view(null, null))
					if (param == A.name)
						M = A
			if (!( M ))
				param = null
			message = text("<B>[]</B> stares[]", src, (param ? text(" at [].", param) : "."))
		if("look")
			var/M = null
			if (param)
				for(var/mob/A in view(null, null))
					if (param == A.name)
						M = A
			if (!( M ))
				param = null
			message = text("<B>[]</B> looks[]", src, (param ? text(" at [].", param) : "."))
			m_type = 1
		if("grin")
			message = text("<B>[]</B> grins.", src)
			m_type = 1
		if("cry")
			if (!( muzzled ))
				message = text("<B>[]</B> cries.", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a weak noise. [] frowns.", src, src)
				m_type = 2
		if("sigh")
			if (!( muzzled ))
				message = text("<B>[]</B> sighs.", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a weak noise.", src)
				m_type = 2
		if("laugh")
			if (!( muzzled ))
				message = text("<B>[]</B> laughs.", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a noise.", src)
				m_type = 2
		if("mumble")
			message = text("<B>[]</B> mumbles!", src)
			m_type = 2
		if("grumble")
			if (!( muzzled ))
				message = text("<B>[]</B> grumbles!", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a noise.", src)
				m_type = 2
		if("groan")
			if (!( muzzled ))
				message = text("<B>[]</B> groans!", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a loud noise.", src)
				m_type = 2
		if("moan")
			message = text("<B>[]</B> moans!", src)
			m_type = 2
		if("point")
			if (!( src.restrained() ))
				var/mob/M = null
				if (param)
					for(var/atom/A as mob|obj|turf|area in view(null, null))
						if (param == A.name)
							M = A
				if (!( M ))
					param = null
				else
					var/obj/point/P = new /obj/point( M.loc )
					spawn( 20 )
						//P = null
						del(P)
						return
				message = text("<B>[]</B> points[]", src, (M ? text(" to [].", M) : "."))
			m_type = 1
		if("raise")
			if (!( src.restrained() ))
				message = text("<B>[]</B> raises a hand.", src)
			m_type = 1
		if("shake")
			message = text("<B>[]</B> shakes [] head.", src, (src.gender == "male" ? "his" : "her"))
			m_type = 1
		if("shrug")
			message = text("<B>[]</B> shrugs.", src)
			m_type = 1
		if("signal")
			var/t1 = round(text2num(param))
			if (!( isnum(t1) ))
				return
			if ((t1 > 5 && (src.r_hand || src.l_hand)))
				return
			else
				if ((t1 <= 5 && src.r_hand && src.l_hand))
					return
				else
					if ((t1 > 10 || t1 < 1))
						return
			if (!( src.restrained() ))
				message = text("<B>[]</B> raises [] finger\s.", src, t1)
			m_type = 1
		if("smile")
			message = text("<B>[]</B> smiles.", src)
			m_type = 1
		if("shiver")
			message = text("<B>[]</B> shivers.", src)
			m_type = 2
		if("pale")
			message = text("<B>[]</B> goes pale for a second.", src)
			m_type = 1
		if("tremble")
			message = text("<B>[]</B> trembles in fear!", src)
			m_type = 1
		if("sneeze")
			if (!( muzzled ))
				message = text("<B>[]</B> sneezes.", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a strange noise.", src)
				m_type = 2
		if("sniff")
			message = text("<B>[]</B> sniffs.", src)
			m_type = 2
		if("snore")
			if (!( muzzled ))
				message = text("<B>[]</B> snores.", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a noise.", src)
				m_type = 2
		if("whimper")
			if (!( muzzled ))
				message = text("<B>[]</B> whimpers.", src)
				m_type = 2
			else
				message = text("<B>[]</B> makes a weak noise.", src)
				m_type = 2
		if("wink")
			message = text("<B>[]</B> winks.", src)
			m_type = 1
		if("yawn")
			if (!( muzzled ))
				message = text("<B>[]</B> yawns.", src)
				m_type = 2
		if("collapse")
			if (!src.paralysis)	src.paralysis += 2
			message = text("<B>[]</B> collapses!", src)
			m_type = 2
		if("hug")
			m_type = 1
			if (!( src.restrained() ))
				var/M = null
				if (param)
					for(var/mob/A in view(1, null))
						if (param == A.name)
							M = A
				if (M == src)
					M = null
				if (M)
					message = text("<B>[]</B> hugs [].", src, M)
				else
					message = text("<B>[]</B> hugs [].", src, (src.gender == "male" ? "himself" : "herself"))
		if("handshake")
			m_type = 1
			if ((!( src.restrained() ) && !( src.r_hand )))
				var/mob/M = null
				if (param)
					for(var/mob/A in view(1, null))
						if (param == A.name)
							M = A
				if (M == src)
					M = null
				if (M)
					if ((M.canmove && !( M.r_hand ) && !( M.restrained() )))
						message = text("<B>[]</B> shakes hands with [].", src, M)
					else
						message = text("<B>[]</B> holds out [] hand to [].", src, (src.gender == "male" ? "his" : "her"), M)
		if("help")
			src << "blink, blink_r, blush, bow-(none)/mob, choke, chuckle, clap, collapse, cough,\ncry, drool, eyebrow, frown, gasp, giggle, groan, grumble, handshake, hug-(none)/mob, glare-(none)/mob,\ngrin, laugh, look-(none)/mob, moan, mumble, nod, pale, point-atom, raise, salute, shake, shiver, shrug,\nsigh, signal-#1-10, smile, sneeze, sniff, snore, stare-(none)/mob, tremble, twitch, twitch_s, whimper,\nwink, yawn"
		else
			src << text("\blue Unusable emote []. Say *help for a list.", act)
	if (message)
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return