/datum/game_mode/monkey
	name = "monkey"

/datum/game_mode/monkey/announce()
	world << "<B>The current game mode is - Monkey!</B>"
	world << "<B>Some of your crew members have been infected by a mutageous virus!</B>"
	world << "<B>Escape on the shuttle but the humans have precedence!</B>"

/datum/game_mode/monkey/post_setup()
	spawn (50)
		var/list/mobs = list()
		for (var/mob/human/M in world)
			if ((M.client && M.start))
				mobs += M

		if (mobs.len >= 3)
			var/amount = round((mobs.len - 1) / 3) + 1
			amount = min(4, amount)
			while (amount > 0)
				var/mob/human/H = pick(mobs)
				H.monkeyize()
				mobs -= H
				amount--

	spawn (0)
		ticker.extend_process()

/datum/game_mode/monkey/check_win()
	var/area/A = locate(/area/shuttle)
	var/monkeywin = 1
	for(var/mob/human/M in world)
		if (M.stat != 2)
			var/T = M.loc
			if (istype(T, /turf))
				if ((T in A))
					monkeywin = 0
		//Foreach goto(999)
	if (monkeywin)
		monkeywin = 0
		for(var/mob/monkey/M in world)
			if (M.stat != 2)
				var/T = M.loc
				if (istype(T, /turf))
					if ((T in A))
						monkeywin = 1
			//Foreach goto(1096)
	if (monkeywin)
		world << "<FONT size = 3><B>The monkies have won!</B></FONT>"
		for(var/mob/monkey/M in world)
			if (M.client)
				world << text("<B>[] was a monkey.</B>", M.key)
			//Foreach goto(1194)
	else
		world << "<FONT size = 3><B>The Research Staff has stopped the monkey invasion!</B></FONT>"
		for(var/mob/human/M in world)
			if (M.client)
				world << text("<B>[] was [].</B>", M.key, M)
	return 1