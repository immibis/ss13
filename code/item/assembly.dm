datum/trigger_cb
	proc/trigger()
		CRASH("trigger() not implemented in [type]")

obj/item/trigger
	var/obj/item/assembly/attached
	var/icon_state_id
	var/state_suffix = 0

	w_class = 2
	s_istate = "electronic"
	icon = 'icons/goonstation/obj/assemblies.dmi'

	proc/trigger()
		var/obj/item/O = attached ? attached : src
		for(var/mob/M in hearers(1, O))
			M.show_message("\icon[O] *beep*", 1, "*beep*", 2)
		if(attached)
			attached.trigger()

	// do any processing here, it should spawn itself or loop forever unless it does nothing
	proc/check()

	proc/c_state(s)
		state_suffix = s
		icon_state = "[icon_state_id][s]"
		if(!(icon_state in icon_states(icon)))
			icon_state = "[icon_state_id]0"
		if(attached)
			attached.updateicon()

	New()
		. = ..()
		check()

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/igniter))
			var/obj/item/assembly/bomb/B = new
			B.TR = src
			loc = B
			user.unequip(src)
			B.attackby(I, user)
		else
			. = ..()

	radio
		icon_state_id = "radio"
		icon_state = "radio0"
		name = "signaller"

		proc/r_signal()
			trigger()

	proximity
		icon_state_id = "prox"
		icon_state = "prox0"
		name = "proximity sensor"
		desc = "Triggers a device when an object passes nearby."

		var/state = 0
		var/time = 0
		var/timing = 0
		check()
			var/obj/item/O = attached ? attached : src
			for(var/atom/movable/A in view(O, 1))
				if(A != src && A != O)
					trigger()
					break
			spawn(10) check()

		check()
			if (src.timing)
				if (src.time > 0)
					if(!src.state)
						src.c_state(2)
					src.time = round(src.time) - 1
				else
					time()
					src.time = 0
					src.timing = 0
				var/obj/item/O = attached ? attached : src

				if (istype(O.loc, /mob))
					attack_self(O.loc)
				else
					for(var/mob/M in viewers(1, O))
						if (M.client && (M.machine == O || M.machine == src))
							src.attack_self(M)
			spawn(10)
				check()

		proc/time()
			if(state == 0)
				state = !state
				c_state(state)

		HasProximity(atom/movable/AM as mob|obj)
			if(istype(AM, /obj/beam))
				return
			if(AM.move_speed < 12)
				trigger()

		attack_self(mob/user as mob)
			if (user.stat || user.restrained() || user.lying)
				return
			if ((user.contents.Find(src) || user.contents.Find(src.master) || get_dist(src, user) <= 1 && istype(src.loc, /turf)))
				user.machine = src
				var/second = src.time % 60
				var/minute = (src.time - second) / 60
				var/dat = text("<TT><B>Proximity Sensor</B>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (src.timing ? text("<A href='?src=\ref[];time=0'>Arming</A>", src) : text("<A href='?src=\ref[];time=1'>Not Arming</A>", src)), minute, second, src, src, src, src)
				dat += "<BR><A href='?src=\ref[src];state=1'>[state?"Armed":"Unarmed"]</A> (Movement sensor active when armed!)"
				dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
				user << browse(dat, "window=prox")
			else
				user << browse(null, "window=prox")
				user.machine = null

		Topic(href, href_list)
			..()
			if (usr.stat || usr.restrained() || usr.lying)
				return
			if ((usr.contents.Find(src) || usr.contents.Find(src.master) || get_dist(src, usr) <= 1 && istype(src.loc, /turf)))
				usr.machine = src
				if (href_list["state"])
					state = !state
					c_state(state)

				if (href_list["time"])
					src.timing = text2num(href_list["time"])
					if(timing)
						src.c_state(1)

				if (href_list["tp"])
					var/tp = text2num(href_list["tp"])
					src.time += tp
					src.time = min(max(round(src.time), 0), 600)

				if (href_list["close"])
					usr << browse(null, "window=prox")
					usr.machine = null
					return

				var/obj/item/O = attached ? attached : src

				if (istype(O.loc, /mob))
					attack_self(O.loc)
				else
					for(var/mob/M in viewers(1, O))
						if (M.client && (M.machine == O || M.machine == src))
							src.attack_self(M)
			else
				usr << browse(null, "window=prox")

		Move()
			. = ..()
			if(. && state)
				trigger()

	// TODO: Infrared scanners that make the beams visible

	infra
		icon_state_id = "infra"
		icon_state = "infra0"

		name = "infrared beam"
		desc = "Emits a visible or invisible beam and triggers when the beam is interrupted."
		var/obj/beam/i_beam/first = null
		var/state = 0.0
		var/visible = 0.0

		proc/hit()
			if (src.master)
				spawn( 0 )
					src.master:r_signal(1, src)
					return
			else
				for(var/mob/O in hearers(null, null))
					O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
			return

		check()
			var/obj/item/O = attached ? attached : src
			if(!src.first && src.state && isturf(O.loc))
				var/obj/beam/i_beam/I = new(O.loc)
				I.master = src
				I.density = 1
				I.dir = src.dir
				step(I, I.dir)
				if (I)
					I.density = 0
					src.first = I
					I.vis_spread(src.visible)
					spawn( 0 )
						if (I)
							I.limit = 20
							I.process()
						return
			if(!state)
				del(src.first)
			spawn(5)
				src.check()

		attack_self(mob/user as mob)
			user.machine = src
			var/dat = text("<TT><B>Infrared Laser</B>\n<B>Status</B>: []<BR>\n<B>Visibility</B>: []<BR>\n</TT>", (src.state ? text("<A href='?src=\ref[];state=0'>On</A>", src) : text("<A href='?src=\ref[];state=1'>Off</A>", src)), (src.visible ? text("<A href='?src=\ref[];visible=0'>Visible</A>", src) : text("<A href='?src=\ref[];visible=1'>Invisible</A>", src)))
			user << browse(dat, "window=infra")

		Topic(href, href_list)
			..()
			if (usr.stat || usr.restrained())
				return
			if ((usr.contents.Find(src) || usr.contents.Find(src.master) || get_dist(src, usr) <= 1 && istype(src.loc, /turf)))
				usr.machine = src
				if (href_list["state"])
					src.state = !src.state
					src.icon_state = text("infrared[]", src.state)
					if (src.master)
						src.master:c_state(src.state, src)
				if (href_list["visible"])
					src.visible = !( src.visible )
					spawn(0)
						if (src.first)
							src.first.vis_spread(src.visible)
				var/obj/item/O = attached ? attached : src
				if (istype(O.loc, /mob))
					attack_self(O.loc)
				else
					for(var/mob/M in viewers(1, O))
						if (M.machine == O)
							src.attack_self(M)
			else
				usr << browse(null, "window=infra")

		attack_hand()
			//src.first = null
			del(src.first)
			..()
			return

		Move()
			var/t = src.dir
			. = ..()
			src.dir = t
			//src.first = null
			del(src.first)

		verb/rotate()
			set src in usr

			src.dir = turn(src.dir, 90)

	timer
		icon_state_id = "timer"
		icon_state = "timer0"
		name = "timer"

		var/timing = 0
		var/time = null

		check()
			if(src.timing)
				if(src.time > 0)
					src.time = round(src.time) - 1
					if(time<5)
						c_state(2)
					else
						// they might increase the time while it is timing
						c_state(1)
				else
					trigger()
					src.time = 0
					src.timing = 0
				var/obj/item/O = attached ? attached : src
				if(istype(O.loc, /mob))
					attack_self(O.loc)
				else
					for(var/mob/M in viewers(1, O))
						if (M.client && (M.machine == O || M.machine == src))
							O.attack_self(M)
			else
				c_state(0)
			spawn(10)
				check()

		attack_self(mob/user as mob)
			..()
			if (user.stat || user.restrained() || user.lying)
				return
			if ((user.contents.Find(src) || user.contents.Find(src.master) || get_dist(src, user) <= 1 && istype(src.loc, /turf)))
				user.machine = src
				var/second = src.time % 60
				var/minute = (src.time - second) / 60
				var/dat = text("<TT><B>Timing Unit</B>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (src.timing ? text("<A href='?src=\ref[];time=0'>Timing</A>", src) : text("<A href='?src=\ref[];time=1'>Not Timing</A>", src)), minute, second, src, src, src, src)
				dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
				user << browse(dat, "window=timer")
			else
				user << browse(null, "window=timer")
				user.machine = null

		Topic(href, href_list)
			..()
			if (usr.stat || usr.restrained() || usr.lying)
				return
			if ((usr.contents.Find(src) || usr.contents.Find(src.master) || get_dist(src, usr) <= 1 && istype(src.loc, /turf)))
				usr.machine = src
				if (href_list["time"])
					src.timing = text2num(href_list["time"])
					if(timing)
						src.c_state(1)

				if (href_list["tp"])
					var/tp = text2num(href_list["tp"])
					src.time += tp
					src.time = min(max(round(src.time), 0), 600)

				if (href_list["close"])
					usr << browse(null, "window=timer")
					usr.machine = null
					return

				var/obj/item/O = attached ? attached : src

				if (istype(O.loc, /mob))
					attack_self(O.loc)
				else
					for(var/mob/M in viewers(1, O))
						if (M.client && (M.machine == O || M.machine == src))
							src.attack_self(M)
				src.add_fingerprint(usr)
			else
				usr << browse(null, "window=timer")

obj/item/assembly
	proc/trigger()
	proc/updateicon()

	icon = 'icons/goonstation/obj/assemblies.dmi'
	icon_state = ""

	bomb
		var/obj/item/trigger/TR
		var/obj/item/igniter/I
		var/obj/item/tank/plasma/PT

		Del()
			if(TR)
				TR.loc = loc
				TR.attached = null
			if(I) I.loc = loc
			if(PT) PT.loc = loc
			. = ..()

		attackby(obj/item/I, mob/user)
			if(istype(I, /obj/item/trigger))
				if(TR)
					if(user)
						user << "\blue You remove \the [TR]."
					TR.loc = loc
					TR.attached = null
				if(user)
					user << "\blue You attach \the [I]."
				var/obj/item/trigger/T = I
				T.attached = src
				T.loc = src
				TR = T
				if(istype(I, /obj/item/trigger/radio))
					world << "\blue <B> (OOC) Radio bombs don't work yet! Swear at Immibis and submit a bug report."
			else if(istype(I, /obj/item/igniter))
				if(src.I)
					if(user)
						user << "\blue You remove \the [src.I]"
					src.I.loc = loc
				if(user)
					user << "\blue You attach \the [I]"
				I.loc = src
				src.I = I
			else if(istype(I, /obj/item/tank/plasma))
				if(PT)
					if(user)
						user << "\blue You remove \the [PT]"
					PT.loc = loc
				if(user)
					user << "\blue You attach \the [I]"
				I.loc = src
				PT = I
			else if(user)
				. = ..()


		attack_self(mob/user)
			if(TR)
				TR.attack_self(user)
			else
				. = ..()

		updateicon()
			// invalid combinations
			if((!TR && !I && !PT) || (TR && !I && PT) || (!TR && I && PT))
				icon = 'icons/goonstation/obj/assemblies.dmi'
				icon_state = ""
				return

			// only one part
			if(TR && !I && !PT)
				icon = TR.icon
				icon_state = TR.icon_state
				return
			if(!TR && I && !PT)
				icon = I.icon
				icon_state = I.icon_state
				return
			if(!TR && !I && PT)
				icon = PT.icon
				icon_state = PT.icon_state
				return

			// multiple parts
			var/parts = list()
			if(TR) parts += TR.icon_state_id
			if(I) parts += "igniter"
			if(PT) parts += "tank"

			var/is = ""
			for(var/p in parts)
				is += (is ? "-" : "") + p

			icon = 'icons/goonstation/obj/assemblies.dmi'
			icon_state = "[is][TR ? TR.state_suffix :""]"
