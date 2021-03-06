/obj/secloset/blob_act()
	if (prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/secloset/alter_health()
	var/turf/T = get_turf(src)	//don't ask why we alter temperature in here. fuck this build
	return T

/obj/secloset/CheckPass(O as mob|obj, target as turf)
	if (!( src.opened ))
		return 0
	else
		return 1
	return

/obj/secloset/personal/var/registered = null
/obj/secloset/personal/req_access = list("access_all_personal_lockers")

/obj/secloset/personal/New()
	..()
	sleep(2)
	new /obj/item/radio/signaler( src )
	new /obj/item/pen( src )
	new /obj/item/storage/backpack( src )
	new /obj/item/radio/headset( src )
	return

/obj/secloset/personal/attackby(obj/item/W as obj, mob/user as mob)
	if (src.opened)
		if (istype(W, /obj/item/grab))
			src.MouseDrop_T(W:affecting, user)      //act like they were dragged onto the closet
		user.drop_item()
		if (W) W.loc = src.loc
	else if (istype(W, /obj/item/card/id))
		if(src.broken)
			user << "\red It appears to be broken."
			return
		var/obj/item/card/id/I = W
		if (src.allowed(user) || !src.registered || (istype(W, /obj/item/card/id) && src.registered == I.registered))
			//they can open all lockers, or nobody owns this, or they own this locker
			src.locked = !( src.locked )
			for(var/mob/O in viewers(user, 3))
				if ((O.client && !( O.blinded )))
					O << text("\blue The locker has been []locked by [].", (src.locked ? null : "un"), user)
			src.icon_state = text("[]secloset0", (src.locked ? "1" : null))
			if (!src.registered)
				src.registered = I.registered
				src.desc = "Owned by [I.registered]."
		else
			user << "\red Access Denied"
	else if(istype(W, /obj/item/card/emag) && !src.broken)
		src.broken = 1
		src.locked = 0
		src.desc = "It appears to be broken."
		src.icon = 'icons/ss13/secloset_broken.dmi'
		src.icon_state = "secloset0"
		for(var/mob/O in viewers(user, 3))
			if ((O.client && !( O.blinded )))
				O << text("\blue The locker has been broken by [user] with an electromagnetic card!")
	else
		user << "\red Access Denied"
	return

/obj/secloset/security2/New()
	..()
	sleep(2)
	new /obj/item/clothing/under/forensics_red( src )
	new /obj/item/storage/fcard_kit( src )
	new /obj/item/storage/fcard_kit( src )
	new /obj/item/storage/fcard_kit( src )
	new /obj/item/storage/lglo_kit( src )
	new /obj/item/storage/lglo_kit( src )
	new /obj/item/fcardholder( src )
	new /obj/item/fcardholder( src )
	new /obj/item/fcardholder( src )
	new /obj/item/fcardholder( src )
	new /obj/item/f_print_scanner( src )
	new /obj/item/f_print_scanner( src )
	new /obj/item/f_print_scanner( src )
	return

/obj/secloset/security1/New()
	..()
	sleep(2)
	new /obj/item/storage/flashbang_kit(src)
	new /obj/item/handcuffs(src)
	new /obj/item/gun/energy/taser_gun(src)
	new /obj/item/flash(src)
	new /obj/item/clothing/under/red(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/suit/armor(src)
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/baton(src)
	return

/obj/secloset/highsec/New()
	..()
	sleep(2)
	new /obj/item/gun/energy/laser_gun( src )
	new /obj/item/gun/energy/taser_gun( src )
	new /obj/item/flash( src )
	new /obj/item/storage/id_kit( src )
	new /obj/item/clothing/under/green( src )
	new /obj/item/clothing/shoes/brown( src )
	new /obj/item/clothing/glasses/sunglasses( src )
	new /obj/item/clothing/suit/armor( src )
	new /obj/item/clothing/head/helmet( src )
	return

/obj/secloset/captains/New()
	..()
	sleep(2)
	new /obj/item/gun/energy/laser_gun( src )
	new /obj/item/gun/energy/taser_gun( src )
	new /obj/item/storage/id_kit( src )
	new /obj/item/clothing/under/darkgreen( src )
	new /obj/item/clothing/shoes/brown( src )
	new /obj/item/clothing/glasses/sunglasses( src )
	new /obj/item/clothing/suit/armor( src )
	new /obj/item/clothing/head/helmet/swat_hel( src )
	return

/obj/secloset/animal/New()
	..()
	sleep(2)
	new /obj/item/radio/signaler( src )
	new /obj/item/radio/electropack( src )
	new /obj/item/radio/electropack( src )
	new /obj/item/radio/electropack( src )
	new /obj/item/radio/electropack( src )
	new /obj/item/radio/electropack( src )
	return

/obj/secloset/medical1/New()
	..()
	sleep(2)
	//new /obj/item/bottle/toxins( src )
	new /obj/item/reagent/bottle/inaprovaline( src )
	new /obj/item/reagent/bottle/inaprovaline( src )
	new /obj/item/reagent/bottle/inaprovaline( src )
	new /obj/item/reagent/bottle/inaprovaline( src )
	new /obj/item/reagent/bottle/sleep_toxin( src )
	new /obj/item/reagent/bottle/sleep_toxin( src )
	new /obj/item/reagent/bottle/sleep_toxin( src )
	//new /obj/item/bottle/toxins( src )
	//new /obj/item/bottle/r_epil( src )
	//new /obj/item/bottle/r_ch_cough( src )
	new /obj/item/pill_canister/Tourette( src )
	new /obj/item/pill_canister/cough( src )
	new /obj/item/pill_canister/epilepsy( src )
	new /obj/item/pill_canister/sleep( src )
	new /obj/item/pill_canister/antitoxin( src )
	new /obj/item/pill_canister/placebo( src )
	new /obj/item/storage/syringe( src )
	new /obj/item/storage/gl_kit( src )
	new /obj/item/dropper( src )
	return

/obj/secloset/medical2/New()
	..()
	sleep(2)
	new /obj/item/tank/anesthetic( src )
	new /obj/item/tank/anesthetic( src )
	new /obj/item/tank/anesthetic( src )
	new /obj/item/tank/anesthetic( src )
	new /obj/item/tank/anesthetic( src )
	new /obj/item/clothing/mask/m_mask( src )
	new /obj/item/clothing/mask/m_mask( src )
	new /obj/item/clothing/mask/m_mask( src )
	new /obj/item/clothing/mask/m_mask( src )
	return

/obj/secloset/toxin/New()
	..()
	sleep(2)
	new /obj/item/tank/oxygen( src )
	new /obj/item/clothing/mask/gasmask( src )
	new /obj/item/clothing/suit/bio_suit( src )
	new /obj/item/clothing/under/toxins_white( src )
	new /obj/item/clothing/shoes/white( src )
	new /obj/item/clothing/gloves/latex( src )
	new /obj/item/clothing/head/bio_hood( src )
	new /obj/item/clothing/suit/labcoat(src)
	return

/obj/secloset/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		if(3.0)
			if (prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		else
	return

/obj/secloset/blob_act()
	if (prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/secloset/meteorhit(obj/O as obj)
	if (O.icon_state == "flaming")
		for(var/obj/item/I in src)
			I.loc = src.loc
		for(var/mob/M in src)
			M.loc = src.loc
			if (M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
		src.icon_state = "secloset1"
		del(src)
		return
	return

/obj/secloset/attackby(obj/item/W as obj, mob/user as mob)
	if (src.opened)
		if (istype(W, /obj/item/grab))
			src.MouseDrop_T(W:affecting, user)	//act like they were dragged onto the closet
		user.drop_item()
		if (W)
			W.loc = src.loc
	else if(src.broken)
		user << "\red It appears to be broken."
		return
	else if(istype(W, /obj/item/card/emag) && !src.broken)
		src.broken = 1
		src.locked = 0
		src.icon = 'icons/ss13/secloset_broken.dmi'
		src.icon_state = "secloset0"
		for(var/mob/O in viewers(user, 3))
			if ((O.client && !( O.blinded )))
				O << text("\blue The locker has been broken by [user] with an electromagnetic card!")
	else if(src.allowed(user))
		src.locked = !src.locked
		for(var/mob/O in viewers(user, 3))
			if ((O.client && !( O.blinded )))
				O << text("\blue The locker has been []locked by [].", (src.locked ? null : "un"), user)
		src.icon_state = text("[]secloset0", (src.locked ? "1" : null))
	else
		user << "\red Access Denied"
	return

/obj/secloset/relaymove(mob/user as mob)
	if (user.stat)
		return
	if (!( src.locked ))
		for(var/obj/item/I in src)
			I.loc = src.loc
		for(var/mob/M in src)
			M.loc = src.loc
			if (M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
		src.icon_state = "secloset1"
		src.opened = 1
	else
		user << "\blue It's welded shut!"
		for(var/mob/M in hearers(src, null))
			M << text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M)))
	return

/obj/secloset/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if ((user.restrained() || user.stat))
		return
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if(!src.opened)
		return
	step_towards(O, src.loc)
	if (user != O)
		for(var/mob/B in viewers(user, 3))
			if ((B.client && !( B.blinded )))
				B << text("\red [] stuffs [] into []!", user, O, src)
	src.add_fingerprint(user)
	return

/obj/secloset/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if (!src.opened && !src.locked)
		//open it
		for(var/obj/item/I in src)
			I.loc = src.loc
		for(var/mob/M in src)
			M.loc = src.loc
			if (M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
		src.icon_state = "secloset1"
		src.opened = 1
	else if(src.opened)
		//close it
		for(var/obj/item/I in src.loc)
			if (!( I.anchored ))
				I.loc = src
		for(var/mob/M in src.loc)
			if (M.buckled)
				continue
			if (M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.loc = src
		src.icon_state = "secloset0"
		src.opened = 0
	else
		return src.attackby(null, user)
	return

/obj/secloset/attack_paw(mob/user as mob)
	return src.attack_hand(user)

