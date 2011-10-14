var/list/airtunnels = new

turf/simulated/airtunnel
	var/a_type

	icon = 'icons/immibis/airtunnel.dmi'

	floor
		a_type = /turf/simulated/airtunnel/floor
		density = 0
		opacity = 0
		icon_state = "floor"

	wall
		a_type = /turf/simulated/airtunnel/wall
		density = 1
		opacity = 1
		icon_state = "wall"

	connector
		var/at_id = null
		floor
			a_type = /turf/simulated/airtunnel/floor
			density = 0
			opacity = 0
			icon_state = "floor-c"
		wall
			a_type = /turf/simulated/airtunnel/wall
			density = 1
			opacity = 1
			icon_state = "wall-c"
		New()
			. = ..()
			if(!at_id)
				return
			var/datum/airtunnel/at
			if(!(at_id in airtunnels))
				at = new
				airtunnels[at_id] = at
			else
				at = airtunnels[at_id]
			at.start += src
			at.end += src

	var/turf/simulated/airtunnel
		next
		previous

	proc/extend()
		var/turf/T = get_step(src, dir)
		if(!istype(T, /turf/space))
			return
		if(next)
			return
		next = new a_type(T)
		next.dir = dir
		next.previous = src
		buildlinks()

	proc/retract()
		if(!previous)
			return
		previous.next = null
		previous = null
		var/turf/space/S = new /turf/space(src)
		S.buildlinks()

datum/airtunnel
	var/const
		RETRACTED = 0
		EXTENDED = 1
		MIDWAY = 2
		RETRACTING = 3
		EXTENDING = 4

	var/state = RETRACTED

	var/list/start = new
	var/list/end = new

	proc/extend()
		if(state != EXTENDED)
			state = EXTENDING

	proc/retract()
		if(state != RETRACTED)
			state = RETRACTING

	proc/stop()
		if(state == RETRACTING || state == EXTENDING)
			state = MIDWAY

	proc/process()
		if(state == RETRACTING)
			for(var/turf/simulated/airtunnel/T in end)
				if(T.previous)
					end -= T
					end += T.previous
					T.retract()
				else
					state = RETRACTED
		else if(state == EXTENDING)
			for(var/turf/simulated/airtunnel/T in end)
				T.extend()
				if(T.next)
					end -= T
					end += T.next
				else
					state = EXTENDED


obj/machinery/computer/airtunnel
	name = "Air Tunnel Control"

	var/datum/airtunnel/tunnel = null

	var/at_id = null

	New()
		. = ..()
		spawn(10)
			tunnel = airtunnels[at_id]
			if(!tunnel)
				world.log << "No such airtunnel: [at_id]"
				stat |= BROKEN
				updateicon()

	attack_ai(mob/user)
		add_fingerprint(user)

		if(stat & (BROKEN|NOPOWER))
			return
		interact(user)

	attack_hand(mob/user)
		add_fingerprint(user)

		if(stat & (BROKEN|NOPOWER))
			return
		interact(user)

	proc/interact(mob/user)
		if(stat & (BROKEN|NOPOWER))
			return

		var/dat = "<PRE>Air tunnel controls<BR>"
		user.machine = src
		switch(tunnel.state)
			if(tunnel.RETRACTED) dat += "<B>Status:</B> Fully retracted<BR>"
			if(tunnel.EXTENDED) dat += "<B>Status:</B> Fully extended<BR>"
			if(tunnel.MIDWAY) dat += "<B>Status:</B> Stopped midway<BR>"
			if(tunnel.RETRACTING) dat += "<B>Status:</B> Retracting<BR>"
			if(tunnel.EXTENDING) dat += "<B>Status:</B> Extending<BR>"
		if(tunnel.state != tunnel.RETRACTED && tunnel.state != tunnel.RETRACTING)
			dat += "<A href='?src=\ref[src];retract=1'>Retract</A> "
		else
			dat += "Retract "
		if(tunnel.state == tunnel.RETRACTING || tunnel.state == tunnel.EXTENDING)
			dat += "<A href='?src=\ref[src];stop=1'>Stop</A> "
		else
			dat += "Stop "
		if(tunnel.state != tunnel.EXTENDED && tunnel.state != tunnel.EXTENDING)
			dat += "<A href='?src=\ref[src];extend=1'>Extend</A> "
		else
			dat += "Extend "
		dat += "<BR><BR><A href='?src=\ref[user];mach_close=computer'>Close</A></TT></BODY></HTML>"
		user << browse(dat, "window=computer;size=400x500")

	Topic(href, href_list[])
		if(href_list["retract"])
			tunnel.retract()
		else if(href_list["extend"])
			tunnel.extend()
		else if(href_list["stop"])
			tunnel.stop()
		else
			. = ..()
		updateicon()

	updateicon()
		if(!tunnel)
			display = "0"
			return ..()
		switch(tunnel.state)
			if(tunnel.RETRACTED) display = "0"
			if(tunnel.EXTENDED) display = "1"
			if(tunnel.MIDWAY) display = "2"
			if(tunnel.RETRACTING) display = "r"
			if(tunnel.EXTENDING) display = "e"
		. = ..()
