/obj/machinery/network/server_rack
	icon = 'icons/immibis/network_device.dmi'
	icon_state = "rack-preview"

	name = "server rack"

	// these are set to paths in the map
	// New() turns them into objects
	var/obj/machinery/network/server
		slot1
		slot2
		slot3
		slot4
		slot5

	proc/init_server(path)
		var/obj/machinery/network/server/obj = new path
		obj.rack = src
		obj.loc = src
		return obj

	New()
		. = ..()
		icon_state = "rack-under"
		if(slot1) slot1 = init_server(slot1)
		if(slot2) slot2 = init_server(slot2)
		if(slot3) slot3 = init_server(slot3)
		if(slot4) slot4 = init_server(slot4)
		if(slot5) slot5 = init_server(slot5)
		updateicon()

	attackby(obj/item/weapon/network_server/item, mob/user)
		add_fingerprint(user)
		if(istype(item))
			var/obj/machinery/network/server/S = item.server
			if(!slot1) slot1 = S
			else if(!slot2) slot2 = S
			else if(!slot3) slot3 = S
			else if(!slot4) slot4 = S
			else if(!slot5) slot5 = S
			else
				user << "There's no room in the server rack to put this."
				return
			del(item)
			S.Move(src)
			S.rack = src
			updateicon()
			for(var/mob/M)
				if(M.machine == src)
					if(istype(M, /mob/ai))
						attack_ai(M)
					else if(istype(M, /mob/human))
						attack_hand(M)

	attack_ai(mob/user)
		add_fingerprint(user)
		user << browse(get_interact_html(1), "window=server-rack")
		user.machine = src

	attack_hand(mob/user)
		add_fingerprint(user)
		user << browse(get_interact_html(0), "window=server-rack")
		user.machine = src

	proc/get_status_line(obj/machinery/network/server/server, is_ai)
		if(!server)
			return "empty"
		var/a = server.get_status_line()
		if(!is_ai)
			a += " <a href=\"?src=\ref[src]&eject=\ref[server]\">Eject</a>"
		return a

	Topic(href, href_list[])
		if("eject" in href_list)
			var/obj/machinery/network/server/S = locate(href_list["eject"])
			if(S.loc != src)
				return
			var/obj/item/weapon/network_server/I = new(src.loc, S)
			S.rack = null
			S.Move(I)
			if(slot1 == S) slot1 = null
			if(slot2 == S) slot2 = null
			if(slot3 == S) slot3 = null
			if(slot4 == S) slot4 = null
			if(slot5 == S) slot5 = null
			updateicon()
			for(var/mob/M)
				if(M.machine == src)
					if(istype(M, /mob/ai))
						attack_ai(M)
					else if(istype(M, /mob/human))
						attack_hand(M)
		else
			. = ..()

	proc/get_interact_html(is_ai)
		var/html = "<pre>ThinkTronic Server Rack Monitoring Interface\n"
		html += "Network Status: [nwnet ? "connected" : "disconnected"]\n"
		html += "\n"
		html += "Slot 1: [get_status_line(slot1, is_ai)]\n"
		html += "Slot 2: [get_status_line(slot2, is_ai)]\n"
		html += "Slot 3: [get_status_line(slot3, is_ai)]\n"
		html += "Slot 4: [get_status_line(slot4, is_ai)]\n"
		html += "Slot 5: [get_status_line(slot5, is_ai)]\n"
		html += "</pre>"
		return html


	proc/updateicon()
		if(slot1) slot1.pixel_y = 10
		if(slot2) slot2.pixel_y = 5
		if(slot3) slot3.pixel_y = 0
		if(slot4) slot4.pixel_y = -5
		if(slot5) slot5.pixel_y = -10
		overlays = null
		if(slot1) overlays += slot1
		if(slot2) overlays += slot2
		if(slot3) overlays += slot3
		if(slot4) overlays += slot4
		if(slot5) overlays += slot5
		overlays += image(icon='icons/immibis/network_device.dmi', icon_state="rack-over", layer=OBJ_LAYER+0.1)

/obj/machinery/network/server
	var/obj/machinery/network/server_rack/rack = null

	icon = 'icons/immibis/network_device.dmi'
	icon_state = "server"

	name = "server"

	proc/get_status_line()
		return "[name] - online"

	QM
		name = "QM server"

/obj/item/weapon/network_server
	var/obj/machinery/network/server/server = null

	// replaced by the actual server's icon and name when New is called
	icon = 'icons/immibis/network_device.dmi'
	icon_state = "server0"
	name = "server"

	Del()
		if(server)
			server.Move(src.loc)
		. = ..()

	pixel_y = 2

	New(loc, obj/machinery/network/server/server)
		src.server = server
		if(server)
			src.icon = server.icon
			src.icon_state = "[server.icon_state]0"
			src.name = server.name
		. = ..(loc)