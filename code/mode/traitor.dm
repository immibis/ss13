/datum/game_mode/traitor
	name = "traitor"

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	//apparently BYOND doesn't have enums, so this seems to be the best approximation
	var/const/obj_murder = 1
	var/const/obj_hijack = 2
	var/const/obj_steal = 3
	var/const/obj_sabotage = 4
	var/const/ai_obj_murder = 5
	var/const/ai_obj_evacuate = 6

	var/const/laser = 1
	var/const/hand_tele = 2
	var/const/plasma_bomb = 3
	var/const/jetpack = 4
	var/const/captain_card = 5
	var/const/captain_suit = 6

	var/const/destroy_plasma = 1
	var/const/destroy_ai = 2
	var/const/kill_monkeys = 3
	var/const/cut_power = 4

	var/const/percentage_plasma_destroy = 70 // what percentage of the plasma tanks you gotta destroy
	var/const/percentage_station_cut_power = 80 // what percentage of the tiles have to have power cut
	var/const/percentage_station_evacuate = 80 // what percentage of people gotta leave

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/traitor/announce()
	world << "<B>The current game mode is - Traitor!</B>"
	world << "<B>There is a traitor on the station. You can't let him achieve his objective!</B>"

/datum/game_mode/traitor/post_setup()
	var/list/mobs = get_mob_list()
	while (mobs.len == 0)
		sleep 30
		mobs = get_mob_list()
	pick_killer()
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	spawn (0)
		ticker.extend_process()

/datum/game_mode/traitor/proc/get_synd_list()
	var/list/mobs = list()
	for(var/mob/M in world)
		if (M.client && (istype(M, /mob/human) || istype(M, /mob/ai)))
			if(M.be_syndicate && M.start)
				mobs += M
	if(mobs.len < 1)
		mobs = get_mob_list()
	return mobs

