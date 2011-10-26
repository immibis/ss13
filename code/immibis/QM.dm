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

	metal_50
		start_items = list(/obj/item/weapon/sheet/metal)
		name = "50 Metal Sheets"
	metal_100
		start_items = list(/obj/item/weapon/sheet/metal,/obj/item/weapon/sheet/metal)
		name = "100 Metal Sheets"
	metal_200
		start_items = list(/obj/item/weapon/sheet/metal,/obj/item/weapon/sheet/metal,/obj/item/weapon/sheet/metal,/obj/item/weapon/sheet/metal)
		name = "200 Metal Sheets"
	glass_50
		start_items = list(/obj/item/weapon/sheet/glass)
		name = "50 Glass Sheets"
	glass_100
		start_items = list(/obj/item/weapon/sheet/glass,/obj/item/weapon/sheet/glass)
		name = "100 Glass Sheets"
	glass_200
		start_items = list(/obj/item/weapon/sheet/glass,/obj/item/weapon/sheet/glass,/obj/item/weapon/sheet/glass,/obj/item/weapon/sheet/glass)
		name = "200 Glass Sheets"
	internals
		start_items = list(
			/obj/item/weapon/tank/oxygentank,
			/obj/item/weapon/tank/oxygentank,
			/obj/item/weapon/tank/oxygentank,
			/obj/item/weapon/clothing/mask/gasmask,
			/obj/item/weapon/clothing/mask/gasmask,
			/obj/item/weapon/clothing/mask/gasmask)
		name = "Internals Crate"
		icon_state = "o2crate"
	engineering
		start_items = list(
			/obj/item/weapon/storage/toolbox/mechanical,
			/obj/item/weapon/storage/toolbox/mechanical,
			/obj/item/weapon/storage/toolbox/mechanical,
			/obj/item/weapon/storage/toolbox/electrical,
			/obj/item/weapon/storage/toolbox/electrical,
			/obj/item/weapon/storage/toolbox/electrical,
			/obj/item/weapon/clothing/gloves/yellow,
			/obj/item/weapon/clothing/gloves/yellow,
			/obj/item/weapon/clothing/gloves/yellow)
		name = "Engineering Crate"
	medical
		name = "Medical Crate"
		icon_state = "medicalcrate"
		start_items = list(
			/obj/item/weapon/reagent/bottle/sleep_toxin,
			/obj/item/weapon/reagent/bottle/sleep_toxin,
			/obj/item/weapon/reagent/bottle/sleep_toxin,
			/obj/item/weapon/reagent/bottle/inaprovaline,
			/obj/item/weapon/reagent/bottle/inaprovaline,
			/obj/item/weapon/reagent/bottle/inaprovaline,
			/obj/item/weapon/reagent/bottle/antitoxin,
			/obj/item/weapon/reagent/bottle/antitoxin,
			/obj/item/weapon/reagent/bottle/antitoxin,
			/obj/item/weapon/storage/syringe,
			/obj/item/weapon/storage/firstaid/fire,
			/obj/item/weapon/storage/firstaid/toxin,
			/obj/item/weapon/storage/firstaid/regular)

	food
		name = "Food Crate"
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
		start_items = list(/obj/item/weapon/tank/oxygentank, /obj/item/weapon/tank/oxygentank, /obj/item/weapon/tank/oxygentank,
			/obj/item/weapon/clothing/mask/gasmask, /obj/item/weapon/clothing/mask/gasmask, /obj/item/weapon/clothing/mask/gasmask,
			/*  /obj/aibot/floorbot*/)
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
	list("50 Metal Sheets", /obj/crate/qm/metal_50, 500),
	list("100 Metal Sheets", /obj/crate/qm/metal_100, 1000),
	list("200 Metal Sheets", /obj/crate/qm/metal_200, 2000),
	list("50 Glass Sheets", /obj/crate/qm/glass_50, 500),
	list("100 Glass Sheets", /obj/crate/qm/glass_100, 1000),
	list("200 Glass Sheets", /obj/crate/qm/glass_200, 2000),
	list("Internals", /obj/crate/qm/internals, 500),
	list("Food. NOT IMPLEMENTED", /obj/crate/qm/food, 250),
	list("Engineering", /obj/crate/qm/engineering, 1000),
	list("Medical", /obj/crate/qm/medical, 1000),
	list("Janitorial. NOT IMPLEMENTED", /obj/crate/qm/janitorial, 500),
	list("Hydroponics. NOT IMPLEMENTED", /obj/crate/qm/hydroponics, 500),
	list("Plasma Assembly. NOT IMPLEMENTED", /obj/crate/qm/assembly, 500),
	list("Weapons. NOT IMPLEMENTED", /obj/crate/qm/weapons, 5000),
	list("Experimental Weapons. NOT IMPLEMENTED", /obj/crate/qm/xp_weapons, 2500),
	list("Emergency Equipment. NOT IMPLEMENTED", /obj/crate/qm/emergency, 1500),
	list("Party Equipment. NOT IMPLEMENTED", /obj/crate/qm/party, 300),
	list("Robotics. NOT IMPLEMENTED", /obj/crate/qm/robotics, 2000)

	// should require emagging
	//list("Spec Ops. NOT IMPLEMENTED", /obj/crate/qm/spec_ops, 2500)
)

