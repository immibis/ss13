/datum/comp_program
	var
		obj/machinery/terminal/term
		datum/os/os

	// override these
	proc/start()
	proc/command(cmd)
	proc/crash() // called when the program is forcibly shut down