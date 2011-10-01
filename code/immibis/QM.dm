/obj/crate
	var/state_open
	var/state_closed

	var/opened

	icon = 'icons/goonstation/obj/storage.dmi'
	icon_state = "crate"

	density = 1
	opacity = 0

	New()
		. = ..()
		state_closed = icon_state
		state_open = icon_state + "open"

	attack_hand(mob/user)
		add_fingerprint(user)
		interact(user)

	proc/interact(mob/user)
		if(opened)
			for(var/atom/movable/O in loc)
				O.Move(src)
			icon_state = state_closed
		else
			for(var/atom/movable/O in src)
				O.Move(loc)
			icon_state = state_open
		opened = !opened

/obj/crate/qm
	var/list/start_items = new
	var/locked = 0
	var/lockable = 0

	New()
		. = ..()
		for(var/path in start_items)
			var/atom/movable/O = new path()
			O.loc = src

	metal
		start_items = list(/obj/item/weapon/sheet/metal)
		name = "Metal Sheets Crate"
	glass
		start_items = list(/obj/item/weapon/sheet/glass)
		name = "Glass Sheets Crate"
	internals
		start_items = list(/obj/item/weapon/tank/oxygentank, /obj/item/weapon/tank/oxygentank, /obj/item/weapon/tank/oxygentank,
			/obj/item/weapon/clothing/mask/gasmask, /obj/item/weapon/clothing/mask/gasmask, /obj/item/weapon/clothing/mask/gasmask)
		name = "Internals Crate"
		icon_state = "o2crate"
	food
		start_items = list()
		name = "Food Crate"
	engineering
		start_items = list(/obj/item/weapon/storage/toolbox/mechanical, /obj/item/weapon/storage/toolbox/mechanical, /obj/item/weapon/storage/toolbox/mechanical,
			/obj/item/weapon/storage/toolbox/electrical, /obj/item/weapon/storage/toolbox/electrical, /obj/item/weapon/storage/toolbox/electrical,
			/obj/item/weapon/clothing/gloves/yellow, /obj/item/weapon/clothing/gloves/yellow, /obj/item/weapon/clothing/gloves/yellow)
		name = "Engineering Crate"
	medical
		name = "Medical Crate"
		icon_state = "medicalcrate"
	janitorial
		name = "Janitorial Crate"
	hydroponics
		name = "Hydroponics Crate"
	assembly
		name = "Plasma Assembly Crate"
		icon_state = "plasmacrate"
		locked = 1
		lockable = 1
	weapons
		icon_state = "weaponcrate"
		name = "Weapons Crate"
		locked = 1
		lockable = 1
	xp_weapons
		icon_state = "weaponcrate"
		name = "Experimental Weapons Crate"
		locked = 1
		lockable = 1
	emergency
		name = "Emergency Equipment Crate"
	party
		name = "Party Equipment Crate"
	robotics
		name = "Robotics Crate"
	spec_ops
		icon_state = "secgearcrate"
		name = "Spec Ops Crate"
		locked = 1
		lockable = 1



var/list/QM_crates = list(
	list("Empty crate", /obj/crate, 10),
	list("50 Metal Sheets", /obj/crate/qm/metal, 500),
	list("50 Glass Sheets", /obj/crate/qm/glass, 500),
	list("Internals", /obj/crate/qm/internals, 500),
	list("Food. NOT IMPLEMENTED", /obj/crate/qm/food, 250),
	list("Engineering", /obj/crate/qm/engineering, 1000),
	list("Medical. NOT IMPLEMENTED", /obj/crate/qm/medical, 1000),
	list("Janitorial. NOT IMPLEMENTED", /obj/crate/qm/janitorial, 500),
	//list("Hydroponics", /obj/crate/qm/hydroponics, 500),
	list("Plasma Assembly. NOT IMPLEMENTED", /obj/crate/qm/assembly, 500),
	list("Weapons. NOT IMPLEMENTED", /obj/crate/qm/weapons, 5000),
	list("Experimental Weapons. NOT IMPLEMENTED", /obj/crate/qm/xp_weapons, 2500),
	list("Emergency Equipment. NOT IMPLEMENTED", /obj/crate/qm/emergency, 1500),
	list("Party Equipment. NOT IMPLEMENTED", /obj/crate/qm/party, 300),
	list("Robotics. NOT IMPLEMENTED", /obj/crate/qm/robotics, 2000)
	//list("Spec Ops. NOT IMPLEMENTED", /obj/crate/qm/spec_ops, 2500)
)

