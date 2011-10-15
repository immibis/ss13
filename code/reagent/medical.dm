/datum/reagent
	antitoxins
		name = "antitoxins"
		inject_mob(mob/M)
			if (M.health >= 0)
				if ((amount * 4) >= M.toxloss)
					M.toxloss = 0
				else
					M.toxloss -= amount * 4
			M.antitoxs += amount * 180
			M.health = 100 - M.oxyloss - M.toxloss - M.fireloss - M.bruteloss

	liquid_plasma
		name = "liquid plasma"
		inject_mob(mob/M)
			M.plasma += amount * 6
			for(var/obj/item/weapon/implant/tracking/T in M)
				M.plasma += 1
				del(T)

	sleep_toxin
		name = "sleep toxin"
		inject_mob(mob/M)
			M.paralysis += amount * 12
			if(M.stat != 2)	M.stat = 1

	rejuvenators
		name = "rejuvenators"
		inject_mob(mob/M)
			M.rejuv += amount * 3
			if (M.paralysis)
				M.paralysis = 3
			if (M.weakened)
				M.weakened = 3
			if (M.stunned)
				M.stunned = 3