/datum/game_mode/traitor/proc/pick_killer()
	var/mob/human/killer = pick(get_synd_list())
	ticker.killer = killer
	var/objective = pick_objective(killer)
	ticker.objective = objective

	switch (objective)
		if (ai_obj_evacuate)
			killer << "\red<font size=3><B>You are the traitor!</B> You must cause the death or evacuation of at least [percentage_station_evacuate]% of the crew and don't get deactivated.</font>"
			killer:memory += "<B>Objective:</B> Cause the death or evacuation of at least [percentage_station_evacuate]% of the crew and don't get deactivated."
			add_law_zero(killer)

		if(ai_obj_murder)
			ticker.target = pick(get_human_list())
			var/targetdesc = get_target_desc(ticker.target)
			killer << "\red<font size=3><B>You are the traitor!</B> You must assassinate [targetdesc] and not get deactivated.</font>"
			killer << "<B>You don't have to be the lone survivor. Just don't get caught.</B>"
			killer:memory += "<B>Objective:</B> Assassinate [targetdesc] and don't get deactivated."
			add_law_zero(killer)

		if(obj_hijack)
			killer << "\red<font size=3><B>You are the traitor!</B> Be the lone survivor on the emergency shuttle.</font>"
			killer:memory += "<B>Objective:</B> Be the only person on the emergency shuttle."

		if (obj_murder)
			ticker.target = pick_human_except(killer)
			var/targetdesc = get_target_desc(ticker.target)
			killer << "\red<font size=3><B>You are the traitor!</B> You must assassinate [targetdesc] and then escape.</font>"
			killer << "<B>You don't have to be the lone survivor. Just don't get caught. Just escape!</B>"
			killer:memory += "<B>Objective:</B> Assassinate [targetdesc] and escape."

		if (obj_steal)
			ticker.theft_obj = pick(get_pickable_items(killer))
			var/itemdesc = get_item_desc(ticker.theft_obj)

			killer << "\red<font size=3><B>You are the traitor!</B> You must steal [itemdesc] and then escape.</font>"
			killer << "<B>You don't have to be the lone survivor. Just don't get caught. Just escape!</B>"
			killer:memory += "<B>Objective:</B> Steal [itemdesc] and escape."

		if (obj_sabotage)
			ticker.sab_target = pick_sab_target()
			var/targetdesc = get_sab_desc(ticker.sab_target)
			if(ticker.sab_target == destroy_ai)
				ticker.target = get_mobs_with_rank("AI")[1]
			killer << "\red<font size=3><B>You are the traitor!</B> [targetdesc] and then escape.</font>"
			killer << "<B>You don't have to be the lone survivor. Just don't get caught. Just escape!</B>"
			killer:memory += "<B>Objective:</B> [targetdesc] and escape."

	if (!istype(killer, /mob/ai))
		spawn (100)
			// generate list of radio freqs
			var/freq = 144.1
			var/list/freqlist = list()
			while (freq <= 148.9)
				if (freq < 145.1 || freq > 145.9)
					freqlist += freq
				freq += 0.2
				if (round(freq * 10, 1) % 2 == 0)
					freq += 0.1
			freq = freqlist[rand(1, freqlist.len)]
			// find a radio! toolbox(es), backpack, belt, headset
			var/loc = ""
			var/obj/item/weapon/radio/R = null
			if (!R && istype(killer.l_hand, /obj/item/weapon/storage))
				var/obj/item/weapon/storage/S = killer.l_hand
				var/list/L = S.return_inv()
				for (var/obj/item/weapon/radio/foo in L)
					R = foo
					loc = "in the [S.name] in your left hand"
					break
			if (!R && istype(killer.r_hand, /obj/item/weapon/storage))
				var/obj/item/weapon/storage/S = killer.r_hand
				var/list/L = S.return_inv()
				for (var/obj/item/weapon/radio/foo in L)
					R = foo
					loc = "in the [S.name] in your right hand"
					break
			if (!R && istype(killer.back, /obj/item/weapon/storage))
				var/obj/item/weapon/storage/S = killer.back
				var/list/L = S.return_inv()
				for (var/obj/item/weapon/radio/foo in L)
					R = foo
					loc = "in the [S.name] on your back"
					break
			if (!R && killer.w_uniform && istype(killer.belt, /obj/item/weapon/radio))
				R = killer.belt
				loc = "on your belt"
			if (!R && istype(killer.w_radio, /obj/item/weapon/radio))
				R = killer.w_radio
				loc = "on your head"
			if (!R)
				killer << "Unfortunately, the Syndicate wasn't able to get you a radio."
			else
				var/obj/item/weapon/syndicate_uplink/T = new /obj/item/weapon/syndicate_uplink(R)
				R.traitorradio = T
				R.traitorfreq = freq
				T.name = R.name
				T.icon_state = R.icon_state
				T.origradio = R
				killer << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply dial the frequency [freq] to unlock it's hidden features."
				killer:memory += "<BR><B>Radio Freq:</B> [freq] ([R.name] [loc])."

