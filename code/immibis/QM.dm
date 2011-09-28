/obj/crate
	var/state_open
	var/state_closed

	var/opened

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
	list("Empty", /obj/crate, 10),
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

/obj/machinery/terminal/computer/supply
	name = "Supply console"
	New()
		. = ..()
		var/datum/os/thinkdos/td = os
		td.FS.root.contents["SupplyMaster"] = /datum/comp_program/supplymaster

/datum/comp_program/supplymaster
	start()
		term.print("Welcome to SupplyMaster!")

	command(cmd)
