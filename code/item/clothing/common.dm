/obj/item/clothing/burn(fi_amount)
	if (fi_amount > src.s_fire)
		spawn( 0 )
			var/t = src.icon_state
			src.icon_state = ""
			src.icon = 'icons/ss13/b_items.dmi'
			flick(text("[]", t), src)
			spawn(14)
				del(src)
				return
			return
		return 0
	return 1

/obj/item/clothing/gloves/examine()
	set src in usr
	..()
	return

/obj/item/clothing/shoes/orange/attack_self(mob/user as mob)
	if (src.chained)
		src.chained = null
		new /obj/item/handcuffs( user.loc )
		src.icon_state = "o_shoes"
	return

/obj/item/clothing/shoes/orange/attackby(H as obj, loc)
	if ((istype(H, /obj/item/handcuffs) && !( src.chained )))
		//H = null
		del(H)
		src.chained = 1
		src.icon_state = "o_shoes1"
	return

/obj/item/clothing/mask/muzzle/attack_paw(mob/user as mob)
	if (src == user.wear_mask)
		return
	else
		..()
	return

