mob/human/npc

	New()
		. = ..()
		Login()

	var/atom/talking_to = null

	// called asynchronously at round start
	proc/npc_process()
		wander()

	proc/wander()
		while(1)
			var/d = pick(NORTH, SOUTH, EAST, WEST)
			var/turf/T = get_step(src, d)
			if(talking_to == null)
				step(src, d)
			else if(talking_to in view(T))
				step(src, d)
			sleep(max(src.move_delay - world.time, 10))

	// does not return until the NPC has entered the area
	// returns 1 on success, 0 on failure
	proc/goto_area(area_path)
		var/area/A = locate(area_path)
		if(!A)
			return 0
		var/list/turfs = new
		for(var/turf/T in A.contents)
			if(T.isempty())
				turfs += T
		return goto_turf(pick(turfs))

	// see note for goto_area
	proc/goto_turf(turf/T)
		var/list/path = AStar(loc, T, 2000)
		if(!path)
			//world << "Pathfinding fail."
			return 0
		//world << "Pathfinding success. [path.len] nodes."

		for(var/k = 1, k <= path.len, k++)
			var/turf/T2 = path[k]
			if(T2 == loc)
				continue
			var/turf/OL = loc
			WalkInDirection(get_dir(loc, T2))
			var/delay = src.move_delay - world.time
			sleep(delay)
			world << "[OL.x],[OL.y] -> [loc.x],[loc.y]"
			if(loc == OL)
				sleep(10)
				k--
			else if(loc != T2)
				var/k2 = path.Find(loc) - 1
				if(k2 != -1)
					k = k2
		return 1

	// sets src.patrolling, loops until it's reset
	var/patrolling = 0
	proc/patrol()
		patrolling = 1
		var/obj/patrol_node/cur_node
		var/best_dist
		while(!cur_node)
			for(var/obj/patrol_node/P)
				if(P.z != z) continue
				var/d = abs(P.x - x) + abs(P.y - y)
				if(!cur_node || best_dist > d)
					cur_node = P
					best_dist = d
			if(!cur_node)
				sleep(10)
		while(patrolling)
			if(!isturf(cur_node.loc))
				return
			if(!goto_turf(cur_node.loc))
				return
			cur_node = pick(cur_node.links)

/obj/patrol_node
	icon = 'icons/ss13/screen.dmi'
	icon_state = "x3"
	invisibility = 101
	var/links = list()
	New()
		spawn
			if(!isturf(loc))
				del(src)
			for(var/obj/patrol_node/P)
				if(P == src) continue
				if(P.z != z || !isturf(P.loc)) continue
				if(P.x == x || P.y == y)
					var/d = get_dir(P.loc, src)
					var/turf/T = P.loc
					// check the line of tiles between loc and P.loc isn't blocked
					while(T && T != loc)
						if(T.density || !T.isempty())
							//spawn world << "line from [P.loc.x],[P.loc.y] to [loc.x],[loc.y] blocked at [T.x],[T.y]"
							break
						T = get_step(T, d)
					if(T == loc)
						links += P
					//else if(!T)
						//spawn world << "line from [P.loc.x],[P.loc.y] to [loc.x],[loc.y] blocked by map edge"

proc/CreateNPC(job)
	switch(job)
		if("Quartermaster")
			return new/mob/human/npc/quartermaster
		else
			return null