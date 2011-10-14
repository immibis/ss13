/obj/machinery/computer/security/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/security/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/security/check_eye(var/mob/user as mob)
	if ((get_dist(user, src) > 1 || !( user.canmove ) || user.blinded || !( src.current ) || !( src.current.status )) && (!istype(user, /mob/ai)))
		return null
	user.reset_view(src.current)
	return 1

/obj/machinery/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN))
		return 1
	if(usr.restrained() || usr.lying || usr.stat)
		return 1
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		if (!istype(usr, /mob/ai))
			usr << "\red You don't have the dexterity to do this!"
			return 1
	if ((get_dist(src, usr) > 1 || !istype(src.loc, /turf)) && !istype(usr, /mob/ai))
		return 1
	src.add_fingerprint(usr)
	return 0

/obj/machinery/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return 1
	if(user.lying || user.stat)
		return 1
	if (!(istype(usr, /mob/human) || ticker) && ticker.mode.name != "monkey")
		if (!istype(user, /mob/ai))
			usr << "\red You don't have the dexterity to do this!"
			return 1
	if ((get_dist(src, user) > 1 || !istype(src.loc, /turf)) && !istype(user, /mob/ai))
		return 1
	src.add_fingerprint(user)
	return 0

/obj/machinery/computer/communications/process()
	..()
	src.updateDialog()