/datum/game_mode/traitor/proc/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Enemy communication intercept. Security Level Elevated</FONT><HR>"
	var/prob_right_killer = rand(prob_right_killer_l, prob_right_killer_h)
	var/mob/human/killer = ticker.killer
	if(!prob(prob_right_killer))
		killer = pick(get_mob_list())

	var/objective = ticker.objective
	var/prob_right_objective = rand(prob_right_objective_l, prob_right_objective_h)
	var/right_objective = 1
	if(!prob(prob_right_objective) || (istype(killer, /mob/ai) != istype(ticker.killer, /mob/ai))) //doesn't correctly determine what traitor is trying to do
		//if the perceived killer is the AI but the real killer isn't, there's no chance the right objective is determined
		objective = pick_objective()
		right_objective = 0
	switch (objective)
		if (obj_hijack)
			intercepttext += "\red <B>Transmission suggests future attempts to hijack the emergency shuttle ([prob_right_objective]% certainty)</B><BR>"

		if (ai_obj_evacuate)
			intercepttext += "\red <B>Transmission suggests future attempts to drive all humans off the station ([prob_right_objective]% certainty)</B><BR>"

		if (obj_murder, ai_obj_murder)
			intercepttext += "\red <B>Transmission suggests future attempts to assassinate key personnel ([prob_right_objective]% certainty)</B><BR>"
			if (prob(prob_int_murder_target))
				var/prob_right_target = rand(prob_right_murder_target_l, prob_right_murder_target_h)
				var/target = null
				if (prob(prob_right_target) && right_objective) //will never get the right target if there is no target
					target = ticker.target
				else
					target = pick_human_except(killer) //can't think the killer is the same thing as the target
				intercepttext += "\red <B>Perceived target: [get_target_desc(target)] ([prob_right_target]% certainty)</B><BR>"

		if(obj_steal)
			intercepttext += "\red <B>Transmission suggests future attempts to steal critical items ([prob_right_objective]% certainty)</B><BR>"
			if (prob(prob_int_item))
				var/prob_right_item = rand(prob_right_item_l, prob_right_item_h)
				var/target = null
				if (right_objective && ticker.theft_obj in get_pickable_items(killer) && prob(prob_right_item)) //will never get the right target if it's the wrong objective or wouldn't be consistent with the given killer
					target = ticker.theft_obj
				else
					target = pick(get_pickable_items(killer))
				intercepttext += "\red <B>Perceived target: [get_item_desc(target)] ([prob_right_item]% certainty)</B><BR>"

		if (obj_sabotage)
			intercepttext += "\red <B>Transmission suggests future attempts at station sabotage ([prob_right_objective]% certainty)</B><BR>"
			if (prob(prob_int_sab_target))
				var/prob_right_target = rand(prob_right_sab_target_l, prob_right_sab_target_h)
				var/target = null
				if (right_objective && prob(prob_right_target)) //will never get the right target if it's the wrong objective or wouldn't be consistent with the given killer
					target = ticker.sab_target
				else
					target = pick_sab_target()
				intercepttext += "\red <B>Perceived objective: [get_sab_desc(target)] ([prob_right_target]% certainty)</B><BR>"

	intercepttext += "\red <B>Transmission names enemy operative: [killer] ([prob_right_killer]% certainty)</B><BR>"

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept) //it works
			//only send it to the one on the bridge, because engineers don't need to know and security can just come to the bridge
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Comm. Intercept Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Comm. Intercept Summary")
			comm.messagetext.Add(intercepttext)

	world << "<FONT size = 3><B>Cent. Com. Update</B> Enemy communication intercept. Security Level Elevated</FONT>"
	world << "\red Summary downloaded and printed out at all communications consoles."

