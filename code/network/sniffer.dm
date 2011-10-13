/obj/machinery/packet_sniffer
	icon = 'icons/immibis/network_device.dmi'
	icon_state = "sniffer"

	name = "packet sniffer"

	var/last_packet = "(none)"

	parent_type = /obj/machinery/terminal

	nw_promiscuous = 1
	networked = 1
	anchored = 1
	density = 0

	var/tts_on = 0

	receive_tagged_packet(sender, packet, tag, dest)
		if(dest)
			last_packet = "(from [sender] to [dest])"
		else
			last_packet = "(broadcast from [sender])"
		last_packet += " ([tag]) [packet]"
		print(last_packet)
		if(tts_on)
			for(var/mob/O in hearers(src, null))
				O.show_message("[src] states, \"[sanitize(last_packet)]\".", 2)

	command(cmd, user)
		print(">[cmd]")
		if(cmd == "tts_on")
			print("Text-to-speech is now on.")
			tts_on = 1
		else if(cmd == "tts_off")
			print("Text-to-speech is now off.")
			tts_on = 0
		else if(cmd == "address")
			print("Address: [nw_address]")
		else if(cmd == "help")
			print("Recognized commands:")
			print(" tts_on - turns on text-to-speech")
			print(" tts_off - turns off text-to-speech")
			print(" help - displays this message")
			print(" address - displays the sniffer's address")
