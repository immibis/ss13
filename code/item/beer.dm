/obj/item/bottle/beer/attack(mob/M as mob, mob/user as mob)

	if (user.a_intent == "hurt")
		if (src.icon_state == "broken_beer")
			if (M == user)
				user << "\red <B>You go to rub your eyes with your hand, forgetting you are holding a broken beer bottle!</b>"
			else
				user << "\red <B>You jab [M] in the face with your broken beer bottle!</b>"
				M << "\red <B>[user] gouges your face with their broken beer bottle!</b>"
			M.stunned += rand(0,5)
			M.bruteloss += 30
			M.eye_blurry += rand(0,20)
			M.health = 100 - M.oxyloss - M.toxloss - M.fireloss - M.bruteloss

		else // Bottle is not broken, intent is hurt
			if (M == user)
				user << "\red <B>You let out a ferocious yell and smash the beer bottle into your own face!</b>"
			else
				user << "\red <B>You smash the beer bottle over [M]s head!</b>"
				M << "\red <B>[user] smashes a beer bottle over your head!</b>"
			M.bruteloss += 10
			M.stunned += rand(0,5)
			if (prob(40))
				if (user != M)
					user << "\red <B>The bottle shatters!</b>"
				M << "\red <B>The bottle shatters!</b>"
				M.eye_blurry += rand(0,(10-src.amount)) // blur the eyes according to how much beer was left in there
				src.amount = 0
				src.icon_state = "broken_beer"
				M.stunned += rand(0,5)

				M.bruteloss += 10
				M.health = 100 - M.oxyloss - M.toxloss - M.fireloss - M.bruteloss

	else // Intent = not hurt
		if (src.icon_state == "broken_beer")
			if (M == user)
				user << "\blue <B>You brandish the jagged remains of the beer bottle in your hand with a devilish flourish!"
			else
				user << "\blue <B>You lovingly caress [M]'s cheek with the broken beer bottle, being careful not to accidentally cut them with the sharp edges.</b>"
				M << "\blue <B>[user] is the sweetest, caressing your cheek with their broken beer bottle, ever so tender... ever so gentle.</b>"

		else // Bottle is not broken, intent is NOT hurt
			if (src.amount <= 0)
				if (M == user)
					user << "\blue <B>You sadly frown as you are only able to shake a single drop of beer from the bottle. :(</b>"
				else
					user << "\blue <B>You try to give [M] some beer, but the bottle is empty :(</b>"
					M << "\blue <B>[user] tried to give you some beer, but sadly the bottle was empty :(</b>"
			else
				src.amount--
				if (M == user)
					user <<"\blue <B>You take a swig of SPACE BEER!</b>"
				else
					user << "\blue <B>You helpfully force a gulp of beer down [M]s throat!</b>"
					M << "\blue <B>[user] helpfully forces a gulp of beer down your throat!</b>"
				M.stunned += rand(0,5)
				M.weakened += rand(0,10)
				M.eye_blurry += rand(0,6)
				if ((prob(20) && M.drowsyness < 30))
					M.drowsyness += 5
					M.drowsyness = min(M.drowsyness, 30)

	if (src.icon_state == "broken_beer")
		if (prob(20))
			user << "\blue <B>Sadly, the broken beer bottle disintegrates in your hand, giving you some minor lacerations. A single tear drops from the corner of your eye.</b>"
			user.bruteloss += 10
			user.health = 100 - user.oxyloss - user.toxloss - user.fireloss - user.bruteloss
			del(src)
	else
		if (prob(5))
			user << "\blue <B>Woops! You dropped your bottle of beer and it shatters to a million pieces.</b>"
			del(src)
