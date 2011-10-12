obj/machinery/terminal/network
	icon = 'icons/immibis/network_device.dmi'
	icon_state = "terminal"
	name = "network terminal"

	var/connected = null

	networked = 1

	receive_tagged_packet(sender, packet, tag, dest)
		if(tag == "pong")
			print("Ping response from [sender] ([packet == "" ? "no data given" : packet])")
		else
			. = ..()

	receive_packet(sender, packet)
		if(sender != connected)
			print("(unexpected packet from [sender]) [packet]")
		else
			print("][packet]")

	command(cmd, user)
		print(">[cmd]")

		var/list/c_args = split(" ", cmd)
		var/cmd2 = c_args[1]
		c_args.Cut(1,2)

		if(cmd2 == "term_ping")
			if(c_args.len == 0)
				broadcast_packet("", "ping")
			else
				send_packet(c_args[1], "", "ping")
		else if(cmd2 == "disconnect")
			if(connected)
				connected = null
				print("Disconnected.")
			else
				print("You're not connected.")
		else if(cmd2 == "connect")
			if(connected)
				print("You're already connected.")
			else if(c_args.len == 0)
				print("Connect to what?")
			else
				connected = c_args[1]
				print("Connected to [connected]")
		else if(connected)
			send_packet(connected, cmd)
		else
			print("You need to connect first.")
