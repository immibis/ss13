datum/os
	var/obj/machinery/terminal/term

	proc/boot()
	proc/unboot() // apparently "shutdown" is a reserved word...
	proc/command(cmd, user)

	// can be called from a program to return to the OS
	proc/quitprog()

	proc/receive_packet(sender, packet)