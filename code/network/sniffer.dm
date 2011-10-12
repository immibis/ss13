/obj/machinery/network/sniffer
	icon = 'icons/immibis/network_device.dmi'
	icon_state = "sniffer"

	name = "packet sniffer"

	var/last_packet = "(none)"

	attack_hand(mob/user)
		add_fingerprint(user)
		user << "\blue NETWORK ADDRESS: [nw_address]"
		user << "\blue LAST PACKET RECEIVED: [sanitize(last_packet)]"

	receive_tagged_packet(list/packet, sender, tag)
		last_packet = "(from [sender]) ([tag]) [packet]"
		for(var/mob/O in hearers(src, null))
			O.show_message("[src] states, \"[sanitize(last_packet)]\".", 2)
