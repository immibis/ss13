// this object allows power monitoring computers on one powernet to access devices on another powernet
// without actually connecting the nets
// one powernet is connected via a terminal and one directly
// it draws power from the directly-connected net, or the terminal-connected net, in that order

obj/machinery/power/control_info_relay
	var
		operational = 1
		lastusage = 0
		connections = 0
		lastconnections = 0
		obj/machinery/power/terminal/terminal
		n_tag = null

	anchored = 1
	opacity = 0
	density = 1

	directwired = 1

	icon = 'icons/immibis/immibis_power.dmi'
	icon_state = "cir_on"
	name = "Control Information Relay"

	New()
		. = ..()
		spawn(5)
			dir_loop:
				for(var/d in cardinal)
					var/turf/T = get_step(src, d)
					for(var/obj/machinery/power/terminal/term in T)
						if(term && term.dir == turn(d, 180))
							terminal = term
							break dir_loop

			if(!terminal)
				stat |= BROKEN
				return

			terminal.master = src

			updateicon()

	proc/updateicon()
		if(stat & BROKEN)
			icon_state = "cir_broken"
		else if(operational)
			icon_state = "cir_on"
		else
			icon_state = "cir_off"

	process()
		if((stat & BROKEN) || !terminal)
			return
		lastconnections = connections
		connections = 0
		if(operational)
			lastusage = lastconnections * CIR_ACCESSED_POWER + CIR_ON_POWER
			if(surplus() < CIR_ON_POWER)
				if(terminal.surplus() < CIR_ON_POWER)
					operational = 0
					updateicon()
				else
					terminal.add_load(CIR_ON_POWER)
			else
				add_load(CIR_ON_POWER)
		else
			lastusage = lastconnections * CIR_ACCESSED_POWER // might've been accessed before it was turned off
		. = ..()

	proc/accessed()
		if(!operational)
			return 0
		if(stat & BROKEN)
			return 0
		if(surplus() >= CIR_ACCESSED_POWER)
			add_load(CIR_ACCESSED_POWER)
			connections += 1
			return 1
		else if(terminal.surplus() >= CIR_ACCESSED_POWER)
			terminal.add_load(CIR_ACCESSED_POWER)
			connections += 1
			return 1
		else
			operational = 0
			updateicon()
			return 0

	attack_ai(mob/user)
		add_fingerprint(user)
		if(stat & BROKEN) return
		interact(user)

	attack_hand(mob/user)
		add_fingerprint(user)
		if(stat & BROKEN) return
		interact(user)

	proc/interact(mob/user)
		if(get_dist(src, user) > 1)
			if(!istype(user, /mob/ai))
				user.machine = null
				user << browse(null, "window=controlinforelay")
				return

		user.machine = src

		var/t = "<H2>Control Information Relay[n_tag ? " ([n_tag])" : ""]</H2><HR>"
		t += "<PRE>"
		t += "Power usage: [lastusage] W<BR>"
		t += "[operational ? "Enabled <A href='?src=\ref[src];enabled=0'>Disable</A>" : "Disabled <A href='?src=\ref[src];enabled=1'>Enable</A>"]"
		t += "</PRE>"
		user << browse(t, "window=controlinforelay;size=460x300")

	Topic(href, href_list)
		..()

		if (usr.stat || usr.restrained() )
			return
		if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
			if(!istype(usr, /mob/ai))
				usr << "\red You don't have the dexterity to do this!"
				return

		if(href_list["enabled"])
			operational = text2num(href_list["enabled"])
			updateicon()

		interact(usr)