/datum/qm_request
	var/requestor = "Unknown"
	var/item = "Empty"

var/datum/qm_request/QM_requests[] = new

/obj/machinery/terminal/computer/supply_request
	name = "Request console"
	New()
		. = ..()
		var/datum/os/thinkdos/td = os
		td.FS.root.put("RequestMaster", new/datum/fs_file(FILETYPE_PROG, /datum/comp_program/requestmaster))

/obj/machinery/terminal/computer/supply
	name = "Supply console"
	New()
		. = ..()
		var/datum/os/thinkdos/td = os
		td.FS.root.put("SupplyMaster", new/datum/fs_file(FILETYPE_PROG, /datum/comp_program/supplymaster))

var/const/QM_DOCK_ZLEVEL = 4

var/datum/shuttle/QM_shuttle = new
world/New()
	. = ..()
	spawn
		QM_shuttle.transit_zlevel = 3
		QM_shuttle.end_zlevel = 1
		QM_shuttle.area = /area/supply_shuttle
		QM_shuttle.cur_zlevel = QM_DOCK_ZLEVEL

/datum/comp_program/supplymaster
	start()
		term.print("Welcome to SupplyMaster, type 'help' for help.")

	var/approval_mode = 0
	var/datum/qm_request/approval_request = null

	command2(cmd, c_args)
		if(approval_mode)
			approval_cmd(cmd, c_args)
			return
		var/name = join(" ", c_args)
		if(cmd == "order")
			for(var/list/data in QM_crates)
				if(cmptext(data[1], name))
					order_crate(data)
					return
			term.print("No such crate: '[name]'")
		else if(cmd == "help")
			term.print("Current supply budget: $[supply_budget]")
			term.print("SupplyMaster commands:")
			term.print("  list")
			term.print("    shows a list of crates")
			term.print("  order CRATE NAME")
			term.print("    orders a crate")
			term.print("  orders")
			term.print("    shows current orders")
			term.print("  requests")
			term.print("    shows current requests")
			term.print("  approval")
			term.print("    enter request approval mode")
			term.print("  call")
			term.print("    calls the supply shuttle")
			term.print("  status")
			term.print("    shows status information")
			term.print("  quit")
			term.print("    quits the program")
		else if(cmd == "list")
			list_crates()
		else if(cmd == "orders")
			show_orders()
		else if(cmd == "requests")
			show_requests()
		else if(cmd == "approval")
			approval_start()
		else if(cmd == "call")
			call_shuttle()
		else if(cmd == "status")
			show_status()
		else if(cmd == "quit")
			quitprog()
		else
			term.print("Unknown command.")

	proc/order_crate(list/data)
		if(QM_shuttle.cur_zlevel != QM_DOCK_ZLEVEL)
			term.print("Must be at dock to order items.")
			return 0
		if(supply_budget < data[3])
			term.print("Insufficient funds.")
			return 0
		var/turf/simulated/shuttle/floor/T
		for(T in locate(QM_shuttle.area))
			if(T.z != QM_DOCK_ZLEVEL)
				continue
			if(T.isempty())
				supply_budget -= data[3]
				var/crate_path = data[2]
				var/obj/crate/crate = new crate_path()
				crate.loc = T
				break
		if(!T)
			term.print("Shuttle is full.")
			return 0
		term.print("Crate ordered.")
		term.print("Supply budget is now $[supply_budget]")
		return 1

	proc/approval_start()
		approval_mode = 1
		approval_next()
	proc/approval_stop()
		approval_request = null
		approval_mode = 0
		term.print("Exited approval mode.")

	proc/approval_next()
		if(QM_requests.len == 0)
			term.print("No requests left.")
			approval_stop()
			return
		approval_request = QM_requests[1]
		term.print("[approval_request.item] requested by [approval_request.requestor]")
		term.print("Accept, reject, skip or exit? ([QM_requests.len] item\s remaining)")
	proc/approval_cmd(cmd, c_args)
		if(cmd == "accept")
			for(var/list/data in QM_crates)
				if(cmptext(data[1], approval_request.item))
					if(order_crate(data))
						QM_requests -= approval_request
						term.print("Request accepted.")
						// todo: notify the requestor somehow?
					else
						term.print("Error ordering item.")
					approval_next()
					return
			term.print("No such crate: '[approval_request.item]'")
			QM_requests -= approval_request
			approval_next()
		else if(cmd == "reject")
			QM_requests -= approval_request
			term.print("Request rejected.")
			approval_next()
			// todo: notify the requestor somehow?
		else if(cmd == "skip")
			QM_requests -= approval_request
			QM_requests += approval_request
			term.print("Request moved to end of queue.")
			approval_next()
		else if(cmd == "exit")
			approval_stop()
		else
			term.print("Unknown command.")
			term.print("[approval_request.item] requested by [approval_request.requestor]")
			term.print("Accept, reject, skip or exit? ([QM_requests.len] item\s remaining)")

	proc/list_crates()
		for(var/list/data in QM_crates)
			term.print("[data[1]]: $[data[3]]")

	proc/call_shuttle()
		spawn
			QM_shuttle.take_off()
		term.print("Shuttle called.")

	proc/show_orders()

	proc/show_requests()
		for(var/datum/qm_request/R in QM_requests)
			term.print("[R.item] requested by [R.requestor]")
		if(QM_requests.len == 0)
			term.print("No current requests")

	proc/show_status()
		if(QM_shuttle.cur_zlevel == QM_DOCK_ZLEVEL)
			term.print("Shuttle is at dock.")
		else if(QM_shuttle.cur_zlevel == 1)
			term.print("Shuttle is at station.")
		else
			term.print("Shuttle is moving.")
		term.print("Supply budget: $[supply_budget]")

