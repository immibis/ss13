/obj/machinery/packet_sniffer
	icon = 'icons/immibis/network_device.dmi'
	icon_state = "sniffer"

	name = "packet sniffer"

	var/last_packet = "(none)"

	nw_promiscuous = 1
	networked = 1
	anchored = 1
	density = 0

	attack_hand(mob/user)
		add_fingerprint(user)
		user << "\blue NETWORK ADDRESS: [nw_address]"
		user << "\blue LAST PACKET RECEIVED: [sanitize(last_packet)]"

	receive_tagged_packet(sender, packet, tag, dest)
		if(dest)
			last_packet = "(from [sender] to [dest])"
		else
			last_packet = "(broadcast from [sender])"
		last_packet += " ([tag]) [packet]"
		for(var/mob/O in hearers(src, null))
			O.show_message("[src] states, \"[sanitize(last_packet)]\".", 2)
