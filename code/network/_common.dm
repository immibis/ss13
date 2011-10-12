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
		for(var/obj/machinery/network/M)
			if(M.nw_address == a)
				ok = 0
				break

		// if nothing else is using this address, return it
		if(ok)
			return a


obj/machinery/network
	var/datum/nwnet/nwnet

	var/nw_address

	anchored = 1
	density = 1

	New()
		nw_address = random_network_address()
		. = ..()

	// Packets can be strings or lists. Lists are converted to strings
	// when received. Use params2list to receive a list.

	// A tag is a short string describing the packet type for non-data packets - eg "ping"
	// This is always "data" for data packets.

	proc/receive_packet(packet, sender)

	proc/receive_tagged_packet(packet, sender, tag)
		if(tag == "data")
			receive_packet(packet)
		else if(tag == "ping")
			send_packet(sender, nw_address, "pong")

	proc/send_packet(dest, packet, tag="data")
		if(nwnet)
			if(istype(packet, /list))
				packet = list2params(packet)
			for(var/obj/machinery/network/N in nwnet.nodes)
				if(N.nw_address == dest)
					N.receive_tagged_packet(packet, nw_address, tag)

	proc/broadcast_packet(packet, tag="data")
		if(nwnet)
			if(istype(packet, /list))
				packet = list2params(packet)
			for(var/obj/machinery/network/N in nwnet.nodes)
				N.receive_tagged_packet(packet, nw_address, tag)
