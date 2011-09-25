/mob/human/death()
	if(src.stat == 2)
		return
	if(src.healths)
		src.healths.icon_state = "health5"
	src.stat = 2

	emote("deathgasp") //let the world KNOW WE ARE DEAD
	src.canmove = 0
	if(src.client)
		src.blind.layer = 0
	src.lying = 1

	var/h = src.hand
	src.hand = 0
	drop_item()
	src.hand = 1
	drop_item()
	src.hand = h

	var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	store_memory("Time of death: [tod]", 0)
	//src.icon_state = "dead"

		//For restructuring
	if(ticker.mode.name == "Corporate Restructuring")
		ticker.check_win()

	var/cancel
	for(var/mob/M in world)
		if ((M.client && !( M.stat )))
			cancel = 1
			break
	if (!( cancel ))
		spawn(50)
			cancel = 0
			for(var/mob/M in world)
				if ((M.client && !( M.stat )))
					cancel = 1
					break
			if(!( cancel ))
				world << "<B>Everyone is dead! Resetting in 30 seconds!</B>"
				if ((ticker && ticker.timing))
					ticker.check_win()
				else
					spawn( 300 )
						world.log_game("Rebooting because of no live players")
						world.Reboot()
						return
	return ..()