#define REGULATE_RATE 5


/obj/substance/proc/leak(turf)
	return

/obj/substance/chemical/proc/volume()
	var/amount = 0
	for(var/item in src.chemicals)
		var/datum/chemical/C = src.chemicals[item]
		if (istype(C, /datum/chemical))
			amount += C.return_property("volume")
	return amount

/obj/substance/chemical/proc/split(amount)
	var/obj/substance/chemical/S = new /obj/substance/chemical( null )
	var/tot_volume = src.volume()
	if (amount > tot_volume)
		amount = tot_volume
		for(var/item in src.chemicals)
			var/C = src.chemicals[item]
			if (istype(C, /datum/chemical))
				S.chemicals[item] = C
				src.chemicals[item] = null
		return S
	else
		if (tot_volume <= 0)
			return S
		else
			for(var/item in src.chemicals)
				var/datum/chemical/C = src.chemicals[item]
				if (istype(C, /datum/chemical))
					var/datum/chemical/N = new C.type( null )
					C.copy_data(N)
					var/amt = C.return_property("volume") * amount / tot_volume
					C.moles -= amt * C.density / C.molarmass
					if (C.moles == 0)
						//C = null
						del(C)
					N.moles += amt * N.density / N.molarmass
					S.chemicals[text("[]", N.name)] = N
			return S
	return

/obj/substance/chemical/proc/transfer_from(var/obj/substance/chemical/S as obj, amount)
	var/volume = src.volume()
	var/s_volume = S.volume()
	if (amount > s_volume)
		amount = s_volume
	if (src.maximum)
		if (amount > (src.maximum - volume))
			amount = src.maximum - volume
	if (amount >= s_volume)
		for(var/item in S.chemicals)
			var/datum/chemical/C = S.chemicals[item]
			if (istype(C, /datum/chemical))
				var/datum/chemical/N = null
				N = src.chemicals[item]
				if (!( N ))
					N = new C.type( null )
					C.copy_data(N)
				N.moles += C.moles
				//C = null
				del(C)
	else
		var/obj/substance/chemical/U = S.split(amount)
		for(var/item in U.chemicals)
			var/datum/chemical/C = U.chemicals[item]
			if (istype(C, /datum/chemical))
				var/datum/chemical/N = src.chemicals[item]
				if (!( N ))
					N = new C.type( null )
					C.copy_data(N)
					src.chemicals[item] = N
				N.moles += C.moles
				//C = null
				del(C)
		//U = null
		del(U)
	var/datum/chemical/C = null
	for(var/t in src.chemicals)
		C = src.chemicals[text("[]", t)]
		if (istype(C, /datum/chemical))
			C.react(src)
	return amount

/obj/substance/chemical/proc/transfer_mob(var/mob/M as mob, amount)
	if (!( ismob(M) ))
		return
	var/obj/substance/chemical/S = src.split(amount)
	for(var/item in S.chemicals)
		var/datum/chemical/C = S.chemicals[item]
		if (istype(C, /datum/chemical))
			C.injected(M)
	//S = null
	del(S)
	return

/obj/substance/chemical/proc/dropper_mob(M as mob, amount)

	if (!( ismob(M) ))
		return
	var/obj/substance/chemical/S = src.split(amount)
	for(var/item in S.chemicals)
		var/datum/chemical/C = S.chemicals[item]
		if (istype(C, /datum/chemical))
			C.injected(M, "eye")
	del(S)

/obj/substance/chemical/Del()

	for(var/item in src.chemicals)
		//src.chemicals[item] = null
		del(src.chemicals[item])
		//Foreach goto(17)
	..()




/datum/chemical/pathogen/proc/process(source as obj)

	return

/datum/chemical/proc/react(S as obj)

	return

/datum/chemical/proc/react_organ(O as obj)

	return

/datum/chemical/proc/injected(M as mob, zone)

	if (zone == null)
		zone = "body"
	return

/datum/chemical/proc/copy_data(var/datum/chemical/C)

	C.molarmass = src.molarmass
	C.density = src.density
	C.chem_formula = src.chem_formula
	return

/datum/chemical/proc/return_property(property)

	switch(property)
		if("moles")
			return src.moles
		if("mass")
			return src.moles * src.molarmass
		if("density")
			return src.density
		if("volume")
			return src.moles * src.molarmass / src.density
		else
	return

