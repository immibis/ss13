/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"

/datum/game_mode/meteor/announce()
	world << "<B>The current game mode is - Meteor!</B>"
	world << "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>"

/datum/game_mode/meteor/post_setup()
	spawn (0)
		ticker.meteor_process()

/datum/game_mode/meteor/check_win()
	var/list/L = list()
	var/area/A = locate(/area/shuttle)

	for(var/mob/M in world)
		if (M.client)
			if (M.stat != 2)
				var/T = M.loc
				if ((T in A))
					L[text("[]", M.rname)] = "shuttle"
				else
					if (istype(T, /obj/machinery/vehicle/pod))
						L[text("[]", M.rname)] = "pod"
					else
						L[text("[]", M.rname)] = "alive"
	if (L.len)
		world << "\blue <B>The following survived the meteor attack!</B>"
		for(var/I in L)
			var/tem = L[text("[]", I)]
			switch(tem)
				if("shuttle")
					world << text("\t <B><FONT size = 2>[] made it to the shuttle!</FONT></B>", I)
				if("pod")
					world << text("\t <FONT size = 2>[] at least made it to an escape pod!</FONT>", I)
				if("alive")
					world << text("\t <FONT size = 1>[] at least is alive.</FONT>", I)
				else
	else
		world << "\blue <B>No one survived the meteor attack!</B>"
	return 1