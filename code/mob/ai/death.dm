/mob/ai/death()
	var/cancel
	src.stat = 2
	src.canmove = 0
	if (src.blind)
		src.blind.layer = 0
	src.sight |= SEE_TURFS
	src.sight |= SEE_MOBS
	src.sight |= SEE_INFRA
	src.sight |= SEE_OBJS
	src.see_in_dark = 8
	src.see_invisible = 2
	src.see_infrared = 8
	src.lying = 1
	src.icon_state = "teg-broken"

		//For restructuring
	if(ticker.mode.name == "Corporate Restructuring")
		ticker.check_win()

	var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	store_memory("Time of death: [tod]", 0)

	for(var/mob/M in world)
		if ((M.client && !( M.stat )))
			cancel = 1
			break
	if (!( cancel ))
		world << "<B>Everyone is dead! Resetting in 30 seconds!</B>"
		if ((ticker && ticker.timing))
			ticker.check_win()
		else
			spawn( 300 )
				world.log_game("Rebooting because of no live players")
				world.Reboot()
				return
	return ..()