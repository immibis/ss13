/mob/ai/proc/ai_alerts()
	set category = "AI Commands"
	set name = "Show Alerts"

	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[src];mach_close=aialerts'>Close</A><BR><BR>"
	for (var/cat in src.alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = src.alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/C = alm[2]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				if (C && istype(C, /list))
					var/dat2 = ""
					for (var/obj/machinery/camera/I in C)
						dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (dat2=="") ? "" : " | ", src, I, I.c_tag)
					dat += text("-- [] ([])", A.name, (dat2!="") ? dat2 : "No Camera")
				else if (C && istype(C, /obj/machinery/camera))
					var/obj/machinery/camera/Ctmp = C
					dat += text("-- [] (<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>)", A.name, src, C, Ctmp.c_tag)
				else
					dat += text("-- [] (No Camera)", A.name)
				if (sources.len > 1)
					dat += text("- [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	src.viewalerts = 1
	src << browse(dat, "window=aialerts&can_close=0")

/mob/ai/proc/ai_cancel_call()
	set category = "AI Commands"
	if(usr.stat == 2)
		usr << "You can't send the shuttle back because you are dead!"
		return
	cancel_call_proc(src)
	return

/mob/ai/check_eye(var/mob/user as mob)
	if (!src.current)
		return null
	user.reset_view(src.current)
	return 1

/mob/ai/blob_act()
	if (src.stat != 2)
		src.bruteloss += 30
		src.updatehealth()
		return 1
	return 0

/mob/ai/Stat()
	..()
	statpanel("Status")
	if (src.client.statpanel == "Status")
		if(ticker)
			var/timel = ticker.timeleft
			stat(null, text("ETA-[]:[][]", timel / 600 % 60, timel / 100 % 6, timel / 10 % 10))
		if(ticker.mode.name == "Corporate Restructuring" && ticker.target)
			var/icon = ticker.target.name
			var/icon2 = ticker.target.rname
			var/area = get_area(ticker.target)
			stat(null, text("Target: [icon2] (as [icon]) is in [area]"))

	return

/mob/ai/restrained()
	return 0

/mob/ai/ex_act(severity)
	flick("flash", src.flash)

	var/b_loss = src.bruteloss
	var/f_loss = src.fireloss
	switch(severity)
		if(1.0)
			if (src.stat != 2)
				b_loss += 100
				f_loss += 100
		if(2.0)
			if (src.stat != 2)
				b_loss += 60
				f_loss += 60
		if(3.0)
			if (src.stat != 2)
				b_loss += 30
	src.bruteloss = b_loss
	src.fireloss = f_loss
	src.updatehealth()

/mob/ai/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		if (href_list["mach_close"] == "aialerts")
			src.viewalerts = 0
		var/t1 = text("window=[]", href_list["mach_close"])
		src.machine = null
		src << browse(null, t1)
	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]))
	if (href_list["showalerts"])
		ai_alerts()
	return

/mob/ai/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (src.health > 0)
		src.bruteloss += 30
		if ((O.icon_state == "flaming"))
			src.fireloss += 40
		src.updatehealth()
	return

/mob/ai/las_act(flag)
	if (flag == "bullet")
		if (src.stat != 2)
			src.bruteloss += 60
			src.updatehealth()
			src.weakened = 10
	if (flag)
		if (prob(75))
			src.stunned = 15
		else
			src.weakened = 15
	else
		if (src.stat != 2)
			src.bruteloss += 20
			src.updatehealth()
			if (prob(25))
				src.stunned = 1
	return
/mob/ai/proc/getLaw(var/index)
	if (src.laws.len < index+1)
		src << text("Error: Invalid law index [] for getLaw. Writing out list of laws for debug purposes.", index)
		showLaws(0)
	else
		return src.laws[index+1]


/mob/ai/proc/show_laws()
	set category = "AI Commands"
	set name = "Show Laws"
	src.showLaws(0)

/mob/ai/proc/showLaws(var/toAll=0)
	var/showTo = src
	if (toAll)
		showTo = world
	else
		src << "<b>Obey these laws:</b>"
	var/lawIndex = 0
	for (var/index=1, index<=src.laws.len, index++)
		var/law = src.laws[index]
		if (length(law)>0)
			if (index==2 && lawIndex==0)
				lawIndex = 1
			showTo << text("[]. []", lawIndex, law)
			lawIndex += 1

/mob/ai/proc/addLaw(var/number, var/law)
	while (src.laws.len < number+1)
		src.laws += ""
	src.laws[number+1] = law

/mob/ai/proc/firecheck(turf/T as turf)

	if (T.firelevel < 900000.0)
		return 0
	var/total = 0
	total += 0.25
	return total

/mob/ai/proc/switchCamera(var/obj/machinery/camera/C)
	usr:cameraFollow = null
	if (!C)
		src.machine = null
		src.reset_view(null)
		return 0
	if (stat == 2 || !C.status || C.network != src.network) return 0

	// ok, we're alive, camera is good and in our network...

	src.machine = src
	src:current = C
	src.reset_view(C)
	return 1

/mob/ai/proc/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if (stat == 2)
		return 1
	var/list/L = src.alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	if (O)
		if (C && C.status)
			src << text("--- [] alarm detected in []! (<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>)", class, A.name, src, C, C.c_tag)
		else if (CL && CL.len)
			var/foo = 0
			var/dat2 = ""
			for (var/obj/machinery/camera/I in CL)
				dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (!foo) ? "" : " | ", src, I, I.c_tag)
				foo = 1
			src << text ("--- [] alarm detected in []! ([])", class, A.name, dat2)
		else
			src << text("--- [] alarm detected in []! (No Camera)", class, A.name)
	else
		src << text("--- [] alarm detected in []! (No Camera)", class, A.name)
	if (src.viewalerts) src.ai_alerts()
	return 1

/mob/ai/proc/cancelAlarm(var/class, area/A as area, obj/origin)
	var/list/L = src.alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	if (cleared)
		src << text("--- [] alarm in [] has been cleared.", class, A.name)
		if (src.viewalerts) src.ai_alerts()
	return !cleared

/mob/ai/cancel_camera()
	set category = "AI Commands"
	set name = "Cancel Camera View"
	src.reset_view(null)
	src.machine = null
	src:cameraFollow = null

/mob/ai/verb/change_network()
	set category = "AI Commands"
	set name = "Change Camera Network"
	src.reset_view(null)
	src.machine = null
	src:cameraFollow = null
	if(src.network == "SS13")
		src.network = "Prison"
	else
		src.network = "SS13"
	src << "\blue Switched to [src.network] camera network."