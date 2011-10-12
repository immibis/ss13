/datum/comp_program
	var
		obj/machinery/terminal/term
		datum/os/os

	proc/quitprog()
		os.quitprog()

	// override these
	proc/start()
	proc/crash() // called when the program is forcibly shut down

	// either override command or command2, depending on whether you
	// want the parsing or not
	proc/command2(cmd, c_args)
	proc/command(cmd)
		var/list/c_args = split(" ", cmd)
		cmd = c_args[1]
		c_args.Cut(1,2)
		command2(cmd, c_args)

	proc/receive_packet(sender, packet)