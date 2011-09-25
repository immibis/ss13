/datum/configuration/New()
	var/list/L = typesof(/datum/game_mode) - /datum/game_mode
	for (var/T in L)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/game_mode/M = new T()
		if (M.config_tag)
			world.log << "Adding game mode [M.name] ([M.config_tag]) to configuration."
			src.modes += M.config_tag
			src.mode_names[M.config_tag] = M.name
			src.probabilities[M.config_tag] = M.probability
			if (M.votable)
				src.votable_modes += M.config_tag
		del(M)

/datum/configuration/proc/load(filename)
	var/text = file2text(filename)
	
	if (!text)
		world.log << "No config.txt file found, setting defaults"
		src = new /datum/configuration()
		return
	
	world.log << "Reading configuration file [filename]"
	
	var/list/CL = dd_text2list(text, "\n")
	
	for (var/t in CL)
		if (!t)
			continue
		
		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue
		
		var/pos = findtext(t, " ")
		var/name = null
		var/value = null
		
		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)
		
		if (!name)
			continue
		
		switch (name)
			if ("log_ooc")
				config.log_ooc = 1
				
			if ("log_access")
				config.log_access = 1
				
			if ("log_say")
				config.log_say = 1
				
			if ("log_admin")
				config.log_admin = 1
				
			if ("log_game")
				config.log_game = 1
				
			if ("log_vote")
				config.log_vote = 1
				
			if ("allow_vote_restart")
				config.allow_vote_restart = 1
				
			if ("allow_vote_mode")
				config.allow_vote_mode = 1
				
			if ("no_dead_vote")
				config.vote_no_dead = 1
				
			if ("default_no_vote")
				config.vote_no_default = 1
				
			if ("vote_delay")
				config.vote_delay = text2num(value)
				
			if ("vote_period")
				config.vote_period = text2num(value)
				
			if ("allow_ai")
				config.allow_ai = 1
			
			if ("authentication")
				config.enable_authentication = 1

			if ("norespawn")
				config.respawn = 0

			if ("hostedby")
				config.hostedby = value
			
			if ("probability")
				var/prob_pos = findtext(value, " ")
				var/prob_name = null
				var/prob_value = null
				
				if (prob_pos)
					prob_name = lowertext(copytext(value, 1, prob_pos))
					prob_value = copytext(value, prob_pos + 1)
					if (prob_name in config.modes)
						config.probabilities[prob_name] = text2num(prob_value)
					else
						world.log << "Unknown game mode probability configuration definition: [prob_name]."
				else
					world.log << "Incorrect probability configuration definition: [prob_name]  [prob_value]."
			else
				world.log << "Unknown setting in configuration: '[name]'"

/datum/configuration/proc/pick_mode(mode_name)
	// I wish I didn't have to instance the game modes in order to look up
	// their information, but it is the only way (at least that I know of).
	for (var/T in (typesof(/datum/game_mode) - /datum/game_mode))
		var/datum/game_mode/M = new T()
		if (M.config_tag && M.config_tag == mode_name)
			return M
		del(M)

	return null

/datum/configuration/proc/pick_random_mode()
	var/total = 0
	var/list/accum = list()

	for(var/M in src.modes)
		total += src.probabilities[M]
		accum[M] = total

	var/r = total - (rand() * total)

	var/mode_name = null
	for (var/M in modes)
		if (src.probabilities[M] > 0 && accum[M] >= r)
			mode_name = M
			break

	if (!mode_name)
		world << "Failed to pick a random game mode."
		return null

	//world << "Returning mode [mode_name]"

	return src.pick_mode(mode_name)