/obj/machinery/computer/communications/Topic(href, href_list)
	if(..())
		return
	usr.machine = src

	if(!href_list["operation"])
		return
	switch(href_list["operation"])
		// main interface
		if("main")
			src.state = STATE_DEFAULT
		if("login")
			var/mob/human/M = usr
			var/obj/item/weapon/card/id/I = M.equipped()
			if(I && istype(I) && src.check_access(I))
				authenticated = I
			else if(istype(M))
				I = M.wear_id
				if(I && istype(I) && src.check_access(I))
					authenticated = I
		if("logout")
			authenticated = null
		if("callshuttle")
			src.state = STATE_DEFAULT
			if(src.authenticated)
				src.state = STATE_CALLSHUTTLE
		if("callshuttle2")
			if(src.authenticated)
				send_packet("#commdish", SignPacket("emshuttle", "call"))
			src.state = STATE_DEFAULT
		if("cancelshuttle")
			src.state = STATE_DEFAULT
			if(src.authenticated)
				src.state = STATE_CANCELSHUTTLE
		if("cancelshuttle2")
			if(src.authenticated)
				send_packet("#commdish", SignPacket("emshuttle", "recall"))
			src.state = STATE_DEFAULT
		if("messagelist")
			src.currmsg = 0
			src.state = STATE_MESSAGELIST
		if("viewmessage")
			src.state = STATE_VIEWMESSAGE
			if (!src.currmsg)
				if(href_list["message-num"])
					src.currmsg = text2num(href_list["message-num"])
				else
					src.state = STATE_MESSAGELIST
		if("delmessage")
			src.state = (src.currmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("delmessage2")
			if(src.authenticated)
				if(src.currmsg)
					var/title = src.messagetitle[src.currmsg]
					var/text  = src.messagetext[src.currmsg]
					src.messagetitle.Remove(title)
					src.messagetext.Remove(text)
					if(src.currmsg == src.aicurrmsg)
						src.aicurrmsg = 0
					src.currmsg = 0
				src.state = STATE_MESSAGELIST
			else
				src.state = STATE_VIEWMESSAGE
		// AI interface
		if("ai-main")
			src.aicurrmsg = 0
			src.aistate = STATE_DEFAULT
		if("ai-callshuttle")
			src.aistate = STATE_CALLSHUTTLE
		if("ai-callshuttle2")
			call_shuttle_proc(usr)
			src.aistate = STATE_DEFAULT
		if("ai-messagelist")
			src.aicurrmsg = 0
			src.aistate = STATE_MESSAGELIST
		if("ai-viewmessage")
			src.aistate = STATE_VIEWMESSAGE
			if (!src.aicurrmsg)
				if(href_list["message-num"])
					src.aicurrmsg = text2num(href_list["message-num"])
				else
					src.aistate = STATE_MESSAGELIST
		if("ai-delmessage")
			src.aistate = (src.aicurrmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("ai-delmessage2")
			if(src.aicurrmsg)
				var/title = src.messagetitle[src.aicurrmsg]
				var/text  = src.messagetext[src.aicurrmsg]
				src.messagetitle.Remove(title)
				src.messagetext.Remove(text)
				if(src.currmsg == src.aicurrmsg)
					src.currmsg = 0
				src.aicurrmsg = 0
			src.aistate = STATE_MESSAGELIST
	src.updateUsrDialog()

/obj/machinery/computer/communications/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.machine = src
	var/dat = "<head><title>Communications Console</title></head><body>"
	if (ticker.timing == 1)
		dat += "<B>Emergency shuttle</B>\n<BR>\nETA: [(!ticker.timeleft) ? "10:00" : "[ticker.timeleft / 600 % 60]:[ticker.timeleft / 100 % 6][ticker.timeleft / 10 % 10]"]<BR>"

	if (istype(user, /mob/ai))
		var/dat2 = src.interact_ai(user) // give the AI a different interact proc to limit its access
		if(dat2)
			dat += dat2
			user << browse(dat, "window=communications;size=400x500")
		return

	if(!authenticated)
		state = STATE_DEFAULT

	switch(src.state)
		if(STATE_DEFAULT)
			if (src.authenticated)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=logout'>Log Out</A> \]"
				if (ticker.timing == 1)
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=cancelshuttle'>Cancel Shuttle Call</A> \]"
				else
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=callshuttle'>Call Emergency Shuttle</A> \]"
			else
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=login'>Log In</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=messagelist'>Message List</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += "Are you sure you want to call the shuttle? \[ <A HREF='?src=\ref[src];operation=callshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=main'>Cancel</A> \]"
		if(STATE_CANCELSHUTTLE)
			dat += "Are you sure you want to cancel the shuttle? \[ <A HREF='?src=\ref[src];operation=cancelshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=main'>Cancel</A> \]"
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=src.messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=viewmessage;message-num=[i]'>[src.messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (src.currmsg)
				dat += "<B>[src.messagetitle[src.currmsg]]</B><BR><BR>[src.messagetext[src.currmsg]]"
				if (src.authenticated)
					dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=delmessage'>Delete \]"
			else
				src.state = STATE_MESSAGELIST
				src.attack_hand(user)
				return
		if(STATE_DELMESSAGE)
			if (src.currmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
			else
				src.state = STATE_MESSAGELIST
				src.attack_hand(user)
				return

	dat += "<BR>\[ [(src.state != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	user << browse(dat, "window=communications;size=400x500")

/obj/machinery/computer/communications/proc/interact_ai(var/mob/ai/user as mob)
	var/dat = ""
	switch(src.aistate)
		if(STATE_DEFAULT)
			if (ticker.timing != 1)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-callshuttle'>Call Emergency Shuttle</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-messagelist'>Message List</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += "Are you sure you want to call the shuttle? \[ <A HREF='?src=\ref[src];operation=ai-callshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=ai-main'>Cancel</A> \]"
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=src.messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=ai-viewmessage;message-num=[i]'>[src.messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (src.aicurrmsg)
				dat += "<B>[src.messagetitle[src.aicurrmsg]]</B><BR><BR>[src.messagetext[src.aicurrmsg]]"
				dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=ai-delmessage'>Delete</A> \]"
			else
				src.aistate = STATE_MESSAGELIST
				src.attack_hand(user)
				return null
		if(STATE_DELMESSAGE)
			if(src.aicurrmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=ai-delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"
			else
				src.aistate = STATE_MESSAGELIST
				src.attack_hand(user)
				return

	dat += "<BR>\[ [(src.aistate != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=ai-main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	return dat

/proc/call_shuttle_proc()
	if ((!( ticker ) || ticker.shuttle_location == 1))
		return

	if (!( ticker.timeleft ))
		ticker.timeleft = shuttle_time_to_arrive
	world << "\blue <B>Alert: The emergency shuttle has been called. It will arrive in [ticker.timeleft/600] minutes.</B>"
	ticker.timing = 1

/proc/cancel_call_proc()
	if ((!( ticker ) || ticker.shuttle_location == 1 || ticker.timing == 0 || ticker.timeleft < 300))
		return
	if( ticker.mode.name == "blob" )
		return

	world << "\blue <B>Alert: The shuttle is going back!</B>"
	ticker.timing = -1

/obj/machinery/computer/card/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.machine = src
	var/dat
	if (!( ticker ))
		return
	if (src.mode) // accessing crew manifest
		var/crew = ""
		for(var/datum/data/record/t in data_core.general)
			crew += "[t.fields["name"]] - [t.fields["rank"]]<br>"
		dat = "<tt><b>Crew Manifest:</b><br>Please use security record computer to modify entries.<br>[crew]<a href='?src=\ref[src];print=1'>Print</a><br><br><a href='?src=\ref[src];mode=0'>Access ID modification console.</a><br></tt>"
	else
		var/header = "<b>Identification Card Modifier</b><br><i>Please insert the cards into the slots</i><br>"

		var/target_name
		var/target_owner
		var/target_rank
		if(src.modify)
			target_name = src.modify.name
		else
			target_name = "--------"
		if(src.modify && src.modify.registered)
			target_owner = src.modify.registered
		else
			target_owner = "--------"
		if(src.modify && src.modify.assignment)
			target_rank = src.modify.assignment
		else
			target_rank = "Unassigned"
		header += "Target: <a href='?src=\ref[src];modify=1'>[target_name]</a><br>"

		var/scan_name
		if(src.scan)
			scan_name = src.scan.name
		else
			scan_name = "--------"
		header += "Confirm Identity: <a href='?src=\ref[src];scan=1'>[scan_name]</a><br>"
		header += "<hr>"
		var/body
		if (src.authenticated && src.modify)
			var/carddesc = "Registered: <a href='?src=\ref[src];reg=1'>[target_owner]</a><br>Assignment: [target_rank]"
			var/list/alljobs = get_all_jobs() + "Custom"
			var/jobs = ""
			for(var/job in alljobs)
				jobs += "<a href='?src=\ref[src];assign=[job]'>[dd_replacetext(job, " ", "&nbsp")]</a> " //make sure there isn't a line break in the middle of a job
			var/accesses = ""
			for(var/A in get_all_accesses())
				if(A in src.modify.access)
					accesses += "<a href='?src=\ref[src];access=[A];allowed=0'><font color=\"red\">[dd_replacetext(get_access_desc(A), " ", "&nbsp")]</font></a> "
				else
					accesses += "<a href='?src=\ref[src];access=[A];allowed=1'>[dd_replacetext(get_access_desc(A), " ", "&nbsp")]</a> "
			body = "[carddesc]<br>[jobs]<br><br>[accesses]"
		else
			body = "<a href='?src=\ref[src];auth=1'>{Log in}</a>"
		dat = "<tt>[header][body]<hr><a href='?src=\ref[src];mode=1'>Access Crew Manifest</a><br></tt>"
	user << browse(dat, "window=id_com;size=700x375")
	return

/obj/machinery/computer/card/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	if (href_list["modify"])
		if (src.modify)
			src.modify.name = text("[]'s ID Card ([])", src.modify.registered, src.modify.assignment)
			src.modify.loc = src.loc
			src.modify = null
		else
			var/obj/item/I = usr.equipped()
			if (istype(I, /obj/item/weapon/card/id))
				usr.drop_item()
				I.loc = src
				src.modify = I
		src.authenticated = 0
	if (href_list["scan"])
		if (src.scan)
			src.scan.loc = src.loc
			src.scan = null
		else
			var/obj/item/I = usr.equipped()
			if (istype(I, /obj/item/weapon/card/id))
				usr.drop_item()
				I.loc = src
				src.scan = I
		src.authenticated = 0
	if (href_list["auth"])
		if ((!( src.authenticated ) && (src.scan || (istype(usr, /mob/ai))) && (src.modify || src.mode)))
			if (src.check_access(src.scan))
				src.authenticated = 1
		else if ((!( src.authenticated ) && (istype(usr, /mob/ai))) && (!src.modify))
			usr << "You can't modify an ID without an ID inserted to modify. Once one is in the modify slot on the computer, you can log in."
	if(href_list["access"] && href_list["allowed"])
		if(src.authenticated)
			var/access_type = text2num(href_list["access"])
			var/access_allowed = text2num(href_list["allowed"])
			if(access_type in get_all_accesses())
				src.modify.access -= access_type
				if(access_allowed == 1)
					src.modify.access += access_type
	if (href_list["assign"])
		if (src.authenticated)
			var/t1 = href_list["assign"]
			if(t1 == "Custom")
				t1 = input("Enter a custom job assignment.","Assignment")
			else
				src.modify.access = get_access(t1)
			src.modify.assignment = t1
	if (href_list["reg"])
		if (src.authenticated)
			var/t2 = src.modify
			var/t1 = input(usr, "What name?", "ID computer", null)  as text
			if ((src.authenticated && src.modify == t2 && (get_dist(src, usr) <= 1 || (istype(usr, /mob/ai))) && istype(src.loc, /turf)))
				src.modify.registered = t1
	if (href_list["mode"])
		src.mode = text2num(href_list["mode"])
	if (href_list["print"])
		if (!( src.printing ))
			src.printing = 1
			sleep(50)
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
			var/t1 = "<B>Crew Manifest:</B><BR>"
			for(var/datum/data/record/t in data_core.general)
				t1 += "<B>[t.fields["name"]]</B> - [t.fields["rank"]]<BR>"
			P.info = t1
			P.name = "paper- 'Crew Manifest'"
			src.printing = null
	if (href_list["mode"])
		src.authenticated = 0
		src.mode = text2num(href_list["mode"])
	if (src.modify)
		src.modify.name = text("[]'s ID Card ([])", src.modify.registered, src.modify.assignment)
	src.updateUsrDialog()
	return

/obj/machinery/computer/card/attackby(I as obj, user as mob)
	src.attack_hand(user)
	return

/obj/machinery/computer/pod/proc/alarm()
	if(stat & (NOPOWER|BROKEN))
		return

	if (!( src.connected ))
		viewers(null, null) << "Cannot locate mass driver connector. Cancelling firing sequence!"
		return
	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == src.id)
			spawn( 0 )
				M.openpod()
				return
	sleep(20)

	//src.connected.drive()		*****RM from 40.93.3S
	for(var/obj/machinery/mass_driver/M in machines)
		if(M.id == src.id)
			M.power = src.connected.power
			M.drive()

	//*****
	sleep(50)
	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == src.id)
			spawn( 0 )
				M.closepod()
				return
	return

/obj/machinery/computer/pod/New()
	..()
	spawn( 5 )
		for(var/obj/machinery/mass_driver/M in machines)
			if (M.id == src.id)
				src.connected = M
	return

/obj/machinery/computer/pod/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/pod/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/pod/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = "<HTML><BODY><TT><B>Mass Driver Controls</B>"
	user.machine = src
	var/d2
	if (src.timing)
		d2 = text("<A href='?src=\ref[];time=0'>Stop Time Launch</A>", src)
	else
		d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Launch</A>", src)
	var/second = src.time % 60
	var/minute = (src.time - second) / 60
	dat += text("<HR>\nTimer System: []\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>", d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
	if (src.connected)
		var/temp = ""
		var/list/L = list( 0.25, 0.5, 1, 2, 4, 8, 16 )
		for(var/t in L)
			if (t == src.connected.power)
				temp += text("[] ", t)
			else
				temp += text("<A href = '?src=\ref[];power=[]'>[]</A> ", src, t, t)
		dat += text("<HR>\nPower Level: []<BR>\n<A href = '?src=\ref[];alarm=1'>Firing Sequence</A><BR>\n<A href = '?src=\ref[];drive=1'>Test Fire Driver</A><BR>\n<A href = '?src=\ref[];door=1'>Toggle Outer Door</A><BR>", temp, src, src, src)
	//*****RM from 40.93.3S
	else
		dat += text("<BR>\n<A href = '?src=\ref[];door=1'>Toggle Outer Door</A><BR>", src)
	//*****
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=computer'>Close</A></TT></BODY></HTML>", user)
	user << browse(dat, "window=computer;size=400x500")
	return

/obj/machinery/computer/pod/process()
	..()
	if (src.timing)
		if (src.time > 0)
			src.time = round(src.time) - 1
		else
			alarm()
			src.time = 0
			src.timing = 0
		src.updateDialog()
	return

/obj/machinery/computer/pod/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (get_dist(src, usr) <= 1 && istype(src.loc, /turf))) || (istype(usr, /mob/ai)))
		usr.machine = src
		if (href_list["power"])
			var/t = text2num(href_list["power"])
			t = min(max(0.25, t), 16)
			if (src.connected)
				src.connected.power = t
		else
			if (href_list["alarm"])
				src.alarm()
			else
				if (href_list["time"])
					src.timing = text2num(href_list["time"])
				else
					if (href_list["tp"])
						var/tp = text2num(href_list["tp"])
						src.time += tp
						src.time = min(max(round(src.time), 0), 120)
					else
						if (href_list["door"])
							for(var/obj/machinery/door/poddoor/M in machines)
								if (M.id == src.id)
									if (M.density)
										spawn( 0 )
											M.openpod()
											return
									else
										spawn( 0 )
											M.closepod()
											return
		src.add_fingerprint(usr)
		src.updateUsrDialog()

	return

/obj/datacore/proc/manifest()
	for(var/mob/human/H in world)
		if ((H.start && !( findtext(H.rname, "Syndicate ", 1, null) )))
			var/datum/data/record/G = new /datum/data/record(  )
			var/datum/data/record/M = new /datum/data/record(  )
			var/datum/data/record/S = new /datum/data/record(  )
			var/obj/item/weapon/card/id/C = H.wear_id
			if (C)
				G.fields["rank"] = C.assignment
			else
				G.fields["rank"] = "Unassigned"
			G.fields["name"] = H.rname
			G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
			M.fields["name"] = G.fields["name"]
			M.fields["id"] = G.fields["id"]
			S.fields["name"] = G.fields["name"]
			S.fields["id"] = G.fields["id"]
			if (H.gender == "female")
				G.fields["sex"] = "Female"
			else
				G.fields["sex"] = "Male"
			G.fields["age"] = text("[]", H.age)
			G.fields["fingerprint"] = text("[]", md5(H.primary.uni_identity))
			G.fields["p_stat"] = "Active"
			G.fields["m_stat"] = "Stable"
			M.fields["b_type"] = text("[]", H.b_type)
			M.fields["mi_dis"] = "None"
			M.fields["mi_dis_d"] = "No minor disabilities have been declared."
			M.fields["ma_dis"] = "None"
			M.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
			M.fields["alg"] = "None"
			M.fields["alg_d"] = "No allergies have been detected in this patient."
			M.fields["cdi"] = "None"
			M.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
			M.fields["notes"] = "No notes."
			S.fields["criminal"] = "None"
			S.fields["mi_crim"] = "None"
			S.fields["mi_crim_d"] = "No minor crime convictions."
			S.fields["ma_crim"] = "None"
			S.fields["ma_crim_d"] = "No minor crime convictions."
			S.fields["notes"] = "No notes."
			src.general += G
			src.medical += M
			src.security += S
		//Foreach goto(15)
	return

/obj/machinery/mass_driver/proc/drive(amount)
	if(stat & (BROKEN|NOPOWER))
		return

	for(var/atom/movable/O in src.loc)
		if(!O.anchored)
			use_power(O.weight * MASS_DRIVER_POWER)
			spawn( 0 )
				var/atom/targetarea = locate(src.x, src.y, src.z)
				//since NORTHEAST == NORTH & EAST, etc, doing it this way allows for diagonal mass drivers in the future
				//and isn't really any more complicated
				if(src.dir & NORTH)
					targetarea = locate(targetarea.x, world.maxy, targetarea.z)
				if(src.dir & SOUTH)
					targetarea = locate(targetarea.x, 1, targetarea.z)
				if(src.dir & EAST)
					targetarea = locate(world.maxx, targetarea.y, targetarea.z)
				if(src.dir & WEST)
					targetarea = locate(1, targetarea.y, targetarea.z)
				O.throw_at(targetarea, drive_range * src.power, src.power)
	flick("mass_driver1", src)
	return


