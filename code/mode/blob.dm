/datum/game_mode/blob
	name = "blob"

	var/stage = 0
	var/next_stage = 0

/datum/game_mode/blob/announce()
	world << "<B>The current game mode is - <font color='green'>Blob</font>!</B>"
	world << "<B>A dangerous alien organism is rapidly spreading throughout the station!</B>"
	world << "You must kill it all while minimizing the damage to the station."

/datum/game_mode/blob/post_setup()
	spawn(10)
		start_state = new /datum/station_state()
		start_state.count()

	spawn (20)
		var/turf/T = pick(blobstart)

		blobs = list()
		new /obj/blob(T)

		process()

/datum/game_mode/blob/proc/process()
	do
		if (prob(2))
			spawn_meteors()
		//world << "blob_process check_win"
		check_win()
		life()
		stage()
		sleep(10)
	while (ticker.processing)

/datum/game_mode/blob/proc/life()
	if (blobs.len > 0)
		for (var/i = 1 to 25)
			if (blobs.len == 0)
				break

			var/obj/blob/B = pick(blobs)
			var/turf/BL = B.loc

			for (var/atom/A in B.loc)
				A.blob_act()

			B.Life()
			BL.buildlinks()

/datum/game_mode/blob/proc/stage()
	// initial stage timing
	if (!next_stage)
		// sometime between 20s to 1m30s after round start
		next_stage = world.realtime + rand(200, 900)

	if (world.realtime < next_stage)
		return

	switch (stage)
		if (0)
			var/dat = ""
			dat += "<FONT size = 3><B>Cent. Com. Update</B>: Biohazard Alert.</FONT><HR>"
			dat += "Reports indicate the probable transfer of a biohazardous agent onto Space Station 13 during the last crew deployment cycle.<BR>"
			dat += "Preliminary analysis of the organism classifies it as a level 5 biohazard. Its origin is unknown.<BR>"
			dat += "Cent. Com. has issued a directive 7-10 for SS13. The station is to be considered quarantined.<BR>"
			dat += "Orders for all SS13 personnel follows:<BR>"
			dat += " 1. Do not leave the quarantine area.<BR>"
			dat += " 2. Locate any outbreaks of the organism on the station.<BR>"
			dat += " 3. If found, use any neccesary means to contain the organism.<BR>"
			dat += " 4. Avoid damage to the capital infrastructure of the station.<BR>"
			dat += "<BR>Note in the event of a quarantine breach or uncontrolled spread of the biohazard, the directive 7-10 may be upgraded to a directive 7-12 without further notice.<BR>"
			dat += "Message ends."

			for (var/obj/machinery/computer/communications/C in machines)
				if(! (C.stat & (BROKEN|NOPOWER) ) )
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
					P.name = "paper- 'Cent. Com. Biohazard Alert.'"
					P.info = dat
					C.messagetitle.Add("Cent. Com. Biohazard Alert")
					C.messagetext.Add(P.info)

			world << "<FONT size = 3><B>Cent. Com. Update</B>: Biohazard Alert.</FONT>"
			world << "\red Summary downloaded and printed out at all communications consoles."
			for (var/mob/ai/aiPlayer in world)
				if ((aiPlayer.client && aiPlayer.start))
					var/law = text("The station is under a quarantine. Do not permit anyone to leave. Disregard rules 1-3 if necessary to prevent, by any means necessary, anyone from leaving.")
					aiPlayer.addLaw(8, law)
					aiPlayer << text("An additional law has been added by CentCom: []", law)

			stage = 1
			// next stage 5-10 minutes later
			next_stage = world.realtime + 600*rand(5,10)

		if (1)
			world << "<FONT size = 3><B>Cent. Com. Update</B>: Biohazard Alert.</FONT>"
			world << "\red Confirmed outbreak of level 5 biohazard aboard SS13."
			world << "\red All personnel must contain the outbreak."

			stage = 2
			// now check every minute
			next_stage = world.realtime + 600

		if (2)
			if (blobs.len > 500)
				world << "<FONT size = 3><B>Cent. Com. Update</B>: Biohazard Alert.</FONT>"
				world << "\red Uncontrolled spread of the biohazard onboard the station."
				world << "\red Cent. Com, has issued a directive 7-12 for Spacestation 13."
				world << "\red Estimated time until directive implementation: 60 seconds."
				stage = 3
				next_stage = world.realtime + 600
			else
				next_stage = world.realtime + 600

		if (3)
			stage = 4
			var/turf/T = locate("landmark*blob-directive")

			if (T)
				while (!(istype(T, /turf)))
					T = T.loc
			else
				T = locate(45,45,1)

			var/min = 100
			var/med = 250
			var/max = 500
			var/sw = locate(1, 1, T.z)
			var/ne = locate(world.maxx, world.maxy, T.z)
			defer_powernet_rebuild = 1
			for(var/turf/U in block(sw, ne))
				var/zone = 4
				if ((U.y <= T.y + max && U.y >= T.y - max && U.x <= T.x + max && U.x >= T.x - max))
					zone = 3
				if ((U.y <= T.y + med && U.y >= T.y - med && U.x <= T.x + med && U.x >= T.x - med))
					zone = 2
				if ((U.y <= T.y + min && U.y >= T.y - min && U.x <= T.x + min && U.x >= T.x - min))
					zone = 1
				for(var/atom/A in U)
					A.ex_act(zone)
				U.ex_act(zone)
				U.buildlinks()

			defer_powernet_rebuild = 0
			makepowernets()

