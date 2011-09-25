// Double clicking turfs to move to nearest camera

/turf/proc/move_camera_by_click()
	if(usr.stat)
		return ..()
	if(world.time <= usr:lastDblClick+2)
		return ..()
	//try to find the closest working camera in the same area, switch to it
	var/area/A = get_area(src)
	var/best_dist = INFINITY //infinity
	var/best_cam = null
	for(var/obj/machinery/camera/C in A)
		if(usr:network != C.network)
			continue	//	different network (syndicate)
		if(C.z != usr.z)
			continue	//	different viewing plane
		if(!C.status)
			continue	//	ignore disabled cameras
		var/dist = get_dist(src, C)
		if(dist < best_dist)
			best_dist = dist
			best_cam = C

	if(!best_cam)
		return ..()
	usr:lastDblClick = world.time
	usr:switchCamera(best_cam)

/mob/ai/proc/ai_camera_list()
	set category = "AI Commands"
	set name = "Show Camera List"

	if(usr.stat == 2)
		usr << "You can't track with camera because you are dead!"
		return

	attack_ai(src)

/mob/ai/proc/ai_camera_track()
	set category = "AI Commands"
	set name = "Track With Camera"
	if(usr.stat == 2)
		usr << "You can't track with camera because you are dead!"
		return

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()
	for (var/mob/M in world)
		if (istype(M, /mob/human) && istype(M:wear_id, /obj/item/weapon/card/id/syndicate))
			continue
		if(!istype(M.loc, /turf)) //in a closet or something, AI can't see him anyways
			continue
		if(M.invisibility) //cloaked
			continue
		else if (M == usr)
			continue

		var/name = M.name
		if (name in names)
			namecounts[name]++
			name = text("[] ([])", name, namecounts[name])
		else
			names.Add(name)
			namecounts[name] = 1

		creatures[name] = M

	var/target_name = input(usr, "Which creature should you track?") as null|anything in creatures

	if (!target_name)
		usr:cameraFollow = null
		return

	var/mob/target = creatures[target_name]

	usr:cameraFollow = target
	usr << text("Now tracking [] on camera.", target.name)
	if (usr.machine == null)
		usr.machine = usr

	spawn (0)
		while (usr:cameraFollow == target)
			if (usr:cameraFollow == null)
				return
			else if (istype(target, /mob/human) && istype(target:wear_id, /obj/item/weapon/card/id/syndicate))
				usr << "Follow camera mode ended."
				usr:cameraFollow = null
				return
			else if (!target || !istype(target.loc, /turf)) //in a closet
				usr << "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb)."
				sleep(40) //because we're sleeping another second after this (a few lines down)
				continue

			var/obj/machinery/camera/C = usr:current
			if ((C && istype(C, /obj/machinery/camera)) || C==null)

				var/closestDist = -1
				if (C!=null)
					if (C.status)
						closestDist = get_dist(C, target)
				//usr << text("Dist = [] for camera []", closestDist, C.name)
				var/zmatched = 0
				if (closestDist > 7 || closestDist == -1)
					//check other cameras
					var/obj/machinery/camera/closest = C
					for(var/obj/machinery/camera/C2 in world)
						if (C2.network == src.network)
							if (C2.z == target.z)
								zmatched = 1
								if (C2.status)
									var/dist = get_dist(C2, target)
									if ((dist < closestDist) || (closestDist == -1))
										closestDist = dist
										closest = C2
					//usr << text("Closest camera dist = [], for camera []", closestDist, closest.area.name)

					if (closest != C)
						usr:current = closest
						usr.reset_view(closest)
					if (zmatched == 0)
						usr << "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb)."
						sleep(40) //because we're sleeping another second after this (a few lines down)
			else
				usr << "Follow camera mode ended."
				usr:cameraFollow = null

			sleep(10)

/proc/camera_sort(list/L)
	var/obj/machinery/camera/a
	var/obj/machinery/camera/b

	for (var/i = L.len, i > 0, i--)
		for (var/j = 1 to i - 1)
			a = L[j]
			b = L[j + 1]
			if (a.c_tag_order != b.c_tag_order)
				if (a.c_tag_order > b.c_tag_order)
					L.Swap(j, j + 1)
			else
				if (sorttext(a.c_tag, b.c_tag) < 0)
					L.Swap(j, j + 1)
	return L

/obj/machinery/computer/security/attack_hand(var/mob/user as mob)
	if (stat & (NOPOWER|BROKEN))
		return

	user.machine = src

	var/list/L = list()
	for (var/obj/machinery/camera/C in world)
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	D["Cancel"] = "Cancel"
	for (var/obj/machinery/camera/C in L)
		if (C.network == src.network)
			D[text("[][]", C.c_tag, (C.status ? null : " (Deactivated)"))] = C

	var/t = input(user, "Which camera should you change to?") as null|anything in D

	if(!t)
		user.machine = null
		return 0

	var/obj/machinery/camera/C = D[t]

	if (t == "Cancel")
		user.machine = null
		return 0

	if ((get_dist(user, src) > 1 || user.machine != src || user.blinded || !( user.canmove ) || !( C.status )) && (!istype(user, /mob/ai)))
		return 0
	else
		src.current = C
		use_power(CAMERA_COMPUTER_POWER)

		spawn( 5 )
			attack_hand(user)

/mob/ai/attack_ai(var/mob/user as mob)
	if (user != src)
		return

	if (stat == 2)
		return

	user.machine = src

	var/list/L = list()
	for (var/obj/machinery/camera/C in world)
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	D["Cancel"] = "Cancel"
	for (var/obj/machinery/camera/C in L)
		if (C.network == src.network)
			D[text("[][]", C.c_tag, (C.status ? null : " (Deactivated)"))] = C

	var/t = input(user, "Which camera should you change to?") as null|anything in D

	if (!t || t == "Cancel")
		switchCamera(null)
		return 0

	var/obj/machinery/camera/C = D[t]

	switchCamera(C)

	return

/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return
	else
		..(severity)
	return

/obj/machinery/camera/blob_act()
	return