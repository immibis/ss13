/datum/generic_network
	var/list/cables = new
	var/list/nodes = new

	var/list/propagate_queue = new

	// OVERRIDE THESE
	var/cable_type
	proc/add_machine(obj/machinery/M)
	proc/check_machine(obj/machinery/M)
	proc/add_cable(obj/generic_cable/C)

	// Example:
	// cable_type = /obj/net_cable
	// check_machine(obj/machinery/M)
	//		return M.networked
	// add_machine(obj/machinery/M)
	//		M.nwnet = src
	// add_cable(obj/net_cable/C)
	//		C.nwnet = src

	proc/merge_into(datum/generic_network/N)
		if(type != N.type) CRASH("/datum/generic_network/merge_into: Merging two unrelated networks")
		N.cables += cables
		N.nodes += nodes
		for(var/obj/machinery/M in nodes)
			M.nwnet = N
		for(var/obj/generic_cable/C in cables)
			C.nwnet = N
		del(src)

	proc/add_cable(obj/generic_cable/C)
		ASSERT(C.type == cable_type)
		if(C.nwnet == src)
			return
		if(C.nwnet)
			C.nwnet.merge_into(src)
			return
		cables += C
		C.nwnet = src
		propagate_queue += C
		if(!C.d1)
			for(var/obj/machinery/M in C.loc)
				if(check_machine(M))
					if(!(M in nodes))
						nodes += M
					add_machine(M)

	proc/update_cable(obj/generic_cable/C)
		propagate_queue += C
		propagate()

	proc/propagate()
		while(propagate_queue.len > 0)
			var/obj/net_cable/C = propagate_queue[1]
			propagate_queue -= C
			for(var/obj/generic_cable/C2 in C.get_connections())
				if(C2.type != cable_type)
					continue
				add_cable(C2)

	proc/cut_cable(obj/net_cable/C)
		// TODO
		world << "\red Note: Immibis was lazy and didn't implement /datum/nwnet/cut_cable. Cutting the cables will do nothing useful. Except for giving you more cables. I suggest you spam Immibis until he fixes it."


/proc/makenwnets()

	nwnets = list()

	for(var/obj/net_cable/C)
		C.nwnet = null
	for(var/obj/machinery/M)
		M.nwnet = null

	for(var/obj/net_cable/C)
		if(!C.nwnet)
			var/datum/nwnet/net = new
			net.add_cable(C)
			net.propagate()

world/New()
	. = ..()
	makenwnets()