/datum/qm_request
	var/requestor = "Unknown"
	var/item = "Empty"

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

	proc/order_crate(name)
		begin_packet_wait("confirm-order")
		term.send_packet("#qmserver", list(action = "order", item = name))
		var/list/p = wait_for_packet()
		if(!p)
			term.print("Server is not responding.")
			return 0
		else
			term.print(p["msg"])
			if("success" in p)
				term.print("Supply budget is now $[supply_budget]")
				return 1
			return 0

	command2(cmd, c_args)
		if(approval_mode)
			approval_cmd(cmd, c_args)
			return
		var/name = join(" ", c_args)
		if(cmd == "order")
			order_crate(name)
		else if(cmd == "help")
			term.print("Current supply budget: $[supply_budget]")
			term.print("SupplyMaster commands:")
			term.print("  list")
			term.print("    shows a list of crates")
			term.print("  order CRATE NAME")
			term.print("    orders a crate")
//			term.print("  orders")
//			term.print("    shows current orders")
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
//		else if(cmd == "orders")
//			show_orders()
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

	proc/approval_start()
		approval_mode = 1
		approval_next()
	proc/approval_stop()
		approval_request = null
		approval_mode = 0
		term.print("Exited approval mode.")

	proc/approval_next()
		begin_packet_wait("approval-next")
		term.send_packet("#qmserver", list(action = "approval-pull"))
		var/list/p = wait_for_packet()
		if(!p)
			term.print("Server is not responding.")
			approval_stop()
			return
		if(!("item" in p))
			term.print("No requests left.")
			approval_stop()
			return
		approval_request = new
		approval_request.item = p["item"]
		approval_request.requestor = p["requestor"]
		term.print("[approval_request.item] requested by [approval_request.requestor]")
		term.print("Accept, reject, skip or exit? ([text2num(p["remaining"])] item\s remaining)")

	proc/approval_cmd(cmd, c_args)
		if(cmd == "accept")
			if(order_crate(approval_request.item))
				begin_packet_wait("confirm-remove")
				term.send_packet("#qmserver", list(action = "remove-request", item = approval_request.item, requestor = approval_request.requestor))
				if(!wait_for_packet())
					term.print("Server is not responding.")
				else
					term.print("Request accepted.")
				// todo: notify the requestor somehow?
			else
				term.print("Error ordering item.")
			approval_next()
		else if(cmd == "reject")
			begin_packet_wait("confirm-remove")
			term.send_packet("#qmserver", list(action = "remove-request", item = approval_request.item, requestor = approval_request.requestor))
			if(!wait_for_packet())
				term.print("Server is not responding.")
			else
				term.print("Request rejected.")
			approval_next()
			// todo: notify the requestor somehow?
		else if(cmd == "skip")
			begin_packet_wait("confirm-remove")
			term.send_packet("#qmserver", list(action = "remove-request", item = approval_request.item, requestor = approval_request.requestor))
			if(!wait_for_packet())
				term.print("Server is not responding.")
			else
				begin_packet_wait("confirm-request")
				term.send_packet("#qmserver", list(action = "request", item = approval_request.item, requestor = approval_request.requestor))
				if(!wait_for_packet())
					term.print("Server is not responding.")
				else
					term.print("Request moved to end of queue.")
			approval_next()
		else if(cmd == "exit")
			approval_stop()
		else
			term.print("Unknown command.")
			term.print("[approval_request.item] requested by [approval_request.requestor]")
			term.print("Accept, reject, skip or exit?")

	proc/list_crates()
		for(var/list/data in QM_crates)
			term.print("[data[1]]: $[data[3]]")

	proc/call_shuttle()
		spawn
			QM_shuttle.take_off()
		term.print("Shuttle called.")

