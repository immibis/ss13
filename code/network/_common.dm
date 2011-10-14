proc/random_network_address()
	var/chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	while(1)
		var/a = ""

		// generate a random 4-character address
		for(var/k in 1 to 4)
			var/pos = rand(1, lentext(chars))
			a += copytext(chars, pos, pos+1)

		// check nothing else is using it
		var/ok = 1
		for(var/obj/machinery/M)
			if(M.nw_address == a)
				ok = 0
				break

		// if nothing else is using this address, return it
		if(ok)
			return a


obj/machinery
	var/datum/nwnet/nwnet

	var/nw_address

	var/list/nw_tdns_cache = new

	var/tdns_name = null

	// if nonzero, this machine receives packets destined for other machines
	// in addition to packets destined for itself
	var/nw_promiscuous = 0

	var/networked = 0

	New()
		if(networked)
			nw_address = random_network_address()
		. = ..()

	// Packets can be strings or lists. Lists are converted to strings
	// when received. Use params2list to receive a list.

	// A tag is a short string describing the packet type for non-data packets - eg "ping"
	// This is always "data" for data packets.

	// If a destination starting with a # is given, it will
	// be resolved using ThinkDNS. If the address cannot be resolved the
	// packet is dropped, as it usually is if the destination doesn't exist.

	// You may set the tdns_name var to alter a machine's ThinkDNS name.

	// Multiple machines on a network may have the same ThinkDNS name.
	// In this case, any of them may be returned when resolving the name.
	// It will always resolve to the same one on each client, because of
	// the DNS cache, unless the DNS cache is flushed.

	proc/receive_packet(sender, packet)

	proc/receive_tagged_packet(sender, packet, tag, dest, datum/nwnet/net)
		if(tag == "data")
			receive_packet(sender, packet)
		else if(tag == "ping")
			var/list/L = new
			L["name"] = name
			if(tdns_name) L["tdns"] = tdns_name
			send_packet(sender, L, "pong")
		else if(tag == "tdns_announce")
			nw_tdns_cache[packet] = sender
		else if(tag == "tdns_request")
			if(packet == tdns_name)
				send_packet(sender, tdns_name, "tdns_announce")

	proc/nw_resolve_tdns(name)
		if(!(name in nw_tdns_cache))
			broadcast_packet(name, "tdns_request")
		if(name in nw_tdns_cache)
			return nw_tdns_cache[name]
		return null

	proc/nw_resolve_addr(addr)
		if(copytext(addr, 1, 2) == "#")
			return nw_resolve_tdns(copytext(addr, 2))
		return addr

	proc/send_packet(dest, packet, tag="data")
		if(!networked) CRASH("Cannot send packet from non-networked machine [src.type]")
		dest = nw_resolve_addr(dest)
		if(nwnet && dest)
			nwnet.send_packet(nw_address, packet, tag, dest)

	proc/broadcast_packet(packet, tag="data")
		if(!networked) CRASH("Cannot send packet from non-networked machine [src.type]")
		if(nwnet)
			nwnet.send_packet(nw_address, packet, tag, null)