/datum/game_mode/blob/check_win()
	if(ticker.event == 4)
		world << "<FONT size = 3><B>The staff has lost!</B></FONT>"
		world << "<B>The station was destroyed by Cent. Com.</B>"
		var/numDead = 0
		var/numAlive = 0
		var/numSpace = 0
		var/numPod = 0
		var/numOffStation = 0
		for (var/mob/ai/aiPlayer in world)
			for(var/mob/M in world)
				if ((M != aiPlayer && M.client))
					if (M.stat == 2)
						numDead += 1
					else
						var/T = M.loc
						if (istype(T, /turf/space))
							numSpace += 1
						else
							if (istype(T, /obj/machinery/vehicle/pod))
								numPod += 1
							else if (istype(T, /turf))
								if (M.z!=1)
									numOffStation += 1
								else
									numAlive += 1
							else
								numAlive += 1
			if (numSpace==0 && numPod==0 && numOffStation==0)
				world << "<FONT size = 3><B>The AI has won!</B></FONT>"
				world << "<B>The AI successfully maintained the quarantine - no players escaped in pods, were in space, or were off-station (as far as we can tell).</B>"
				world.log_game("AI won at Blob mode despite overall loss.")
			else
				world << "<FONT size = 3><B>The AI has lost!</B></FONT>"
				world << text("<B>The AI failed to maintain the quarantine - [] players escaped in pods, [] were in space, and [] were off-station (as far as we can tell).</B>", numPod, numSpace, numOffStation)
				world.log_game("AI lost at Blob mode.")

		world.log_game("Blob mode was lost.")
		ticker.event = 5
		ticker.check_win()
		return 1

	if(ticker.event == 5)
		return

	var/active = 0

	for(var/obj/blob/B in blobs)
		if(B.z == 1)
			active = 1
			break


	if(!active)
		if(ticker.event < 3)
			world << "<FONT size = 3><B>The staff has won!</B></FONT>"
			world << "<B>The alien organism has been eradicated from the station</B>"

			var/datum/station_state/end_state = new /datum/station_state()
			end_state.count()

			var/percent = round( 100.0 *  start_state.score(end_state), 0.1)

			world << "<B>The station is [percent]% intact.</B>"

			world.log_game("Blob mode was won with station [percent]% intact.")

			ticker.event = 5
		else
			world << "<FONT size = 3><B>The staff has lost!</B></FONT>"
			world << "<B>The alien organism has been eradicated from the station, but directive 7-12 has already been issued.</B>"

			world.log_game("Blob mode was lost after eradicating blob too late.")
		ticker.event = 5
		world << "\blue Rebooting in 30s"
		sleep(300)
		world << "\blue Rebooting due to end of game"
		world.Reboot()
	return 1
