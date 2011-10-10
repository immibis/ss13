// the nwnet datum
// each contiguous network of cables & nodes


// rebuild all power networks from scratch

/datum/nwnet
	var/list/cables = list()	// all cables & junctions
	var/list/nodes = list()		// all APCs & sources
	var/newload = 0
	var/load = 0
	var/newavail = 0
	var/avail = 0

	var/viewload = 0

	var/number = 0

	var/perapc = 0			// per-apc avilability

	var/netexcess = 0

/proc/makenwnets()

	var/netcount = 0
	nwnets = list()

	for(var/obj/net_cable/PC in world)
		PC.netnum = 0
	for(var/obj/machinery/network/M in machines)
		if(M.netnum >=0)
			M.netnum = 0


	for(var/obj/net_cable/PC in world)
		if(!PC.netnum)
			PC.netnum = ++netcount

			if(Debug) world.log << "Starting mpn at [PC.x],[PC.y] ([PC.d1]/[PC.d2]) #[netcount]"
			nwnet_nextlink(PC, PC.netnum)

	if(Debug) world.log << "[netcount] nwnets found"

	for(var/L = 1 to netcount)
		var/datum/nwnet/PN = new()
		//PN.tag = "nwnet #[L]"
		nwnets += PN
		PN.number = L


	for(var/obj/net_cable/C in world)
		var/datum/nwnet/PN = nwnets[C.netnum]
		PN.cables += C

	for(var/obj/machinery/network/M in machines)
		if(M.netnum<=0)		// APCs have netnum=-1 so they don't count as network nodes directly
			continue

		M.nwnet = nwnets[M.netnum]
		M.nwnet.nodes += M

world/New()
	. = ..()
	makenwnets()




// returns a list of all power-related objects (nodes, cable, junctions) in turf,
// excluding source, that match the direction d
// if unmarked==1, only return those with netnum==0

/proc/network_list(var/turf/T, var/source, var/d, var/unmarked=0)
	var/list/result = list()
	var/fdir = (!d)? 0 : turn(d, 180)	// the opposite direction to d (or 0 if d==0)

	for(var/obj/machinery/network/P in T)
		if(P.netnum < 0)	// exclude APCs
			continue

		/*if(P.directwired)	// true if this machine covers the whole turf (so can be joined to a cable on neighbour turf)
			if(!unmarked || !P.netnum)
				result += P
		else*/ if(d == 0)		// otherwise, need a 0-X cable on same turf to connect*
			if(!unmarked || !P.netnum)
				result += P


	for(var/obj/net_cable/C in T)
		if(C.d1 == fdir || C.d2 == fdir)
			if(!unmarked || !C.netnum)
				result += C

	result -= source

	return result


/obj/net_cable/proc/get_connections()

	var/list/res = list()	// this will be a list of all connected power objects

	var/turf/T
	if(!d1)
		T = src.loc		// if d1=0, same turf as src
	else
		T = get_step(src, d1)

	res += network_list(T, src , d1, 1)

	T = get_step(src, d2)

	res += network_list(T, src, d2, 1)

	return res


/obj/machinery/network/proc/get_connections()

	/*if(!directwired)
		return get_indirect_connections()

	var/list/res = list()
	var/cdir

	for(var/turf/T in orange(1, src))

		cdir = get_dir(T, src)

		for(var/obj/net_cable/C in T)
			if(C.type != /obj/cable) continue

			if(C.netnum)
				continue

			if(C.d1 == cdir || C.d2 == cdir)
				res += C

	return res

/obj/machinery/network/proc/get_indirect_connections()*/

	var/list/res = list()

	for(var/obj/net_cable/C in src.loc)
		if(C.type != /obj/cable) continue

		if(C.netnum)
			continue

		if(C.d1 == 0)
			res += C

	return res


/proc/nwnet_nextlink(var/obj/O, var/num)

	var/list/P

	//world.log << "start: [O] at [O.x].[O.y]"


	while(1)

		if( istype(O, /obj/cable) )
			var/obj/net_cable/C = O

			C.netnum = num

		else if( istype(O, /obj/machinery/network) )

			var/obj/machinery/network/M = O

			M.netnum = num


		if( istype(O, /obj/cable) )
			var/obj/net_cable/C = O

			P = C.get_connections()

		else if( istype(O, /obj/machinery/network) )

			var/obj/machinery/network/M = O

			P = M.get_connections()

		if(P.len == 0)
			//world.log << "end1"
			return

		O = P[1]


		for(var/L = 2 to P.len)

			nwnet_nextlink(P[L], num)

		//world.log << "next: [O] at [O.x].[O.y]"







// cut a nwnet at this cable object

/datum/nwnet/proc/cut_cable(var/obj/net_cable/C)

	var/turf/T1 = C.loc
	if(C.d1)
		T1 = get_step(C, C.d1)

	var/turf/T2 = get_step(C, C.d2)

	var/list/P1 = network_list(T1, C, C.d1)	// what joins on to cut cable in dir1

	var/list/P2 = network_list(T2, C, C.d2)	// what joins on to cut cable in dir2

	if(Debug)
		for(var/obj/O in P1)
			world.log << "P1: [O] at [O.x] [O.y] : [istype(O, /obj/cable) ? "[O:d1]/[O:d2]" : null] "
		for(var/obj/O in P2)
			world.log << "P2: [O] at [O.x] [O.y] : [istype(O, /obj/cable) ? "[O:d1]/[O:d2]" : null] "



	if(P1.len == 0 || P2.len ==0)			// if nothing in either list, then the cable was an endpoint
											// no need to rebuild the nwnet, just remove cut cable from the list
		cables -= C
		if(Debug) world.log << "Was end of cable"
		return

	// zero the netnum of all cables & nodes in this nwnet

	for(var/obj/net_cable/OC in cables)
		OC.netnum = 0
	for(var/obj/machinery/network/OM in nodes)
		OM.netnum = 0


	// remove the cut cable from the network
	C.netnum = -1
	C.loc = null
	cables -= C




	nwnet_nextlink(P1[1], number)		// propagate network from 1st side of cable, using current netnum

	// now test to see if propagation reached to the other side
	// if so, then there's a loop in the network

	var/notlooped = 0
	for(var/obj/O in P2)
		if( istype(O, /obj/machinery/network) )
			var/obj/machinery/network/OM = O
			if(OM.netnum != number)
				notlooped = 1
				break
		else if( istype(O, /obj/cable) )
			var/obj/net_cable/OC = O
			if(OC.netnum != number)
				notlooped = 1
				break

	if(notlooped)

		// not looped, so make a new nwnet

		var/datum/nwnet/PN = new()
		//PN.tag = "nwnet #[L]"
		nwnets += PN
		PN.number = nwnets.len

		if(Debug) world.log << "Was not looped: spliting PN#[number] ([cables.len];[nodes.len])"

		for(var/obj/net_cable/OC in cables)

			if(!OC.netnum)		// non-connected cables will have netnum==0, since they weren't reached by propagation

				OC.netnum = PN.number
				cables -= OC
				PN.cables += OC		// remove from old network & add to new one

		for(var/obj/machinery/network/OM in nodes)
			if(!OM.netnum)
				OM.netnum = PN.number
				OM.nwnet = PN
				nodes -= OM
				PN.nodes += OM		// same for power machines

		if(Debug)
			world.log << "Old PN#[number] : ([cables.len];[nodes.len])"
			world.log << "New PN#[PN.number] : ([PN.cables.len];[PN.nodes.len])"

	else
		if(Debug)
			world.log << "Was looped."
		//there is a loop, so nothing to be done
