world
	maxx = 100
	maxy = 100
	maxz = 1

randomizer
	var
		list/cells
		xcells
		ycells
		cellsize
		minx
		miny
		maxx
		maxy

	proc/SetCell(x, y, area/A, turftype)
		if(!isarea(A)) A = locate(A)
		cells[x][y] = A
		x = (x-1)*cellsize+minx
		y = (y-1)*cellsize+miny

		var/obj/start/S = new(locate(x+round(cellsize/2), y+round(cellsize/2), 1))
		S.name = "Captain"
		S.New()

		for(var/x2 in x to x+cellsize-1)
			for(var/y2 in y to y+cellsize-1)
				A.contents += new turftype(locate(x2,y2,1))
		world.log << "[x],[y] = [A],[turftype]"

	proc/MakeWall(x, y, d)
		var/area/A = cells[x][y]
		x = (x-1)*cellsize+minx
		y = (y-1)*cellsize+miny
		if(d == NORTH)
			y += cellsize - 1
			d = SOUTH
		if(d == EAST)
			x += cellsize - 1
			d = WEST
		if(d == WEST)
			for(var/y2 in y to y+cellsize-1)
				A.contents += new/turf/simulated/wall(locate(x,y2,1))
		else
			for(var/x2 in x to x+cellsize-1)
				A.contents += new/turf/simulated/wall(locate(x2,y,1))

	proc/PlaceRoom(required_area, area/A, turftype, area/seed_area = null)
		required_area = -round(-required_area/(cellsize**2))
		if(!isarea(A)) A = locate(A)
		var/x[]
		var/y[]
		var/pick_one = 0
		if(seed_area == null)
			while(x == null || cells[x[1]][y[1]] != null)
				x = list(rand(1, xcells))
				y = list(rand(1, ycells))
			SetCell(x[1], y[1], A, turftype)
			required_area--
		else
			if(!isarea(seed_area))
				seed_area = locate(seed_area)
			x = list()
			y = list()
			for(var/x2 in 1 to xcells)
				for(var/y2 in 1 to ycells)
					if(cells[x2][y2] == seed_area)
						x += x2
						y += y2
			pick_one = 1

		for(var/k in 1 to required_area)
			var/tn
			var/tx
			var/ty
			var/attempts = 0
			while(tx == null || tx < 1 || ty < 1 || tx > xcells || ty > ycells || cells[tx][ty] != null)
				if(attempts > 100)
					spawn(10)
						world.log << "FAILED TO ALLOCATE [required_area - k]/[required_area + (seed_area == null ? 1 : 0)] cells for [A.type]!!!"
					return
				tn = rand(1, x.len)
				if(x.len == 0)
					spawn(10)
						world.log << "[x.len] [tn] [pick_one] [seed_area ? seed_area.type : "(null)"]"
				tx = x[tn]
				ty = y[tn]
				attempts++
				if(prob(25))
					tx = tx - 1
				else if(prob(33))
					tx = tx + 1
				else if(prob(50))
					ty = ty - 1
				else
					ty = ty + 1
			SetCell(tx, ty, A, turftype)
			if(pick_one)
				x = list(tx)
				y = list(ty)
				pick_one = 0
			else
				x += tx
				y += ty

		for(var/k in 1 to x.len)
			var/tx = x[k]
			var/ty = y[k]
			if(tx == 1 || cells[tx-1][ty] != A)
				MakeWall(tx, ty, WEST)
			if(ty == 1 || cells[tx][ty-1] != A)
				MakeWall(tx, ty, SOUTH)
			if(tx == xcells || cells[tx+1][ty] != A)
				MakeWall(tx, ty, EAST)
			if(ty == ycells || cells[tx][ty+1] != A)
				MakeWall(tx, ty, NORTH)

	proc/LinkAreas(area/A, area/B, doortype)
		if(!isarea(A)) A = locate(A)
		if(!isarea(B)) B = locate(B)

		if(!A || !B)
			CRASH("Invalid parameters to LinkArea: [A],[B],[doortype]")

		var/list/pairs = new

		for(var/x in 1 to xcells)
			for(var/y in 1 to ycells)
				if(cells[x][y] == A)
					if(x > 1 && cells[x-1][y] == B)
						pairs += list(x, y, x-1, y, WEST)
					if(y > 1 && cells[x][y-1] == B)
						pairs += list(x, y, x, y-1, SOUTH)
					if(x < xcells && cells[x+1][y] == B)
						pairs += list(x, y, x+1, y, EAST)
					if(y < ycells && cells[x][y+1] == B)
						pairs += list(x, y, x, y+1, NORTH)

		if(pairs.len == 0)
			CRASH("Cannot connect areas directly: [A.type] and [B.type]")

		var/n = round(pairs.len / 10) + 1
		var/ofs = round(cellsize/2)
		for(var/k in 1 to n)
			var/id = rand(1, pairs.len/5) * 5 - 4
			var/x1 = pairs[id]
			var/y1 = pairs[id+1]
			var/x2 = pairs[id+2]
			var/y2 = pairs[id+3]
			var/d = pairs[id+4]
			var/tx1
			var/ty1
			var/airlock_turf
			tx1 = (x1-1)*cellsize+minx
			ty1 = (y1-1)*cellsize+miny
			if(d == EAST)
				airlock_turf = new/turf/simulated/floor(locate(tx1+cellsize-1, ty1+ofs, 1))
				B.contents += new/turf/simulated/floor(locate(tx1+cellsize, ty1+ofs, 1))
			if(d == WEST)
				airlock_turf = new/turf/simulated/floor(locate(tx1, ty1+ofs, 1))
				B.contents += new/turf/simulated/floor(locate(tx1-1, ty1+ofs, 1))
			if(d == NORTH)
				airlock_turf = new/turf/simulated/floor(locate(tx1+ofs, ty1+cellsize-1, 1))
				B.contents += new/turf/simulated/floor(locate(tx1+ofs, ty1+cellsize, 1))
			if(d == SOUTH)
				airlock_turf = new/turf/simulated/floor(locate(tx1+ofs, ty1, 1))
				B.contents += new/turf/simulated/floor(locate(tx1+ofs, ty1-1, 1))
			A.contents += airlock_turf
			if(locate(/obj/machinery/door) in airlock_turf || locate(/obj/shuttle/door) in airlock_turf)
				continue
			var/obj/machinery/door/airlock = new doortype(airlock_turf)
			if(A.primary_permission != null || B.primary_permission != null)
				var/a_perm = A.primary_permission
				var/b_perm = B.primary_permission
				if(a_perm != null && b_perm != null)
					airlock.req_access = list(a_perm, b_perm)
				else if(a_perm != null)
					airlock.req_access = list(a_perm)
				else
					airlock.req_access = list(b_perm)
			else
				airlock.req_access = null
			airlock.dir = (doortype == /obj/machinery/door/window ? turn(d, 90) : d)
			airlock.name = "[A.name]/[B.name]"

	proc/LinkAdjacentAreas(doortype)
		var/list/pairs = new

		for(var/x in 1 to xcells)
			for(var/y in 1 to ycells)
				var/A = cells[x][y]
				if(x > 1 && cells[x-1][y] != A)
					pairs += list(x, y, x-1, y, WEST)
				if(y > 1 && cells[x][y-1] != A)
					pairs += list(x, y, x, y-1, SOUTH)
				if(x < xcells && cells[x+1][y] != A)
					pairs += list(x, y, x+1, y, EAST)
				if(y < ycells && cells[x][y+1] != A)
					pairs += list(x, y, x, y+1, NORTH)

		var/n = pairs.len/5
		var/ofs = round(cellsize/2)
		for(var/k in 1 to n)
			var/id = rand(1, pairs.len/5) * 5 - 4
			var/x1 = pairs[id]
			var/y1 = pairs[id+1]
			var/x2 = pairs[id+2]
			var/y2 = pairs[id+3]
			var/d = pairs[id+4]
			var/tx1 = (x1-1)*cellsize+minx
			var/ty1 = (y1-1)*cellsize+miny
			var/airlock_turf
			var/tdoortype = doortype
			var/area/A = cells[x1][y1]
			var/area/B = cells[x2][y2]
			if(!A)
				continue
			if(!B)
				if(prob(80)) continue
				B = locate(/area)
				tdoortype = /obj/machinery/door/airlock/external
			if(d == EAST)
				airlock_turf = new/turf/simulated/floor(locate(tx1+cellsize-1, ty1+ofs, 1))
				B.contents += new/turf/simulated/floor(locate(tx1+cellsize, ty1+ofs, 1))
			if(d == WEST)
				airlock_turf = new/turf/simulated/floor(locate(tx1, ty1+ofs, 1))
				B.contents += new/turf/simulated/floor(locate(tx1-1, ty1+ofs, 1))
			if(d == NORTH)
				airlock_turf = new/turf/simulated/floor(locate(tx1+ofs, ty1+cellsize-1, 1))
				B.contents += new/turf/simulated/floor(locate(tx1+ofs, ty1+cellsize, 1))
			if(d == SOUTH)
				airlock_turf = new/turf/simulated/floor(locate(tx1+ofs, ty1, 1))
				B.contents += new/turf/simulated/floor(locate(tx1+ofs, ty1-1, 1))
			A.contents += airlock_turf
			if(locate(/obj/machinery/door) in airlock_turf || locate(/obj/shuttle/door) in airlock_turf)
				continue
			var/obj/machinery/door/airlock = new tdoortype(airlock_turf)
			if(A.primary_permission != null || B.primary_permission != null)
				var/a_perm = A.primary_permission
				var/b_perm = B.primary_permission
				if(a_perm != null && b_perm != null)
					airlock.req_access = list(a_perm, b_perm)
				else if(a_perm != null)
					airlock.req_access = list(a_perm)
				else
					airlock.req_access = list(b_perm)
			else
				airlock.req_access = null
			airlock.dir = (doortype == /obj/machinery/door/window ? turn(d, 90) : d)
			airlock.name = "[A.name]/[B.name]"


	proc/RandomizeMap()
		var/area/A = locate(/area/start)
		A.contents += locate(6,6,1)
		A.contents += locate(5,6,1)
		A = locate(/area/arrival/start)
		A.contents += locate(6,5,1)

		minx = world.maxx*0.2
		maxx = world.maxx*0.8
		miny = world.maxy*0.2
		maxy = world.maxy*0.8

		cellsize = 5
		xcells = round((maxx - minx - 1) / cellsize)
		ycells = round((maxy - miny - 1) / cellsize)
		cells = new(xcells, ycells)

		PlaceRoom(200, /area/bridge, /turf/simulated/floor)
		PlaceRoom(200, /area/chapel/main, /turf/simulated/floor/chapel_red_tiled)
		PlaceRoom(50, /area/chapel/office, /turf/simulated/floor/chapel_red_tiled, /area/chapel/main)
		PlaceRoom(50, /area/medical/morgue, /turf/simulated/floor/whitefloor, /area/chapel/main)
		PlaceRoom(200, /area/medical/medbay, /turf/simulated/floor/whitefloor, /area/medical/morgue)
		PlaceRoom(100, /area/medical/research, /turf/simulated/floor/whitefloor)
		PlaceRoom(100, /area/arrival/shuttle, /turf/simulated/shuttle/floor)
		PlaceRoom(25, /area/security/checkpoint, /turf/simulated/floor, /area/arrival/shuttle)
		PlaceRoom(50, /area/security/forensics, /turf/simulated/floor/carpet)
		PlaceRoom(100, /area/security/main, /turf/simulated/floor, /area/bridge)
		PlaceRoom(200, /area/security/brig, /turf/simulated/floor, /area/security/main)
		PlaceRoom(50, /area/storage/auxillary, /turf/simulated/floor)
		PlaceRoom(50, /area/storage/emergency, /turf/simulated/floor)
		PlaceRoom(75, /area/storage/eva, /turf/simulated/floor)
		PlaceRoom(50, /area/storage/secure, /turf/simulated/floor)
		PlaceRoom(100, /area/storage/tools, /turf/simulated/floor)
		PlaceRoom(25, /area/teleporter, /turf/simulated/floor)
		PlaceRoom(250, /area/toxins/lab, /turf/simulated/floor/whitefloor)
		PlaceRoom(75, /area/toxins/storage, /turf/simulated/floor/whitefloor, /area/toxins/lab)
		PlaceRoom(25, /area/turret_protected/ai_upload_foyer, /turf/simulated/floor/aifloor)
		PlaceRoom(50, /area/turret_protected/ai_upload, /turf/simulated/floor/aifloor, /area/turret_protected/ai_upload_foyer)
		PlaceRoom(50, /area/turret_protected/ai, /turf/simulated/floor/aifloor)

		LinkAreas(/area/chapel/main, /area/chapel/office, /obj/machinery/door/window)
		LinkAreas(/area/medical/morgue, /area/chapel/main, /obj/machinery/door)
		LinkAreas(/area/medical/medbay, /area/medical/morgue, /obj/machinery/door)
		LinkAreas(/area/security/checkpoint, /area/arrival/shuttle, /obj/shuttle/door)
		LinkAreas(/area/bridge, /area/security/main, /obj/machinery/door/airlock)
		LinkAreas(/area/security/brig, /area/security/main, /obj/machinery/door/window)
		LinkAreas(/area/toxins/storage, /area/toxins/lab, /obj/machinery/door/airlock)
		LinkAreas(/area/turret_protected/ai_upload_foyer, /area/turret_protected/ai_upload, /obj/machinery/door/window)

		LinkAdjacentAreas(/obj/machinery/door/airlock)

world/New()
	var/randomizer/R = new
	R.RandomizeMap()
	. = ..()

mob/human/Login()
	. = ..()
	spawn
		usr = src
		var/obj/begin/B = new(loc)

		spawn(5)
			var/obj/admins/A = client.holder
			A.start_now()

			spawn(5)
				if(back)
					back.loc = loc
					back.layer = initial(back.layer)
					back = null
				var/obj/item/tank/jetpack/J = new(src)
				J.toggle()
				J.layer = 20
				back = J
				internal = J

		B.ready()

mob/human/Life()
	. = ..()
	oxyloss = 0
	toxloss = 0
	fireloss = 0
	bruteloss = 0
	bodytemperature = T20C


