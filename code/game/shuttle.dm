obj/machinery/computer/shuttle
	name = "Shuttle Controller"
	icon = 'icons/ss13/shuttle.dmi'
	icon_state = "shuttlecom"

	var/area = null // string with path to area

	var/transit_zlevel = 3
	var/end_zlevel = 2

	var/datum/shuttle/shuttle

	New()
		. = ..()
		shuttle = new
		shuttle.transit_zlevel = transit_zlevel
		shuttle.end_zlevel = end_zlevel
		shuttle.area = text2path(area)
		shuttle.cur_zlevel = src.z

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					for(var/x in src.verbs)
						src.verbs -= x
					src.icon_state = "broken"
			if(3.0)
				if (prob(25))
					for(var/x in src.verbs)
						src.verbs -= x
					src.icon_state = "broken"
			else
		return

	verb/take_off()
		if(src.z == transit_zlevel)
			usr << "\red Already in transit! Please wait!"
			return
		src.add_fingerprint(usr)

		shuttle.take_off()


datum/shuttle
	var/transit_zlevel
	var/end_zlevel
	var/area
	var/cur_zlevel

	// does not return until the shuttle has arrived at its destination
	proc/take_off()
		set src in oview(1)

		if (usr.stat || usr.restrained())
			return

		var/A = locate(area)
		for(var/mob/M in A)
			if(M.z != cur_zlevel) continue
			M.show_message("\red Launch sequence initiated!")
			spawn(0)	shake_camera(M, 10, 1)

		for(var/obj/machinery/door/poddoor/M in A)
			if(M.z != cur_zlevel) continue
			if(!M.density)
				spawn M.closepod()
		for(var/obj/machinery/door/D in A)
			if(D.z != cur_zlevel) continue
			if(!D.density && !istype(D, /obj/machinery/door/poddoor))
				spawn D.close()
		for(var/obj/shuttle/door/D in A)
			if(D.z != cur_zlevel) continue
			if(!D.density)
				spawn D.close()

		sleep(10)

		var/original_zlevel = cur_zlevel

		for(var/turf/T as turf in A)
			if(T.z != cur_zlevel) continue
			move_turf(T, transit_zlevel)
		for(var/turf/T as turf in A)
			T.buildlinks()

		cur_zlevel = transit_zlevel

		var/time = rand(2,4)
		sleep(time)

		for(var/turf/T as turf in A)
			if(T.z != cur_zlevel) continue
			move_turf(T, end_zlevel)
		for(var/turf/T as turf in A)
			T.buildlinks()

		cur_zlevel = end_zlevel
		end_zlevel = original_zlevel

		for(var/obj/machinery/door/poddoor/M in A)
			if(M.z != cur_zlevel) continue
			if (M.density)
				spawn M.openpod()

		for(var/mob/M in A)
			if(M.z != cur_zlevel) continue
			M.show_message("\red Arrived at destination!")
			spawn(0)	shake_camera(M, 2, 1)

	proc/move_turf(turf/T, newz)
		if(newz == T.z)
			return
		var/turf/newT = new T.type(locate(T.x, T.y, newz))
		for(var/key in T.vars)
			if(issaved(T.vars[key]))
				newT.vars[key] = T.vars[key]
		for(var/atom/movable/AM in T)
			AM.loc = newT
		newT = new/turf/space(T)
		newT.overlays = null


obj/machinery/computer/shuttle/escape
	ex_act(severity)
		switch(severity)
			if(1.0)
				//SN src = null
				del(src)
				return
			if(2.0)
				if (prob(50))
					for(var/x in src.verbs)
						src.verbs -= x
					src.icon_state = "broken"
			if(3.0)
				if (prob(25))
					for(var/x in src.verbs)
						src.verbs -= x
					src.icon_state = "broken"
			else
		return

	New()
		. = ..()
		src.verbs -= /obj/machinery/computer/shuttle/verb/take_off

	attackby(var/obj/item/weapon/card/id/W as obj, var/mob/user as mob)
		if(stat & (BROKEN|NOPOWER))
			return
		if ((!( istype(W, /obj/item/weapon/card/id) ) || !( ticker ) || ticker.shuttle_location == shuttle_z || !( user )))
			return
		if (!W.access) //no access
			user << "The access level of [W.registered]\'s card is not high enough. "
			return
		var/list/cardaccess = W.access
		if(!istype(cardaccess, /list) || !cardaccess.len) //no access
			user << "The access level of [W.registered]\'s card is not high enough. "
			return
		var/choice = alert(user, text("Would you like to (un)authorize a shortened launch time? [] authorization\s are still needed. Use abort to cancel all authorizations.", src.auth_need - src.authorized.len), "Shuttle Launch", "Authorize", "Repeal", "Abort")
		switch(choice)
			if("Authorize")
				src.authorized -= W.registered
				src.authorized += W.registered
				if (src.auth_need - src.authorized.len > 0)
					world << text("\blue <B>Alert: [] authorizations needed until shuttle is launched early</B>", src.auth_need - src.authorized.len)
				else
					world << "\blue <B>Alert: Shuttle launch time shortened to 10 seconds!</B>"
					ticker.timeleft = 100
					//src.authorized = null
					del(src.authorized)
					src.authorized = list(  )
			if("Repeal")
				src.authorized -= W.registered
				world << text("\blue <B>Alert: [] authorizations needed until shuttle is launched early</B>", src.auth_need - src.authorized.len)
			if("Abort")
				world << "\blue <B>All authorizations to shorting time for shuttle launch have been revoked!</B>"
				src.authorized.len = 0
				src.authorized = list(  )

