// Any packet sent to #commdish will be received by all other comm dishes.
// The packet must be wrapped in a packet of the form:
// target=TARGET_ADDRESS&packet=WRAPPED_PACKET
// When received the packet will be unwrapped.

/obj/machinery/commdish
	icon_state = "commdish"
	icon = 'icons/immibis/network_device.dmi'
	name = "communications dish"

	tdns_name = "commdish"

	networked = 1

	receive_packet(sender, packet)
		spawn(rand(1,2))
			for(var/obj/machinery/commdish/D)
				if(D.nwnet != nwnet)
					packet = params2list(packet)
					if(!packet) packet = list()
					packet["comm-received"] = 1
					D.send_packet("#commserver", packet)

/obj/machinery/server/comms
	tdns_name = "commserver"

	name = "Communications server"

	var/online = 0
	var/dish_addr

	receive_tagged_packet(sender, packet, tag, dest)
		if(tag == "pong")
			online = 2
			dish_addr = sender
		else
			. = ..()

	receive_packet(sender, packet)
		packet = params2list(packet)
		if(!packet || !("comm-received" in packet))
			if(dish_addr)
				send_packet(dish_addr, packet)
			else
				send_packet(sender, list2params(list(action="comms-error",msg="no dish")))
			return
		if(sender == dish_addr)
			// do nothing
			return

	New()
		. = ..()
		spawn while(1)
			online--
			if(online <= 0) dish_addr = null
			send_packet("#commdish", "", "ping")
			sleep(10)
			online--
			sleep(90)

	get_status_line()
		return "[name] - [online ? "Connected to [dish_addr]" : "Not connected"]"

