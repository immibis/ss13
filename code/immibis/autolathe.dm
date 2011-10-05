var/list/autolathe_items = list(
	list("Wirecutters", 80, 0, /obj/item/weapon/wirecutters),
	list("Wrench", 150, 0, /obj/item/weapon/wrench),
	list("Crowbar", 50, 0, /obj/item/weapon/crowbar),
	list("Welder", 30, 30, /obj/item/weapon/weldingtool),
	list("Welding helmet", 3000, 1000),
	list("Multitool", 50, 20, /obj/item/weapon/multitool),
	list("Flashlight", 50, 20, /obj/item/weapon/flashlight),
	list("Fire extinguisher", 90, 0, /obj/item/weapon/extinguisher),
	list("Metal", 3750, 0),
	list("Glass", 3750, 0),
	list("Reinforced metal", 7500, 0),
	list("Reinforced glass", 1875, 3750),
	list("Rods", 1875, 0),
	list("Compressed matter cartridge", 30000, 15000),
	list("Scalpel", 10000, 5000, ),
	list("Circular saw", 20000, 10000),
	list("T-ray scanner", 150, 0, /obj/item/weapon/t_scanner)
)

obj/machinery/autolathe
	icon = 'icons/goonstation/obj/stationobjs.dmi'
	icon_state = "autolathe"

	var/metal = 0
	var/glass = 0

	var/busy = 0

	attack_hand(mob/user)
		add_fingerprint(user)
		interact(user)

	attack_ai(mob/user)
		add_fingerprint(user)
		interact(user)

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		add_fingerprint(user)
		var/obj/item/weapon/sheet/S = W
		if(istype(W, /obj/item/weapon/sheet/metal))
			metal += 3750 * S.amount
		else if(istype(W, /obj/item/weapon/sheet/glass))
			glass += 3750 * S.amount
		else if(istype(W, /obj/item/weapon/sheet/r_metal))
			metal += 7500 * S.amount
		else if(istype(W, /obj/item/weapon/sheet/rglass))
			metal += 1875 * S.amount
			glass += 3750 * S.amount
		else
			return ..()
		view() << "\red [user] loads the [W.name] into the autolathe"
		del(W)

	proc/interact(mob/user)
		var/html
		user.machine = src
		if(busy)
			html = "The autolathe is currently busy."
		else
			html = "Metal: [metal] cc<br>"
			html += "Glass: [glass] cc<br><br>"
			for(var/list/item in autolathe_items)
				if(item.len == 4)
					html += "<a href=\"?src=\ref[src];item=\ref[item]\">[item[1]]</a> ([item[2]] cc metal, [item[3]] cc glass)<br>"
				else
					html += "[item[1]] ([item[2]] cc metal, [item[3]] cc glass) (BROKEN)<br>"
		user << browse(html, "window=autolathe")

	Topic(href, href_list)
		var/list/item_data = locate(href_list["item"])
		if(!item_data || item_data.len != 4)
			return
		if(metal < item_data[2] || glass < item_data[3])
			usr << "Not enough raw material."
		else
			var/path = item_data[4]
			metal -= item_data[2]
			glass -= item_data[3]
			busy = 1
			flick("autolathe_c", src)
			icon_state = "autolathe1"
			spawn(34)
				flick("autolathe_o", src)
				spawn(16)
					icon_state = "autolathe"
					busy = 0
					new path(loc)
					UpdateInteraction(src)
		UpdateInteraction(src)