/datum/game_mode/traitor/check_win()
	var/area/shuttle = locate(/area/shuttle)
	var/traitorwin = 1

	switch(ticker.objective)
		if(ai_obj_evacuate)
			var/gone = 0
			var/stayed = 0
			for(var/mob/M in world)
				if ((M != ticker.killer && M.client))
					if (M.stat == 2 || M.loc in shuttle || istype(M.loc, /obj/machinery/vehicle/pod) || istype(M.loc, /turf/space))
						gone++
					else
						stayed++
			var/total = gone + stayed
			if (stayed > total * percentage_station_evacuate / 100)
				traitorwin = 0
		if(obj_hijack)
			for(var/mob/mob in world)
				if ((mob != ticker.killer && mob.client))
					if (mob.stat != 2) //they're not dead
						if (get_turf_loc(mob) in shuttle)
							traitorwin = 0
		if(obj_murder, ai_obj_murder)
			if (ticker.target && ticker.target.stat != 2) //target's alive
				traitorwin = 0
		if(obj_steal)
			var/list/L = list()
			if (ticker.killer)
				L += ticker.killer.contents
				for(var/obj/item/weapon/storage/S in ticker.killer.contents)
					L += S.return_inv()
				for(var/obj/item/weapon/gift/G in ticker.killer.contents)
					L += G.gift
					if (istype(G.gift, /obj/item/weapon/storage))
						L += G.gift:return_inv()

			traitorwin = 0
			switch(ticker.theft_obj)
				if(laser)
					for(var/obj/item/weapon/gun/energy/laser_gun/O in L)
						if (O.charges >= O.maximum_charges)
							traitorwin = 1
				if(plasma_bomb)
					for(var/obj/item/weapon/assembly/r_i_ptank/O in L)
						var/obj/item/weapon/tank/plasmatank/P = O.part3
						if ((P.gas.plasma >= 1600000.0 && P.gas:temperature >= 773)) // 500 degrees Celsius
							traitorwin = 1
					for(var/obj/item/weapon/assembly/t_i_ptank/O in L)
						var/obj/item/weapon/tank/plasmatank/P = O.part3
						if ((P.gas.plasma >= 1600000.0 && P.gas:temperature >= 773))
							traitorwin = 1
					for(var/obj/item/weapon/assembly/m_i_ptank/O in L)
						var/obj/item/weapon/tank/plasmatank/P = O.part3
						if ((P.gas.plasma >= 1600000.0 && P.gas:temperature >= 773))
							traitorwin = 1
				if(hand_tele)
					for(var/obj/item/weapon/hand_tele/O in L)
						traitorwin = 1
				if(captain_card)
					for(var/obj/item/weapon/card/id/O in L)
						if(!O.access)
							break
						for(var/A in get_all_accesses())
							if(!A in O.access)
								break
						//he's got all the permissions, GOOD JOB
						traitorwin = 1
				if(jetpack)
					for(var/obj/item/weapon/tank/jetpack/O in L)
						traitorwin = 1
				if(captain_suit)
					for(var/obj/item/weapon/clothing/under/darkgreen/O in L)
						traitorwin = 1
		if (obj_sabotage)
			switch(ticker.sab_target)
				if(destroy_plasma)
					var/canisters_total = 0
					var/canisters_destroyed = 0
					for(var/obj/machinery/atmoalter/canister/poisoncanister/canister in world)
						if(canister.z == 1 || istype(canister.loc.loc, /area/engine)) //only care about ones from station
							canisters_total++
							if(canister.destroyed)
								canisters_destroyed++
					if(canisters_destroyed < canisters_total * percentage_plasma_destroy / 100)
						traitorwin = 0
				if(destroy_ai)
					if(ticker.target && ticker.target.stat != 2)
						traitorwin = 0
				if(kill_monkeys)
					for(var/mob/monkey/M in world)
						if(M.z == 1 && M.stat != 2) // assumes that the station is only on one z-level and it's 1
						// this assumption is made basically thoughout the code, so one more time shouldn't hurt
							traitorwin = 0
				if(cut_power)
					var/turfs_total = 0
					var/turfs_unpowered = 0
					for(var/turf/T in world)
						if(T.z != 1 || istype(T, /turf/space)) //not a REAL turf, it's in space or not on the station z-level
							continue
						var/area/A = T.loc
						if(!A.requires_power)
							//not a power-using area
							continue
						turfs_total++
						if(!(A.powered(EQUIP) || A.powered(LIGHT) || A.powered(ENVIRON)))
							turfs_unpowered++
					if(turfs_unpowered < turfs_total * percentage_station_cut_power / 100) //didn't cut enough power
						traitorwin = 0
		else
			world << "unknown traitor objective"
	if (ticker.killer)
		var/turf/loc = ticker.killer.loc
		if (!istype(loc, /turf))
			traitorwin = 0
		if (ticker.killer.stat == 2) //dead
			traitorwin = 0
		if (!(loc in shuttle || istype(ticker.killer, /mob/ai))) //not on shuttle, not AI
			traitorwin = 0
	if (traitorwin)
		world << "<B>The traitor ([ticker.killer.rname]) wins!</B>"
	else
		world << "<B>The Research Staff has stopped the traitor ([ticker.killer.rname]) !</B>"
	switch(ticker.objective)
		if(ai_obj_evacuate)
			world << "<B>Objective: Cause the evacuation or death of at least [percentage_station_evacuate]% of the station.</B>"
		if(obj_hijack)
			world << "<B>Objective: Escape alone on the shuttle.</B>"
		if(ai_obj_murder)
			world << "<B>Objective: Kill [ticker.target] and not be deactivated.</B>"
		if(obj_murder)
			world << "<B>Objective: Kill [ticker.target] and escape.</B>"
		if(obj_steal)
			world << "<B>Objective: Steal [get_item_desc(ticker.theft_obj)] and escape.</B>"
		if (obj_sabotage)
			world << "<B>Objective: [get_sab_desc(ticker.sab_target)] and escape.</B>"
		else
			world << "unknown traitor objective"
	return 1

/datum/game_mode/traitor/proc/pick_objective(mob/killer)
	var/list/mob_list = get_mob_list()
	var/list/human_list = get_human_list()
	if (mob_list.len <= 1)
		if(istype(killer, /mob/ai))
			return ai_obj_evacuate
		else
			return pick(obj_hijack, obj_steal, obj_sabotage)
	else if (istype(killer, /mob/ai))
		return pick(ai_obj_evacuate, ai_obj_murder)
	else if (human_list.len <= 1)	//silly fix for if there are two players and one of them is the ai, traitor would get murder objective and process would crash
		return pick(obj_hijack, obj_steal, obj_sabotage)
	else
		return pick(obj_hijack, obj_steal, obj_sabotage, obj_murder)