/datum/chemical/pl_coag/react(obj/substance/chemical/S as obj)

	var/datum/chemical/l_plas/C = S.chemicals["plasma-l"]
	if (istype(C, /datum/chemical/l_plas))
		if (C.moles < src.moles)
			src.moles -= C.moles
			var/datum/chemical/waste/W = S.chemicals["waste-l"]
			if (istype(W, /datum/chemical/waste))
				W.moles += C.moles
			else
				W = new /datum/chemical/waste(  )
				S.chemicals["waste-l"] = W
				W.moles += C.moles
			//C = null
			del(C)
		else
			C.moles -= src.moles
			var/datum/chemical/waste/W = S.chemicals["waste-l"]
			if (istype(W, /datum/chemical/waste))
				W.moles += src.moles
			else
				W = new /datum/chemical/waste(  )
				S.chemicals["waste-l"] = W
				W.moles += src.moles
			src.moles = 0
		if (src.moles <= 0)
			//SN src = null
			del(src)
			return
	return

/datum/chemical/pl_coag/injected(var/mob/M as mob, zone)
	var/volume = src.return_property("volume")
	switch(zone)
		if("eye")
			M.eye_stat -= volume * 2
			M.eye_stat = max(0, M.eye_stat)
		else
			if (M.health >= 0)
				if ((volume * 4) >= M.toxloss)
					M.toxloss = 0
				else
					M.toxloss -= volume * 4
			M.antitoxs += volume * 180
			M.health = 100 - M.oxyloss - M.toxloss - M.fireloss - M.bruteloss
	return

/datum/chemical/l_plas/injected(var/mob/M as mob, zone)
	var/volume = src.return_property("volume")
	switch(zone)
		if("eye")
			M.eye_stat += volume * 5
			M.eye_blurry += volume * 3
			if (M.eye_stat >= 20)
				M << "\red Your eyes start to burn badly!"
				M.disabilities |= 1
				if (prob(M.eye_stat - 20 + 1))
					M << "\red You go blind!"
					M.sdisabilities |= 1
		else
			M.plasma += volume * 6
			for(var/obj/item/implant/tracking/T in M)
				M.plasma += 1
				del(T)
	return

/datum/chemical/s_tox/injected(var/mob/M as mob, zone)
	var/volume = src.return_property("volume")
	switch(zone)
		if("eye")
			M.eye_blind += volume * 10
			M.eye_blurry += volume * 15
		else
			M.paralysis += volume * 12
			if(M.stat != 2)	M.stat = 1
	return

/datum/chemical/epil/injected(var/mob/M as mob, zone)

	var/volume = src.return_property("volume")
	switch(zone)
		if("eye")
			M.eye_blind += volume * 5
			M.eye_stat += volume * 2
			M.eye_blurry += volume * 20
			if (M.eye_stat >= 20)
				M << "\red Your eyes start to burn badly!"
				M.disabilities |= 1
				if (prob(M.eye_stat - 20 + 1))
					M << "\red You go blind!"
					M.sdisabilities |= 1
		else
			M.r_epil += volume * 60
	return

/datum/chemical/ch_cou/injected(var/mob/M as mob, zone)

	var/volume = src.return_property("volume")
	switch(zone)
		if("eye")
			M.eye_blind += volume * 2
			M.eye_stat += volume * 3
			M.eye_blurry += volume * 20
			M << "\red Your eyes start to burn badly!"
			M.disabilities |= 1
			if (prob(M.eye_stat - 20 + 1))
				M << "\red You go blind!"
				M.sdisabilities |= 1
		else
			M.r_ch_cou += volume * 60
	return

/datum/chemical/rejuv/injected(var/mob/M as mob, zone)

	var/volume = src.return_property("volume")
	switch(zone)
		if("eye")
			M.eye_stat -= volume * 5
			M.eye_blurry += volume * 5
			M.eye_stat = max(0, M.eye_stat)
		else
			M.rejuv += volume * 3
			if (M.paralysis)
				M.paralysis = 3
			if (M.weakened)
				M.weakened = 3
			if (M.stunned)
				M.stunned = 3
	return