/datum/comp_program/requestmaster
	command2(cmd, c_args)
		var/name = join(" ", c_args)
		if(cmd == "help")
			term.print("Current supply budget: $[supply_budget]")
			term.print("RequestMaster commands:")
			term.print("  list")
			term.print("    shows a list of crates")
			term.print("  request CRATE NAME")
			term.print("    orders a crate")
			term.print("  requests")
			term.print("    shows current requests")
			term.print("  status")
			term.print("    shows status information")
			term.print("  quit")
			term.print("    quits the program")
		else if(cmd == "list")
			list_crates()
		else if(cmd == "request")
			for(var/list/data in QM_crates)
				if(cmptext(data[1], name))
					request_crate(data)
					return
			term.print("No such crate: '[name]'")
		else if(cmd == "requests")
			show_requests()
		else if(cmd == "status")
			show_status()
		else if(cmd == "quit")
			term.print("Now quitting RequestMaster. Remember to logout!")
			quitprog()
		else
			term.print("Unknown command")

	start()
		var/datum/os/thinkdos/td = os
		if(!td.login_name)
			term.print("Please log in before starting RequestMaster.")
			quitprog()
		else
			term.print("Welcome to RequestMaster, type 'help' for help.")

	proc/list_crates()
		for(var/list/data in QM_crates)
			term.print("[data[1]]: $[data[3]]")

	proc/show_requests()
		for(var/datum/qm_request/R in QM_requests)
			term.print("[R.item] requested by [R.requestor]")
		if(QM_requests.len == 0)
			term.print("No current requests")

	proc/request_crate(data)
		var/datum/os/thinkdos/td = os
		var/datum/qm_request/R = new
		R.item = data[1]
		R.requestor = td.login_name
		QM_requests += R
		term.print("Request placed.")
		// TODO: Notify QM's somehow?

	proc/show_status()
		if(QM_shuttle.cur_zlevel == QM_DOCK_ZLEVEL)
			term.print("Shuttle is at dock.")
		else if(QM_shuttle.cur_zlevel == 1)
			term.print("Shuttle is at station.")
		else
			term.print("Shuttle is moving.")
		term.print("Supply budget: $[supply_budget]")

/area/supply_shuttle
	name = "Supply shuttle"
