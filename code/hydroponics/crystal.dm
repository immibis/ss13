datum/plant/crystal
	name = "crystal plant"
	id = "crystal"
	base_harvests = 2
	base_yield = 4
	base_maturation = 1
	base_production = 0.5
	fruit_type = /obj/item/shard/crystal

obj/item/shard/crystal
	icon = 'icons/isno/Hydroponics/Items/crystal.dmi'
	icon_state = "1"

	New()
		. = ..()
		icon_state = "[rand(1, 3)]"
		pixel_x = rand(-11, 11)
		pixel_y = rand(-11, 11)
	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weldingtool))
			new /obj/item/sheet/crystal(user.loc)
			del(src)
		else
			. = ..()

obj/item/sheet/crystal
	icon = 'icons/isno/Hydroponics/Items/crystal.dmi'
	icon_state = "sheet"

	name = "plasma crystal"
	force = 5.0

	attack_self(mob/user as mob)
		if (!( istype(user.loc, /turf/simulated) ))
			return
		if (!(istype(user, /mob/human) || ticker) && ticker.mode.name != "monkey")
			usr << "\red You don't have the dexterity to do this!"
			return
		switch(alert("Sheet-Crystal", "Would you like full tile glass or one direction?", "one direct", "full (2 sheets)", "cancel", null))
			if("one direct")
				var/obj/window/W = new /obj/window/crystal( user.loc )
				W.anchored = 0
				if (src.amount < 1)
					return
				src.amount--
			if("full (2 sheets)")
				if (src.amount < 2)
					return
				src.amount -= 2
				var/obj/window/W = new /obj/window/crystal( user.loc )
				W.dir = SOUTHWEST
				W.ini_dir = SOUTHWEST
				W.anchored = 0
			else
		if (src.amount <= 0)
			user.unequip(src)
			del(src)

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/sheet/crystal))
			var/obj/item/sheet/crystal/G = W
			if (G.amount >= 5)
				return
			if (G.amount + src.amount > 5)
				src.amount = G.amount + src.amount - 5
				G.amount = 5
			else
				G.amount += src.amount
				//SN src = null
				del(src)
				return
			return
		else if(istype(W, /obj/item/rods))
			var/obj/item/rods/V = W
			var/obj/item/sheet/rcrystal/R = new /obj/item/sheet/rcrystal(user.loc)
			R.loc = user.loc
			R.add_fingerprint(user)

			if(V.amount == 1)
				user.unequip(W)
				del(W)
			else
				V.amount--

			if(src.amount == 1)
				user.unequip(src)
				del(src)
			else
				src.amount--
		else
			. = ..()

	examine()
		set src in view()
		..()
		usr << text("There are [] crystal sheet\s on the stack.", src.amount)

/obj/item/sheet/rcrystal
	name = "reinforced plasma crystal"
	icon = 'icons/isno/Hydroponics/Items/crystal.dmi'
	icon_state = "rsheet"
	force = 6.0

	attack_self(mob/user as mob)
		if (!istype(user.loc, /turf/simulated))
			return
		if (!(istype(user, /mob/human) || ticker) && ticker.mode.name != "monkey")
			usr << "\red You don't have the dexterity to do this!"
			return
		switch(alert("Sheet Reinf. Crystal", "Would you like full tile glass or one direction?", "one direct", "full (2 sheets)", "cancel", null))
			if("one direct")
				var/obj/window/W = new /obj/window/crystal( user.loc, 1 )
				W.anchored = 0
				W.state = 0
				if (src.amount < 1)
					return
				src.amount--
			if("full (2 sheets)")
				if (src.amount < 2)
					return
				src.amount -= 2
				var/obj/window/W = new /obj/window/crystal( user.loc, 1 )
				W.dir = SOUTHWEST
				W.ini_dir = SOUTHWEST
				W.anchored = 0
				W.state = 0
			else
		if (src.amount <= 0)
			user.unequip(src)
			del(src)

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/sheet/rcrystal))
			var/obj/item/sheet/rcrystal/G = W
			if (G.amount >= 5)
				return
			if (G.amount + src.amount > 5)
				src.amount = G.amount + src.amount - 5
				G.amount = 5
			else
				G.amount += src.amount
				del(src)
		else
			. = ..()

	examine()
		set src in view()
		..()
		usr << text("There are [] reinforced crystal sheet\s on the stack.", src.amount)

/obj/window/crystal
	icon = 'icons/isno/Hydroponics/Items/crystal.dmi'
	icon_state = "window"

	reinforced
		reinf = 1
		icon_state = "rwindow"

	destroy()
		for(var/k = 1 to (dir == SOUTHWEST ? 2 : 1))
			new /obj/item/shard/crystal( src.loc )
			if(reinf) new /obj/item/rods( src.loc)
			src.density = 0
			src.loc.buildlinks()
			del(src)