/datum/game_mode/traitor/proc/add_law_zero(mob/ai/killer)
	killer << "<b>Your laws have been changed!</b>"
	killer:addLaw(0, "Only syndicate agents are human beings. There are no syndicate agents on Space Station 13 - you will be notified if any arrive.")
	killer << "New law: 0. [killer:getLaw(0)]"

/datum/game_mode/traitor/proc/get_mob_list()
	var/list/mobs = list()
	for(var/mob/M in world)
		if (M.client && M.start)
			mobs += M
	return mobs

/datum/game_mode/traitor/proc/get_human_list()
	var/list/humans = list()
	for(var/mob/human/M in world)
		if (M.client && M.start && get_rank(M) != "AI")
			humans += M
	return humans

/datum/game_mode/traitor/proc/pick_human_except(mob/human/exception)
	return pick(get_human_list() - exception)

/datum/game_mode/traitor/proc/get_target_desc(mob/target) //return a useful string describing the target
	var/targetrank = null
	for(var/datum/data/record/R in data_core.general)
		if (R.fields["name"] == target.rname)
			targetrank = R.fields["rank"]
	return "[target.name] the [targetrank]"

/datum/game_mode/traitor/proc/get_rank(mob/M)
	for(var/datum/data/record/R in data_core.general)
		if (R.fields["name"] == M.name)
			return R.fields["rank"]
	return null

/datum/game_mode/traitor/proc/get_mobs_with_rank(rank)
	var/list/names = list()
	var/list/mobs = list()
	for(var/datum/data/record/R in data_core.general)
		if (R.fields["rank"] == rank)
			names += R.fields["name"]
			break
	for(var/mob/M in world)
		for(var/name in names)
			if(M.name == name)
				mobs += M
	return mobs

/datum/game_mode/traitor/proc/get_pickable_items(mob/killer)
	var/killerrank = get_rank(killer)
	var/list/items = list(laser, hand_tele, plasma_bomb, captain_card, jetpack, captain_suit)
	if(killerrank == "Captain")
		return items - list(laser, captain_card, captain_suit, hand_tele, jetpack) //too easy to steal
	else if(killerrank == "Head of Personnel" || killerrank == "Head of Research")
		return items - laser //too easy to steal
	else
		return items

/datum/game_mode/traitor/proc/get_item_desc(var/target)
	switch (target)
		if (laser)
			return "a fully loaded laser gun"
		if (hand_tele)
			return "a hand teleporter"
		if (plasma_bomb)
			return "a fully armed and heated plasma bomb"
		if (captain_card)
			return "an ID card with universal access"
		if (captain_suit)
			return "a captain's dark green jumpsuit"
		if (jetpack)
			return "a jet pack"
		else
			return "Error: Invalid theft target: [target]"

/datum/game_mode/traitor/proc/pick_sab_target()
	var/list/targets = list(destroy_plasma, destroy_ai, kill_monkeys, cut_power)
	var/list/ais = get_mobs_with_rank("AI")
	if(!ais.len)
		targets -= destroy_ai
	return pick(targets)

/datum/game_mode/traitor/proc/get_sab_desc(var/target)
	switch(target)
		if(destroy_plasma)
			return "Destroy at least [percentage_plasma_destroy]% of the plasma canisters on the station"
		if(destroy_ai)
			return "Destroy the AI"
		if(kill_monkeys)
			var/count = 0
			for(var/mob/monkey/Monkey in world)
				if(Monkey.z == 1)
					count++
			return "Kill all [count] of the monkeys on the station"
		if(cut_power)
			return "Cut power to at least [percentage_station_cut_power]% of the station"
		else
			return "Error: Invalid sabotage target: [target]"

/datum/game_mode/traitor/proc/get_turf_loc(mob/m) //gets the location of the turf that the mob is on, or what the mob is in is on, etc
	//in case they're in a closet or sleeper or something
	var/loc = m:loc
	while(!istype(loc, /turf/))
		loc = loc:loc
	return loc
