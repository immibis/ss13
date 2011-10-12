// This whole thing doesn't work and causes infinite loops. I might fix it later.

/*
datum/nw_routing
	filter
		// broadcast packets have a destination of *
		var/match // semicolon-separated list of network numbers/node addresses
		var/negate = 0 // 1/0
		var/field // "srcnet"/"src"/"dst"/"tag"

		proc/match(var/srcnet, var/src_, var/dst, var/tag)
			var/x = (field == "srcnet" ? srcnet : field == "src" ? src_ : field == "dst" ? dst : tag)
			var/L = split(";", match)
			if(x in L)
				return !negate
			else
				return negate
	action
		proc/perform(obj/machinery/nw_router/router, sender, packet, tag, dest)
		forward
			var/dstnet
			perform(obj/machinery/nw_router/router, sender, packet, tag, dest)
				var/datum/nwnet/net = router.nets[dstnet+1]
				net.send_packet(sender, packet, tag, dest)
	rule
		var/list/filters = new
		var/list/actions = new

obj/machinery/nw_router

	icon = 'icons/immibis/network_device.dmi'
	icon_state = "nuclear"

	var/list/nets = new
	var/list/rules = new

	networked = 1
	nw_promiscuous = 1
	anchored = 1
	density = 1

	New()
		. = ..()
		spawn
			for(var/d in list(NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST))
				var/d2 = turn(d, 180)
				for(var/obj/net_cable/C in get_step(loc, d))
					if(C.d1 == d2 || C.d2 == d2)
						if(C.nwnet in nets)
							continue
						nets += C.nwnet
						C.nwnet.nodes += src
		var/datum/nw_routing/rule/R
		var/datum/nw_routing/action/forward/AF
		var/datum/nw_routing/filter/F

		R = new
		AF = new
		AF.dstnet = 1
		R.actions += AF
		F = new
		F.match = "eth0"
		F.field = "srcnet"
		F.negate = 0
		R.filters += F
		rules += R

		R = new
		AF = new
		AF.dstnet = 0
		R.actions += AF
		F = new
		F.match = "eth1"
		F.field = "srcnet"
		F.negate = 0
		R.filters += F
		rules += R

	receive_packet(sender, packet)


	receive_tagged_packet(sender, packet, tag, dest, datum/nwnet/net)
		if(dest == nw_address)
			. = ..()
		else if(sender != nw_address)
			var/srcnet = "eth[nets.Find(net)-1]"
			world << srcnet
			for(var/datum/nw_routing/rule/R in rules)
				var/all_ok = 1
				for(var/datum/nw_routing/filter/F in R.filters)
					if(!F.match(srcnet, sender, dest ? dest : "*", tag))
						all_ok = 0
						break
				if(all_ok)
					for(var/datum/nw_routing/action/A in R.actions)
						A.perform(src, sender, packet, tag, dest)
*/