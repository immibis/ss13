/mob/proc/check_burning()
	if(!src.loc) return 0
	var/turf/T = src.loc
	if(!isturf(T)) return 0
	if(T.firelevel < 900000) return 0
	if(!T.gas.total_moles) return 0
	var/resist = T0C + 80	//	highest non-burning temperature
	var/fire_dam = T.gas.temperature
	if (istype(src, /mob/human))
		var/mob/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		if(H.wear_suit) resist = H.wear_suit.fire_resist
		if(fire_dam < resist) return 0
		var/divided_damage = (fire_dam-resist)/(H.organs.len)*(FIRE_DAMAGE_MODIFIER)
		var/obj/item/weapon/organ/external/affecting = null
		var/extradam = 0	//added to when organ is at max dam
		for(var/A in H.organs)
			if(!H.organs[A])	continue
			affecting = H.organs[A]
			if(!istype(affecting, /obj/item/weapon/organ/external))	continue
			if(affecting.take_damage(0, divided_damage+extradam))
				extradam = 0
			else
				extradam += divided_damage
		H.UpdateDamageIcon()
		return 1
	else if(istype(src, /mob/monkey))
		var/mob/monkey/M = src
		if(fire_dam < resist) return 0
		M.fireloss += (fire_dam-resist)*(FIRE_DAMAGE_MODIFIER)
		M.updatehealth()
		return 1
	else if(istype(src, /mob/ai))
		return 0
	else
		if(Debug)	world.log << "check_burning has unrecognized mob: [src]"
		return 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/proc/burn_skin(burn_amount)
	if(istype(src, /mob/human))
		var/mob/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/obj/item/weapon/organ/external/affecting = null
		var/extradam = 0	//added to when organ is at max dam
		for(var/A in H.organs)
			if(!H.organs[A])	continue
			affecting = H.organs[A]
			if(!istype(affecting, /obj/item/weapon/organ/external))	continue
			if(affecting.take_damage(0, divided_damage+extradam))
				extradam = 0
			else
				extradam += divided_damage
		H.UpdateDamageIcon()
		return 1
	else if(istype(src, /mob/monkey))
		var/mob/monkey/M = src
		M.fireloss += burn_amount
		M.updatehealth()
		return 1
	else if(istype(src, /mob/ai))
		return 0
