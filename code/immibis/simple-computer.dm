/obj/machinery/computer
	name = "computer"
	density = 1
	anchored = 1

	networked = 1

	icon = 'icons/immibis/computer.dmi'
	icon_state = "frame"

	var/c_type = null

	// change this to change the overlay displayed on the screen
	var/display = ""

	New()
		. = ..()
		if(!c_type)
			c_type = copytext("[type]", lentext("/obj/machinery/computer/") + 1)
		spawn updateicon()

	ex_act(severity)
		switch(severity)
			if(1)
				del(src)
			if(2)
				if(prob(50))
					for(var/x in src.verbs)
						src.verbs -= x
					stat |= BROKEN
					updateicon()
			if(3)
				if(prob(25))
					for(var/x in src.verbs)
						src.verbs -= x
					stat |= BROKEN
					updateicon()

	power_change()
		updateicon()

	proc/updateicon()
		if(icon != 'icons/immibis/computer.dmi' || icon_state != "frame")
			world.log << "[type] overrides its icon"
			return // don't change subclasses that override their own icons
		overlays = null
		var/ovl_state = "[c_type]-ovl"
		var/kb_state = "[c_type]-kb"
		var/disp_state = display ? "[c_type]-[display]" : c_type;
		if(ovl_state in icon_states(icon))
			overlays += image(icon, ovl_state)
		if(stat & NOPOWER)
			return
		if(stat & BROKEN)
			overlays += image(icon, "broken")
		else
			if(!(kb_state in icon_states(icon)))
				kb_state = "keyboard"
			overlays += image(icon, kb_state)
			overlays += image(icon, disp_state)

	meteorhit(var/obj/O as obj)
		for(var/x in src.verbs)
			src.verbs -= x
		src.icon_state = "broken"
		stat |= BROKEN
		var/obj/effects/smoke/pasta = new /obj/effects/smoke( src.loc )
		pasta.dir = pick(NORTH, SOUTH, EAST, WEST)
		spawn(0)
			pasta.Life()

	blob_act()
		if (prob(50))
			for(var/x in src.verbs)
				src.verbs -= x
			src.icon_state = "broken"
			src.stat |= BROKEN
			src.density = 0

	power_change()
		if(stat & BROKEN)
			icon_state = "broken"
		else if(powered())
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "c_unpowered"
				stat |= NOPOWER


	process()
		if(stat & (NOPOWER|BROKEN))
			return
		use_power(COMPUTER_POWER)

