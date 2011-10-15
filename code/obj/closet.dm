/obj/closet/meteorhit(obj/O as obj)
	if (O.icon_state == "flaming")
		for(var/obj/item/I in src)
			I.loc = src.loc
		for(var/mob/M in src)
			M.loc = src.loc
			if (M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
		src.icon_state = src.icon_opened
		del(src)
		return
	return

/obj/closet/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (!user.can_use_hands())
		return
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if (user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if (!istype(user.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(!src.opened)
		return
	step_towards(O, src.loc)
	user.show_viewers(text("\red [] stuffs [] into []!", user, O, src))
	src.add_fingerprint(user)
	return

/obj/closet/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (src.opened)
		if (istype(W, /obj/item/weapon/grab))
			src.MouseDrop_T(W:affecting, user)      //act like they were dragged onto the closet
		user.drop_item()
		if (W)
			W.loc = src.loc
	else if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if (W:weldfuel < 2)
			user << "\blue You need more welding fuel to complete this task."
			return
		W:weldfuel -= 2
		src.welded =! src.welded
		for(var/mob/M in viewers(src))
			M.show_message("\red [src] has been [welded?"welded shut":"unwelded"] by [user.name].", 3, "\red You hear welding.", 2)
	else
		src.attack_hand(user)
	return

/obj/closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if (!src.opened)
		if (!src.welded)
			for(var/obj/item/I in src)
				I.loc = src.loc
			for(var/mob/M in src)
				M.loc = src.loc
				if (M.client)
					M.client.eye = M.client.mob
					M.client.perspective = MOB_PERSPECTIVE
			src.icon_state = src.icon_opened
			src.opened = 1
		else
			usr << "\blue It's welded shut!"
	else
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
		src.icon_state = src.icon_closed
		src.opened = 0
	return

/obj/closet/relaymove(mob/user as mob)

	if (user.stat)
		return
	if (!( src.welded ))
		for(var/obj/item/I in src)
			I.loc = src.loc
		for(var/mob/M in src)
			M.loc = src.loc
			if (M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
		src.icon_state = src.icon_opened
		src.opened = 1
	else
		user << "\blue It's welded shut!"
		for(var/mob/M in hearers(src, null))
			M << text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M)))
	return

/obj/closet/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)

	if ((user.restrained() || user.stat))
		return
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if (user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if (!istype(user.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(!src.opened)
		return
	step_towards(O, src.loc)
	for(var/mob/M in viewers(user, null))
		if ((M.client && !( M.blinded )))
			M << text("\red [] stuffs [] into []!", user, O, src)
	src.add_fingerprint(user)
	return

/obj/closet/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if (!src.opened)
		if (!src.welded)
			for(var/obj/item/I in src)
				I.loc = src.loc
			for(var/mob/M in src)
				if (!( M.buckled ))
					M.loc = src.loc
					if (M.client)
						M.client.eye = M.client.mob
						M.client.perspective = MOB_PERSPECTIVE
			src.icon_state = src.icon_opened
			src.opened = 1
		else
			usr << "\blue It's welded shut!"
	else
		for(var/obj/item/I in src.loc)
			if (!I.anchored)
				I.loc = src
		for(var/mob/M in src.loc)
			if (M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.loc = src
		src.icon_state = src.icon_closed
		src.opened = 0
	return

/obj/closet/CheckPass(O as mob|obj, target as turf)

	if (!( src.opened ))
		return 0
	else
		return 1
	return

/obj/closet/alter_health()
	return src.loc

/obj/closet/CheckPass(O as mob|obj, target as turf)
	if(!src.opened)
		return 0
	else
		return 1
	return

/obj/closet/syndicate/nuclear/New()
	..()
	sleep(2)
	new /obj/item/weapon/ammo/a357( src )
	new /obj/item/weapon/ammo/a357( src )
	new /obj/item/weapon/ammo/a357( src )
	new /obj/item/weapon/storage/handcuff_kit( src )
	new /obj/item/weapon/storage/flashbang_kit( src )
	new /obj/item/weapon/gun/energy/taser_gun( src )
	new /obj/item/weapon/gun/energy/taser_gun( src )
	new /obj/item/weapon/gun/energy/taser_gun( src )
	var/obj/item/weapon/syndicate_uplink/U = new /obj/item/weapon/syndicate_uplink( src )
	U.uses = 5
	return

/obj/closet/syndicate/personal/New()
	..()
	sleep(2)
	new /obj/item/weapon/tank/jetpack(src)
	new /obj/item/weapon/clothing/mask/m_mask(src)
	new /obj/item/weapon/clothing/head/s_helmet(src)
	new /obj/item/weapon/clothing/suit/sp_suit(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/cell(src)
	new /obj/item/weapon/card/id/syndicate(src)
	new /obj/item/weapon/multitool(src)

/obj/closet/emcloset/New()
	..()
	sleep(2)
	new /obj/item/weapon/tank/oxygentank( src )
	new /obj/item/weapon/clothing/mask/gasmask( src )
	return

/obj/closet/l3closet/New()
	..()
	sleep(2)
	new /obj/item/weapon/clothing/suit/bio_suit( src )
	new /obj/item/weapon/clothing/under/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/head/bio_hood( src )

	return

/obj/closet/wardrobe/New()
	new /obj/item/weapon/clothing/under/blue( src )
	new /obj/item/weapon/clothing/under/blue( src )
	new /obj/item/weapon/clothing/under/blue( src )
	new /obj/item/weapon/clothing/under/blue( src )
	new /obj/item/weapon/clothing/under/blue( src )
	new /obj/item/weapon/clothing/under/blue( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	return

/obj/closet/wardrobe/red/New()
	new /obj/item/weapon/clothing/under/red( src )
	new /obj/item/weapon/clothing/under/red( src )
	new /obj/item/weapon/clothing/under/red( src )
	new /obj/item/weapon/clothing/under/red( src )
	new /obj/item/weapon/clothing/under/red( src )
	new /obj/item/weapon/clothing/under/red( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	return
/obj/closet/wardrobe/forensics_red/New()
	new /obj/item/weapon/clothing/under/forensics_red( src )
	new /obj/item/weapon/clothing/under/forensics_red( src )
	new /obj/item/weapon/clothing/under/forensics_red( src )
	new /obj/item/weapon/clothing/under/forensics_red( src )
	new /obj/item/weapon/clothing/under/forensics_red( src )
	new /obj/item/weapon/clothing/under/forensics_red( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	return

/obj/closet/wardrobe/pink/New()
	new /obj/item/weapon/clothing/under/pink( src )
	new /obj/item/weapon/clothing/under/pink( src )
	new /obj/item/weapon/clothing/under/pink( src )
	new /obj/item/weapon/clothing/under/pink( src )
	new /obj/item/weapon/clothing/under/pink( src )
	new /obj/item/weapon/clothing/under/pink( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	return

/obj/closet/wardrobe/black/New()
	new /obj/item/weapon/clothing/under/black( src )
	new /obj/item/weapon/clothing/under/black( src )
	new /obj/item/weapon/clothing/under/black( src )
	new /obj/item/weapon/clothing/under/black( src )
	new /obj/item/weapon/clothing/under/black( src )
	new /obj/item/weapon/clothing/under/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	return
/obj/closet/wardrobe/chaplain_black/New()
	new /obj/item/weapon/clothing/under/chaplain_black( src )
	new /obj/item/weapon/clothing/under/chaplain_black( src )
	new /obj/item/weapon/clothing/under/chaplain_black( src )
	new /obj/item/weapon/clothing/under/chaplain_black( src )
	new /obj/item/weapon/clothing/under/chaplain_black( src )
	new /obj/item/weapon/clothing/under/chaplain_black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	return

/obj/closet/wardrobe/green/New()
	new /obj/item/weapon/clothing/under/green( src )
	new /obj/item/weapon/clothing/under/green( src )
	new /obj/item/weapon/clothing/under/green( src )
	new /obj/item/weapon/clothing/under/green( src )
	new /obj/item/weapon/clothing/under/green( src )
	new /obj/item/weapon/clothing/under/green( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	return

/obj/closet/wardrobe/orange/New()
	new /obj/item/weapon/clothing/under/orange( src )
	new /obj/item/weapon/clothing/under/orange( src )
	new /obj/item/weapon/clothing/under/orange( src )
	new /obj/item/weapon/clothing/under/orange( src )
	new /obj/item/weapon/clothing/under/orange( src )
	new /obj/item/weapon/clothing/under/orange( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	return

/obj/closet/wardrobe/yellow/New()
	new /obj/item/weapon/clothing/under/yellow( src )
	new /obj/item/weapon/clothing/under/yellow( src )
	new /obj/item/weapon/clothing/under/yellow( src )
	new /obj/item/weapon/clothing/under/yellow( src )
	new /obj/item/weapon/clothing/under/yellow( src )
	new /obj/item/weapon/clothing/under/yellow( src )
	new /obj/item/weapon/clothing/shoes/orange( src )
	new /obj/item/weapon/clothing/shoes/orange( src )
	new /obj/item/weapon/clothing/shoes/orange( src )
	new /obj/item/weapon/clothing/shoes/orange( src )
	new /obj/item/weapon/clothing/shoes/orange( src )
	new /obj/item/weapon/clothing/shoes/orange( src )
	return
/obj/closet/wardrobe/atmospherics_yellow/New()
	new /obj/item/weapon/clothing/under/atmospherics_yellow( src )
	new /obj/item/weapon/clothing/under/atmospherics_yellow( src )
	new /obj/item/weapon/clothing/under/atmospherics_yellow( src )
	new /obj/item/weapon/clothing/under/atmospherics_yellow( src )
	new /obj/item/weapon/clothing/under/atmospherics_yellow( src )
	new /obj/item/weapon/clothing/under/atmospherics_yellow( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	return
/obj/closet/wardrobe/engineering_yellow/New()
	new /obj/item/weapon/clothing/under/engineering_yellow( src )
	new /obj/item/weapon/clothing/under/engineering_yellow( src )
	new /obj/item/weapon/clothing/under/engineering_yellow( src )
	new /obj/item/weapon/clothing/under/engineering_yellow( src )
	new /obj/item/weapon/clothing/under/engineering_yellow( src )
	new /obj/item/weapon/clothing/under/engineering_yellow( src )
	new /obj/item/weapon/clothing/shoes/orange( src )
	new /obj/item/weapon/clothing/shoes/orange( src )
	new /obj/item/weapon/clothing/shoes/orange( src )
	new /obj/item/weapon/clothing/shoes/orange( src )
	new /obj/item/weapon/clothing/shoes/orange( src )
	new /obj/item/weapon/clothing/shoes/orange( src )
	return

/obj/closet/wardrobe/white/New()
	new /obj/item/weapon/clothing/under/white( src )
	new /obj/item/weapon/clothing/under/white( src )
	new /obj/item/weapon/clothing/under/white( src )
	new /obj/item/weapon/clothing/under/white( src )
	new /obj/item/weapon/clothing/under/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/storage/stma_kit( src )
	new /obj/item/weapon/clothing/suit/labcoat(src)
	new /obj/item/weapon/clothing/suit/labcoat(src)
	new /obj/item/weapon/clothing/suit/labcoat(src)
	return
/obj/closet/wardrobe/toxins_white/New()
	new /obj/item/weapon/clothing/under/toxins_white( src )
	new /obj/item/weapon/clothing/under/toxins_white( src )
	new /obj/item/weapon/clothing/under/toxins_white( src )
	new /obj/item/weapon/clothing/under/toxins_white( src )
	new /obj/item/weapon/clothing/under/toxins_white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/storage/stma_kit( src )
	new /obj/item/weapon/clothing/suit/labcoat(src)
	new /obj/item/weapon/clothing/suit/labcoat(src)
	new /obj/item/weapon/clothing/suit/labcoat(src)
	return
/obj/closet/wardrobe/genetics_white/New()
	new /obj/item/weapon/clothing/under/genetics_white( src )
	new /obj/item/weapon/clothing/under/genetics_white( src )
	new /obj/item/weapon/clothing/under/genetics_white( src )
	new /obj/item/weapon/clothing/under/genetics_white( src )
	new /obj/item/weapon/clothing/under/genetics_white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/clothing/shoes/white( src )
	new /obj/item/weapon/storage/stma_kit( src )
	new /obj/item/weapon/clothing/suit/labcoat(src)
	new /obj/item/weapon/clothing/suit/labcoat(src)
	new /obj/item/weapon/clothing/suit/labcoat(src)
	return
/obj/closet/wardrobe/grey/New()
	new /obj/item/weapon/clothing/under/grey( src )
	new /obj/item/weapon/clothing/under/grey( src )
	new /obj/item/weapon/clothing/under/grey( src )
	new /obj/item/weapon/clothing/under/grey( src )
	new /obj/item/weapon/clothing/under/grey( src )
	new /obj/item/weapon/clothing/under/grey( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	new /obj/item/weapon/clothing/shoes/black( src )
	return

/obj/closet/wardrobe/mixed/New()
	new /obj/item/weapon/clothing/under/blue( src )
	new /obj/item/weapon/clothing/under/blue( src )
	new /obj/item/weapon/clothing/under/blue( src )
	new /obj/item/weapon/clothing/under/pink( src )
	new /obj/item/weapon/clothing/under/pink( src )
	new /obj/item/weapon/clothing/under/pink( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	new /obj/item/weapon/clothing/shoes/brown( src )
	return

/obj/closet/ex_act(severity)
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


