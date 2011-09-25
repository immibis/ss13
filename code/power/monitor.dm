// the power monitoring computer

client/var/tmp
	pm_hide_apc = 0
	pm_hide_smes = 0
	pm_hide_teg = 0
	pm_hide_turbine = 0
	pm_hide_solar = 0
	pm_hide_cir = 0
	pm_hide_rpmu = 0

obj/machinery/power/monitor
	var
		locked = 1

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

	attackby(obj/item/weapon/W, mob/user as mob)
		if(istype(W, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/id = W
			if("access_power_remote" in id.access)
				locked = !locked
				user << "You [locked ? "lock" : "unlock"] the remote control interface."

		if(istype(W, /obj/item/weapon/card/emag))
			if(prob(50))
				locked = !locked
				user << "You [locked ? "lock" : "unlock"] the remote control interface."
			else
				user << "You fail to [locked ? "unlock" : "lock"] the remote control interface."

	proc/interact(mob/user)

		if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
			if (!istype(user, /mob/ai))
				user.machine = null
				user << browse(null, "window=powcomp")
				return


		user.machine = src
		var/t = "<H2>Power Monitoring</H2>"

		t += "<A href='?src=\ref[src];close=1'>Close</A><HR>"


		if(!powernet)
			t += "\red No connection"
		else

			var/list/apcs = list()
			var/list/smeses = list()
			var/list/tegs = list()
			var/list/turbines = list()
			var/list/solars = list()
			var/list/links = list(powernet)
			var/list/links_processed = list()
			var/list/all_nodes = list()
			var/list/cirs = list()
			var/list/rpmus = list()

			while(links.len > 0)
				var/datum/powernet/p = links[1]
				links -= p
				if(p in links_processed)
					continue
				links_processed += p
				for(var/obj/machinery/power/terminal/term in p.nodes)
					if(istype(term.master, /obj/machinery/power/control_info_relay))
						var/obj/machinery/power/control_info_relay/CIR = term.master
						if(CIR.powernet in links || CIR.powernet in links_processed || CIR in all_nodes)
							continue
						if(CIR.accessed())
							links -= CIR.powernet
							links += CIR.powernet
				for(var/obj/machinery/power/control_info_relay/CIR in p.nodes)
					if(!CIR.terminal || CIR.terminal.powernet in links || CIR.terminal.powernet in links_processed || CIR in all_nodes)
						continue
					if(CIR.accessed())
						links -= CIR.terminal.powernet
						links += CIR.terminal.powernet
				all_nodes -= p.nodes
				all_nodes += p.nodes

			for(var/obj/machinery/power/control_info_relay/CIR in all_nodes)
				cirs += CIR
			for(var/obj/machinery/power/generator/G in all_nodes)
				tegs += G
			for(var/obj/machinery/power/turbine/T in all_nodes)
				turbines += T
			for(var/obj/machinery/power/solar_control/S in all_nodes)
				solars += S
			for(var/obj/machinery/power/remote_monitor/rpmu in all_nodes)
				rpmus += rpmu
			for(var/obj/machinery/power/terminal/term in all_nodes)
				if(istype(term.master, /obj/machinery/power/apc))
					apcs += term.master
				else if(istype(term.master, /obj/machinery/power/smes))
					smeses += term.master
				else if(istype(term.master, /obj/machinery/power/control_info_relay))
					cirs += term.master

			t += "<PRE><FONT SIZE=-1>Directly connected power: [num2text(max(0, round(powernet.avail)), 10)] W<BR>Directly connected load:  [num2text(max(0, round(powernet.viewload)),10)] W<BR>"

			if(apcs.len > 0)

				if(user.client.pm_hide_apc)
					t += "<A href='?src=\ref[src];hide_apc=0'>Show APCs (area power controllers)</A><BR>"
				else
					t += "<BR>Area <A href='?src=\ref[src];hide_apc=1'>(hide)</A>                    Breaker Eqp./Lgt./Env.  Load   Cell<BR>"

					var/list/S = list(" Off","AOff","  On", " AOn")
					var/list/chg = list("N","C","F")

					for(var/obj/machinery/power/apc/A in apcs)

						t += copytext(add_tspace(A.area.name, 30), 1, 30)

						if(locked)
							t += " [A.operating ? "On     " : "Off    "]"
							t += " [S[A.equipment+1]]"
							t += " [S[A.lighting+1]]"
							t += " [S[A.environ+1]]"
						else
							t += " [A.operating ? "<A href='?src=\ref[src];apc=\ref[A];breaker=0'>On</A>     " : "<A href='?src=\ref[src];apc=\ref[A];breaker=1'>Off</A>    "]"
							t += " <A href='?src=\ref[src];apc=\ref[A];equipment=[A.equipment ^ 1]'>[(A.equipment & 1) ? "A" : " "]</A><A href='?src=\ref[src];apc=\ref[A];equipment=[A.equipment ^ 2]'>[(A.equipment & 2) ? "On " : "Off"]</A>"
							t += " <A href='?src=\ref[src];apc=\ref[A];lighting=[A.lighting ^ 1]'>[(A.lighting & 1) ? "A" : " "]</A><A href='?src=\ref[src];apc=\ref[A];lighting=[A.lighting ^ 2]'>[(A.lighting & 2) ? "On " : "Off"]</A>"
							t += " <A href='?src=\ref[src];apc=\ref[A];environ=[A.environ ^ 1]'>[(A.environ & 1) ? "A" : " "]</A><A href='?src=\ref[src];apc=\ref[A];environ=[A.environ ^ 2]'>[(A.environ & 2) ? "On " : "Off"]</A>"
						t += " [add_lspace(A.lastused_total, 6)]"
						t += "  [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "  N/C"]<BR>"

			if(smeses.len > 0)
				if(user.client.pm_hide_smes)
					t += "<A href='?src=\ref[src];hide_smes=0'>Show SMESs (superconducting magnetic energy storage units)</A><BR>"
				else
					t += "<BR>Name <A href='?src=\ref[src];hide_smes=1'>(hide)</A>                      Input  Output Charging  Status     Load Charge<BR>"
					//   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx iiiiiii ooooooo ccccccccc sssssss lllllll ccc.c%"
					for(var/obj/machinery/power/smes/S in smeses)
						t += "[copytext(add_tspace((S.n_tag ? "SMES ([S.n_tag])" : "SMES"), 31), 1, 30)]  "
						if(locked)
							t += "[add_lspace(round(S.chargelevel), 7)] "
							t += "[add_lspace(round(S.output), 7)] "
							t += "[S.chargemode ? (S.charging ? "Auto On  " : "Auto Off ") : "Off      "] "
							t += "[S.online ? "Online " : "Offline"] "
						else
							t += "<A href='?src=\ref[src];smes=\ref[S];chargelevel=1'>[add_lspace(round(S.chargelevel), 7)]</A> "
							t += "<A href='?src=\ref[src];smes=\ref[S];output=1'>[add_lspace(round(S.output), 7)]</A> "
							t += "[S.chargemode ? "<A href='?src=\ref[src];smes=\ref[S];chargemode=0'>" + (S.charging ? "Auto On</A>  " : "Auto Off</A> ") : "<A href='?src=\ref[src];smes=\ref[S];chargemode=1'>Off</A>      "] "
							t += "[S.online ? "<A href='?src=\ref[src];smes=\ref[S];online=0'>Online</A> " : "<A href='?src=\ref[src];smes=\ref[S];online=1'>Offline</A>"] "
						t += "[add_lspace(round(S.loaddemand), 7)] "
						t += "[add_lspace(round(S.charge / S.capacity * 100, 0.1), 5)]%<BR>"

			if(tegs.len > 0)
				if(user.client.pm_hide_teg)
					t += "<A href='?src=\ref[src];hide_teg=0'>Show TEGs (thermo-electric generators)</A><BR>"
				else
					t += "<BR>                                                 Hot Loop            Cold Loop<BR>"
					t += "Name <A href='?src=\ref[src];hide_teg=1'>(hide)</A>                        Output  Circ    In     Out    Circ    In     Out<BR>"
					//   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx oooooooooo  ccc% tttttt tttttt    ccc% tttttt tttttt"
					for(var/obj/machinery/power/generator/G in tegs)
						if(!G.circ1 || !G.circ2 || (G.stat & BROKEN))
							t += "[G.n_tag ? "TEG ([G.n_tag])" : "TEG"] (BROKEN)<BR>"
						else if(G.stat & NOPOWER)
							t += "[G.n_tag ? "TEG ([G.n_tag])" : "TEG"] (UNPOWERED)<BR>"
						else
							t += "[copytext(add_tspace((G.n_tag ? "TEG ([G.n_tag])" : "TEG"), 31), 1, 30)]  "
							t += "[add_lspace(round(G.lastgen), 10)]  "
							if(locked)
								t += "[add_lspace(G.c2on ? "[G.c2rate]%" : "Off", 4)] "
							else
								t += "<A href='?src=\ref[src];teg=\ref[G];c2=1'>[add_lspace(G.c2on ? "[G.c2rate]%" : "Off", 4)]</A> "
							t += "[add_lspace(G.circ2.gas1.temperature > 1000 ? round(G.circ2.gas1.temperature) : round(G.circ2.gas1.temperature, 0.1), 6)] "
							t += "[add_lspace(G.circ2.gas2.temperature > 1000 ? round(G.circ2.gas2.temperature) : round(G.circ2.gas2.temperature, 0.1), 6)]    "
							if(locked)
								t += "[add_lspace(G.c1on ? "[G.c1rate]%" : "Off", 4)] "
							else
								t += "<A href='?src=\ref[src];teg=\ref[G];c1=1'>[add_lspace(G.c1on ? "[G.c1rate]%" : "Off", 4)]</A> "
							t += "[add_lspace(G.circ1.gas1.temperature > 1000 ? round(G.circ1.gas1.temperature) : round(G.circ1.gas1.temperature, 0.1), 6)] "
							t += "[add_lspace(G.circ1.gas2.temperature > 1000 ? round(G.circ1.gas2.temperature) : round(G.circ1.gas2.temperature, 0.1), 6)]<BR>"
			if(turbines.len > 0)
				if(user.client.pm_hide_turbine)
					t += "<A href='?src=\ref[src];hide_turbine=0'>Show gas turbines</A><BR>"
				else
					t += "<BR>Name <A href='?src=\ref[src];hide_turbine=1'>(hide)</A>                        Output   Speed Starter<BR>"
					//   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx oooooooooo rrrrrrr sssssss"
					for(var/obj/machinery/power/turbine/T in turbines)
						if(!T.compressor || (T.stat & BROKEN))
							t += "[T.n_tag ? "Turbine ([T.n_tag])" : "Turbine"] (BROKEN)<BR>"
						else if(T.stat & NOPOWER)
							t += "[T.n_tag ? "Turbine ([T.n_tag])" : "Turbine"] (UNPOWERED)<BR>"
						else
							var/gen = T.lastgen - (T.compressor.starter * COMPSTARTERLOAD)
							t += "[copytext(add_tspace((T.n_tag ? "Turbine ([T.n_tag])" : "Turbine"), 31), 1, 30)]  "
							t += "[add_lspace(round(gen), 10)] "
							t += "[add_lspace(round(T.compressor.rpm), 7)] "
							if(locked)
								t += "[T.compressor.starter ? "On     " : "Off    "]<BR>"
							else
								t += "[T.compressor.starter ? "<A href='?src=\ref[src];turbine=\ref[T];starter=0'>On</A>     " : "<A href='?src=\ref[src];turbine=\ref[T];starter=1'>Off</A>    "]<BR>"
			if(solars.len > 0)
				if(user.client.pm_hide_solar)
					t += "<A href='?src=\ref[src];hide_solar=0'>Show solar arrays</A><BR>"
				else
					t += "<BR>Name <A href='?src=\ref[src];hide_solar=1'>(hide)</A>                        Output   Angle  Tracking    Rate Dir<BR>"
					//   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx oooooooooo  aaaaaa  tttttttt  rrrrrr ddd"
					for(var/obj/machinery/power/solar_control/S in solars)
						if(S.stat & BROKEN)
							t += "Solar Array ([S.id]) (CONTROL BROKEN)<BR>"
						else if(S.stat & NOPOWER)
							t += "Solar Array ([S.id]) (CONTROL UNPOWERED)<BR>"
						else
							t += "[copytext(add_tspace("Solar Array ([S.id])", 31), 1, 30)]  "
							t += "[add_lspace(round(S.lastgen), 10)]  "
							if(locked)
								t += "[add_lspace(round(S.cdir, 0.1), 6)]  "
								t += "[S.track ? "On      " : "Off     "]  "
								t += "[add_lspace(round(S.trackrate), 6)] "
							else
								t += "<A href='?src=\ref[src];solar=\ref[S];cdir=1'>[add_lspace(round(S.cdir, 0.1), 6)]</A>  "
								t += "<A href='?src=\ref[src];solar=\ref[S];track=[!S.track]'>[S.track ? "On</A>      " : "Off</A>     "]  "
								t += "<A href='?src=\ref[src];solar=\ref[S];trackrate=1'>[add_lspace(round(S.trackrate), 6)]</A> "
							t += "[S.trackrate < 0 ? "CCW" : " CW"]<BR>"

			if(cirs.len > 0)
				if(user.client.pm_hide_cir)
					t += "<A href='?src=\ref[src];hide_cir=0'>Show CIRs (control information relays)</A><BR>"
				else
					t += "<BR>Name <A href='?src=\ref[src];hide_cir=1'>(hide)</A>                      Usage Enabled<BR>"
					//   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx uuuuuuu        cccc  eeeeeee"
					for(var/obj/machinery/power/control_info_relay/CIR in cirs)
						var/display = CIR.n_tag ? "CIR ([CIR.n_tag])" : "CIR"
						if(CIR.stat & BROKEN)
							t += "[display] (BROKEN)<BR>"
						else if(!CIR.operational)
							if(locked)
								t += "[copytext(add_tspace(display, 31), 1, 31)]            Disabled<BR>"
							else
								t += "[copytext(add_tspace(display, 31), 1, 31)]            <A href='?src=\ref[src];cir=\ref[CIR];enabled=1'>Disabled</A><BR>"
						else
							if(locked)
								t += "[copytext(add_tspace(display, 31), 1, 31)] [add_lspace(CIR.lastusage, 10)] Enabled<BR>"
							else
								t += "[copytext(add_tspace(display, 31), 1, 31)] [add_lspace(CIR.lastusage, 10)] <A href='?src=\ref[src];cir=\ref[CIR];enabled=0'>Enabled</A><BR>"

			if(rpmus.len > 0)
				if(user.client.pm_hide_rpmu)
					t += "<A href='?src=\ref[src];hide_rpmu=0'>Show RPMUs (remote power monitoring units)</A><BR>"
				else
					t += "<BR>Name <A href='?src=\ref[src];hide_rpmu=1'>(hide)</A>                        Supply        Load<BR>"
					//   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ssssssss  llllllll"
					for(var/obj/machinery/power/remote_monitor/rpmu in rpmus)
						var/display = rpmu.n_tag ? "RPMU ([rpmu.n_tag])" : "RPMU"
						if(rpmu.stat & BROKEN)
							t += "[display] (BROKEN)<BR>"
						else
							t += "[copytext(add_tspace(display, 31), 1, 31)] [add_lspace(max(0, round(rpmu.powernet.avail)), 10)]  [add_lspace(max(0, round(rpmu.powernet.viewload)), 10)]<BR>"

			t += "</PRE>"
		user << browse(t, "window=powcomp;size=700x570")

	Topic(href, href_list)
		..()

		if(href_list["close"] || get_dist(src, usr) > 1 || (stat & (NOPOWER|BROKEN)))
			usr << browse(null, "window=powcomp")
			usr.machine = null
			return

		if(href_list["apc"])
			var/obj/machinery/power/apc/A = locate(href_list["apc"])
			if(href_list["equipment"])
				var/n = text2num(href_list["equipment"])
				if((n & 2) != (A.equipment & 2)) // if automatic, and attempting to override, then turn off automatic
					n &= 2
				A.equipment = n
				A.update()
			if(href_list["lighting"])
				var/n = text2num(href_list["lighting"])
				if((n & 2) != (A.lighting & 2)) // if automatic, and attempting to override, then turn off automatic
					n &= 2
				A.lighting = n
				A.update()
			if(href_list["environ"])
				var/n = text2num(href_list["environ"])
				if((n & 2) != (A.environ & 2)) // if automatic, and attempting to override, then turn off automatic
					n &= 2
				A.environ = n
				A.update()
			if(href_list["breaker"])
				var/n = text2num(href_list["breaker"])
				A.operating = n
				A.update()

		if(href_list["smes"])
			var/obj/machinery/power/smes/S = locate(href_list["smes"])
			if(href_list["chargemode"])
				S.chargemode = text2num(href_list["chargemode"])
			if(href_list["online"])
				S.online = text2num(href_list["online"])
			if(href_list["output"])
				usr.machine = null
				S.output = input("Enter new output level (max [S.maxoutput])", S.n_tag ? "SMES ([S.n_tag]) remote control" : "SMES remote control", "[S.output]") as num
				usr.machine = src
				S.output = max(0, min(S.maxoutput, S.output))
			if(href_list["chargelevel"])
				usr.machine = null
				S.chargelevel = input("Enter new input level (max [S.maxchargelevel])", S.n_tag ? "SMES ([S.n_tag]) remote control" : "SMES remote control", "[S.chargelevel]") as num
				usr.machine = src
				S.chargelevel = max(0, min(S.maxchargelevel, S.chargelevel))

		if(href_list["teg"])
			var/obj/machinery/power/generator/G = locate(href_list["teg"])
			if(href_list["c1"])
				usr.machine = null
				var/rate = input("Enter new cold-loop circulator rate (0..100)", G.n_tag ? "TEG ([G.n_tag]) remote control" : "TEG remote control", "[G.c1on ? G.c1rate : 0]") as num
				usr.machine = src
				if(rate == 0)
					G.c1on = 0
				else
					G.c1rate = max(1, min(100, rate))
					G.c1on = 1
				G.circ1.control(G.c1on, G.c1rate)
				G.updateicon()
			if(href_list["c2"])
				usr.machine = null
				var/rate = input("Enter new hot-loop circulator rate (0..100)", G.n_tag ? "TEG ([G.n_tag]) remote control" : "TEG remote control", "[G.c2on ? G.c2rate : 0]") as num
				usr.machine = src
				if(rate == 0)
					G.c2on = 0
				else
					G.c2rate = max(1, min(100, rate))
					G.c2on = 1
				G.circ2.control(G.c2on, G.c2rate)
				G.updateicon()

		if(href_list["turbine"])
			var/obj/machinery/power/turbine/T = locate(href_list["turbine"])
			if(href_list["starter"])
				T.compressor.starter = text2num(href_list["starter"])

		if(href_list["solar"])
			var/obj/machinery/power/solar_control/S = locate(href_list["solar"])
			if(href_list["track"])
				S.track = text2num(href_list["track"])
			if(href_list["trackrate"])
				usr.machine = null
				S.trackrate = input("Enter new tracking rate in degrees per hour", "Solar Array ([S.id]) remote control", "[S.trackrate]") as num
				usr.machine = src
				S.trackrate = min(7200, max(-7200, S.trackrate))
				if(S.trackrate) S.nexttime = world.timeofday + 3600/abs(S.trackrate)
			if(href_list["cdir"])
				usr.machine = null
				S.cdir = input("Enter new orientation in degrees", "Solar Array ([S.id]) remote control", "[S.cdir]") as num
				usr.machine = src
				S.cdir = min(359, max(0, S.cdir))
				S.set_panels(S.cdir)
				S.updateicon()

		if(href_list["cir"])
			var/obj/machinery/power/control_info_relay/CIR = locate(href_list["cir"])
			if(href_list["enabled"])
				CIR.operational = text2num(href_list["enabled"])
				CIR.updateicon()

		if(href_list["hide_apc"]) usr.client.pm_hide_apc = text2num(href_list["hide_apc"])
		if(href_list["hide_smes"]) usr.client.pm_hide_smes = text2num(href_list["hide_smes"])
		if(href_list["hide_teg"]) usr.client.pm_hide_teg = text2num(href_list["hide_teg"])
		if(href_list["hide_turbine"]) usr.client.pm_hide_turbine = text2num(href_list["hide_turbine"])
		if(href_list["hide_solar"]) usr.client.pm_hide_solar = text2num(href_list["hide_solar"])
		if(href_list["hide_cir"]) usr.client.pm_hide_cir = text2num(href_list["hide_cir"])
		if(href_list["hide_rpmu"]) usr.client.pm_hide_rpmu = text2num(href_list["hide_rpmu"])

		interact(usr)

	process()
		if(!(stat & (NOPOWER|BROKEN)) )
			use_power(POWER_MONITOR_POWER)

		src.updateDialog()


	power_change()

		if(stat & BROKEN)
			icon_state = "broken"
		else
			if( powered() )
				icon_state = initial(icon_state)
				stat &= ~NOPOWER
			else
				spawn(rand(0, 15))
					src.icon_state = "c_unpowered"
					stat |= NOPOWER


