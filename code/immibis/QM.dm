/obj/crate
	var/state_open
	var/state_closed

	icon_state = "crate"

	New()
		. = ..()
		state_closed = icon_state
		state_open = icon_state + "open"

	attack_hand(mob/user)
		add_fingerprint(user)
		interact(user)

	proc/interact(mob/user)


/obj/machinery/terminal/computer/supply
	New()
		. = ..()
		var/datum/os/thinkdos/td = os
		td.FS.root.contents["SupplyMaster"] = /datum/comp_program/supplymaster

/datum/comp_program/supplymaster
	start()
		term.print("Welcome to SupplyMaster!")

	command(cmd)
