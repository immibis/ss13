/turf/simulated/wall/false_rwall
	name = "r wall"
	icon = 'icons/ss13/Doorf.dmi'
	icon_state = "rdoor1"
	var/operating = null
	var/visible = 1
	var/floorname
	var/floorintact
	var/floorhealth
	var/floorburnt
	var/icon/flooricon
	var/flooricon_state
	var/const/delay = 15
	var/const/prob_opens = 25
	var/list/known_by = list()

/turf/simulated/wall/false_rwall/New()
	..()
	//Hide the wires or whatever THE FUCK
	src.levelupdate()
	spawn(10)	// so that if it's getting created by the map it works, and if it isn't this will just return
		src.setFloorUnderlay('icons/ss13/Icons.dmi', "Floor1", 0, 100, 0, "floor")

/turf/simulated/wall/false_rwall/proc/setFloorUnderlay(FloorIcon, FloorIcon_State, Floor_Intact, Floor_Health, Floor_Burnt, Floor_Name)
	if(src.underlays.len)	return 0	//only one underlay
	if(!(FloorIcon || FloorIcon_State))	return 0
	if(!Floor_Health)	Floor_Health = 150
	if(!Floor_Burnt)	Floor_Burnt = 0
	if(!Floor_Intact)	Floor_Intact = 1
	if(!Floor_Name)	Floor_Name = "floor"
	underlays += image(FloorIcon, FloorIcon_State)
	src.flooricon = FloorIcon
	src.flooricon_state = FloorIcon_State
	src.floorintact = Floor_Burnt
	src.floorhealth = Floor_Health
	src.floorburnt = Floor_Burnt
	src.floorname = Floor_Name
	return 1

/turf/simulated/wall/false_rwall/attack_paw(mob/user as mob)
	if ((ticker && ticker.mode.name == "monkey"))
		return src.attack_hand(user)
	return

/turf/simulated/wall/false_rwall/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	var/known = (user in known_by)

	if (src.density) //door is closed
		if (known)
			if (open())
				user << "\blue The wall slides open." //lack of exclamation mark reflects nonchalance
		else if (prob(prob_opens)) //it's hard to open
			if (open()) //it successfully opens, i.e. wasn't operating
				user << "\blue The wall slides open!"
				known_by += user
		else
			return ..()
	else
		if (close())
			user << "\blue The wall slides shut."
	return

/turf/simulated/wall/false_rwall/attackby(obj/item/weapon/screwdriver/S as obj, mob/user as mob)
	src.add_fingerprint(user)
	var/known = (user in known_by)
	if (istype(S, /obj/item/weapon/screwdriver))
		//try to disassemble the false wall
		if (!src.density || prob(prob_opens)) //without this, you can detect a false wall just by going down the line with screwdrivers
			//if it's already open, you can disassemble it no problem
			if (src.density && !known) //if it was closed, let them know that they did something
				user << "\blue It was a false wall!"
			//disassemble it
			user << "\blue Now dismantling false wall."
			var/floorname1	= src.floorname
			var/floorintact1	= src.floorintact
			var/floorhealth1	= src.floorhealth
			var/floorburnt1	= src.floorburnt
			var/icon/flooricon1	= src.flooricon
			var/flooricon_state1	= src.flooricon_state
			var/turf/simulated/floor/F = src.ReplaceWithFloor()
			F.name = floorname1
			F.icon = flooricon1
			F.icon_state = flooricon_state1
			F.intact = floorintact1
			F.health = floorhealth1
			F.burnt = floorburnt1

			//a false wall turns into a sheet of metal and displaced girders
			new /obj/item/weapon/sheet/metal(F)
			new /obj/item/weapon/sheet/metal(F)
			new /obj/d_girders(F)
			F.buildlinks()
			F.levelupdate()
			return
		else
			return ..()
	else
		return src.attack_hand(user)

/turf/simulated/wall/false_rwall/proc/open()
	if (src.operating)
		return 0
	src.operating = 1
	src.name = "false rwall"
	flick("rdoorc0", src) //show the door opening animation
	src.icon_state = "rdoor0"
	spawn(delay) //we want to return 1 without waiting for the animation to finish - the textual cue seems sloppy if it waits
		//actually do the opening things
		src.density = 0
		src.opacity = 0
		if(!src.floorintact)
			src.intact = 0
			src.levelupdate()
		if(checkForMultipleDoors())
			src.updatecell = 1
			src.state = 1
			src.buildlinks()
		src.operating = 0
	return 1

/turf/simulated/wall/false_rwall/proc/close()
	if (src.operating)
		return 0
	src.operating = 1
	src.name = "r wall"
	flick("rdoorc1", src) //show the door closing animation
	src.icon_state = "rdoor1"
	src.density = 1
	if (src.visible)
		src.opacity = 1
	src.updatecell = 0
	src.state = 2		//stops airflow
	src.buildlinks()
	src.intact = 1
	src.levelupdate()
	spawn(delay) //we want to return 1 without waiting for the animation to finish - the textual cue seems sloppy if it waits
		src.operating = 0
	return 1

/turf/simulated/wall/false_rwall/examine()
	set src in oview(1)
	if (src.density) //door is closed
		..()
	else
		usr << "It's a false rwall. It's open."
	return