//	proc/show_orders()

	var/waiting_for_packet = 0
	var/waiting_for_action = ""
	var/waited_for_packet = null

	proc/begin_packet_wait(action)
		waiting_for_packet = 1
		waiting_for_action = action

	proc/wait_for_packet()
		for(var/k = 1 to 30)
			if(!waiting_for_packet)
				return waited_for_packet
			sleep(1)
		waiting_for_packet = 0
		return null

	receive_packet(sender, packet)
		packet = params2list(packet)
		if(packet == null)
			return
		if(waiting_for_packet && waiting_for_action == packet["action"])
			waited_for_packet = packet
			waiting_for_packet = 0
		switch(packet["action"])
			if("request-list-item")
				term.print("[packet["item"]] requested by [packet["requestor"]]")
			if("request-list-empty")
				term.print("No current requests")

	proc/show_requests()
		begin_packet_wait("request-list-end")
		term.send_packet("#qmserver", list(action = "list-requests"))
		if(!wait_for_packet())
			term.print("Server is not responding.")

	proc/show_status()
		if(QM_shuttle.cur_zlevel == QM_DOCK_ZLEVEL)
			term.print("Shuttle is at dock.")
		else if(QM_shuttle.cur_zlevel == 1)
			term.print("Shuttle is at station.")
		else
			term.print("Shuttle is moving.")
		term.print("Supply budget: $[supply_budget]")

/obj/machinery/server/QM
	name = "QM server"
	tdns_name = "qmserver"

	var/datum/qm_request/QM_requests[] = new

	proc/order_crate(sender, list/data)
		if(QM_shuttle.cur_zlevel != QM_DOCK_ZLEVEL)
			send_packet(sender, list(action = "confirm-order", msg = "Must be at dock to order items."))
			return
		if(supply_budget < data[3])
			send_packet(sender, list(action = "confirm-order", msg = "Insufficient funds."))
			return
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
			send_packet(sender, list(action = "confirm-order", msg = "Shuttle is full."))
			return
		send_packet(sender, list(action = "confirm-order", msg = "Crate ordered.", success=1))

	receive_packet(sender, packet)
		packet = params2list(packet)
		if(packet == null)
			return
		switch(packet["action"])
			if("request")
				var/datum/qm_request/R = new
				R.item = packet["item"]
				R.requestor = packet["requestor"]
				if(!R.item || !R.requestor)
					return
				QM_requests += R
				send_packet(sender, list(action = "confirm-request"))
			if("list-requests")
				for(var/datum/qm_request/R in QM_requests)
					send_packet(sender, list(action = "request-list-item", item = R.item, requestor = R.requestor))
				if(QM_requests.len == 0)
					send_packet(sender, list(action = "request-list-empty"))
				send_packet(sender, list(action = "request-list-end"))
			if("order")
				var/name = packet["item"]
				for(var/list/data in QM_crates)
					if(cmptext(data[1], name))
						order_crate(sender, data)
						return
				send_packet(sender, list(action = "confirm-order", msg = "No such crate: '[name]'"))
			if("remove-request")
				for(var/datum/qm_request/k in QM_requests)
					if(k.item == packet["item"] && k.requestor == packet["requestor"])
						QM_requests -= k
				send_packet(sender, list(action = "confirm-remove"))
			if("approval-pull")
				if(QM_requests.len == 0)
					send_packet(sender, list(action = "approval-next"))
				else
					var/datum/qm_request/R = QM_requests[1]
					send_packet(sender, list(action = "approval-next", item = R.item, requestor = R.requestor, remaining = QM_requests.len - 1))

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

	var/waiting_for_packet = 0
	var/waiting_for_action = ""
	var/waited_for_packet = null

	proc/begin_packet_wait(action)
		waiting_for_packet = 1
		waiting_for_action = action

	proc/wait_for_packet()
		for(var/k = 1 to 30)
			if(!waiting_for_packet)
				return waited_for_packet
			sleep(1)
		waiting_for_packet = 0
		return null

	receive_packet(sender, packet)
		packet = params2list(packet)
		if(packet == null)
			return
		if(waiting_for_packet && waiting_for_action == packet["action"])
			waited_for_packet = packet
			waiting_for_packet = 0
		switch(packet["action"])
			if("request-list-item")
				term.print("[packet["item"]] requested by [packet["requestor"]]")
			if("request-list-empty")
				term.print("No current requests")

	proc/list_crates()
		for(var/list/data in QM_crates)
			term.print("[data[1]]: $[data[3]]")

	proc/show_requests()
		begin_packet_wait("request-list-end")
		term.send_packet("#qmserver", list(action = "list-requests"))
		if(!wait_for_packet())
			term.print("Server is not responding.")

	proc/request_crate(data)
		var/datum/os/thinkdos/td = os
		begin_packet_wait("confirm-request")
		term.send_packet("#qmserver", list(action = "request", item = data[1], requestor = td.login_name))
		if(wait_for_packet())
			term.print("Request placed.")
		else
			term.print("Server is not responding.")
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
	requires_power = 0
