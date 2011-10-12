/datum/nwnet
	var/list/cables = new
	var/list/nodes = new

	var/list/propagate_queue = new

	proc/merge_into(datum/nwnet/N)
		N.cables += cables
		N.nodes += nodes
		for(var/obj/machinery/M in nodes)
			M.nwnet = N
		for(var/obj/net_cable/C in cables)
			C.nwnet = N
		del(src)

	proc/send_packet(sender, packet, tag, dest)
		if(istype(packet, /list))
			packet = list2params(packet)
		for(var/obj/machinery/N in nodes)
			if((!dest && N.nw_address != sender) || N.nw_address == dest || N.nw_promiscuous)
				N.receive_tagged_packet(sender, packet, tag, dest, src)

	proc/add_cable(obj/net_cable/C)
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
				if(M.networked)
					if(!(M in nodes))
						nodes += M
					M.nwnet = src

	proc/update_cable(obj/net_cable/C)
		propagate_queue += C
		propagate()

	proc/propagate()
		while(propagate_queue.len > 0)
			var/obj/net_cable/C = propagate_queue[1]
			propagate_queue -= C
			for(var/obj/net_cable/C2 in C.get_connections())
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