#ifdef USE_OBJ_MOVE
obj/shut_controller/proc/rotate(direct)
	var/SE_X = 1
	var/SE_Y = 1
	var/SW_X = 1
	var/SW_Y = 1
	var/NE_X = 1
	var/NE_Y = 1
	var/NW_X = 1
	var/NW_Y = 1
	for(var/obj/move/M in src.parts)
		if (M.x < SW_X)
			SW_X = M.x
		if (M.x > SE_X)
			SE_X = M.x
		if (M.y < SW_Y)
			SW_Y = M.y
		if (M.y > NW_Y)
			NW_Y = M.y
		if (M.y > NE_Y)
			NE_Y = M.y
		if (M.y < SE_Y)
			SE_Y = M.y
		if (M.x > NE_X)
			NE_X = M.x
		if (M.x < NW_X)
			NW_X = M.y
	var/length = abs(NE_X - NW_X)
	var/width = abs(NE_Y - SE_Y)
	var/obj/random = pick(src.parts)
	var/s_direct = null
	switch(s_direct)
		if(1.0)
			switch(direct)
				if(90.0)
					var/tx = SE_X
					var/ty = SE_Y
					var/t_z = random.z
					for(var/obj/move/M in src.parts)
						M.ty =  -M.x - tx
						M.tx =  -M.y - ty
						var/T = locate(M.x, M.y, 11)
						M.relocate(T)
						M.ty =  -M.ty
						M.tx += length
					for(var/obj/move/M in src.parts)
						M.tx += tx
						M.ty += ty
						var/T = locate(M.tx, M.ty, t_z)
						M.relocate(T, 90)
				if(-90.0)
					var/tx = SE_X
					var/ty = SE_Y
					var/t_z = random.z
					for(var/obj/move/M in src.parts)
						M.ty = M.x - tx
						M.tx = M.y - ty
						var/T = locate(M.x, M.y, 11)
						M.relocate(T)
						M.ty =  -M.ty
						M.ty += width
					for(var/obj/move/M in src.parts)
						M.tx += tx
						M.ty += ty
						var/T = locate(M.tx, M.ty, t_z)
						M.relocate(T, -90.0)
#endif

obj/shuttle/door
	attackby(obj/item/I as obj, mob/user as mob)
		if (src.operating)
			return
		if (src.density)
			return open()
		else
			return close()

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		return attackby(user, user)

	proc/open()
		src.add_fingerprint(usr)
		if (src.operating)
			return
		src.operating = 1
		flick("doorc0", src)
		src.icon_state = "door0"
		sleep(15)

		src.density = 0
		src.opacity = 0
		src.operating = 0
		src.loc.buildlinks()
		return

	proc/close()
		src.add_fingerprint(usr)
		if (src.operating)
			return
		src.operating = 1
		flick("doorc1", src)
		src.icon_state = "door1"
		src.density = 1
		if (src.visible)
			src.opacity = 1
		sleep(15)

		src.operating = 0
		src.loc.buildlinks()
		return


	meteorhit(obj/M as obj)
		src.open()
		return

/turf/simulated/shuttle/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			var/turf/space/S = src.ReplaceWithSpace()
			S.buildlinks()

			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				var/turf/space/S = src.ReplaceWithSpace()
				S.buildlinks()

				del(src)
				return
		else
	return

/turf/simulated/shuttle/blob_act()
	if(prob(20))

		var/turf/space/S = src.ReplaceWithSpace()
		S.buildlinks()

		del(src)
