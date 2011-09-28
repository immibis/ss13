datum/os
	var/obj/machinery/terminal/term

	proc/boot()
	proc/unboot() // apparently "shutdown" is a reserved word...
	proc/command(cmd)

	// can be called from a program to return to the OS
	proc/quitprog()