/datum/configuration
	var/log_ooc = 1						// log OOC channel
	var/log_access = 1					// log login/logout
	var/log_say = 1						// log client say
	var/log_admin = 1					// log admin actions
	var/log_game = 1					// log game events
	var/log_vote = 1					// log voting
	var/allow_vote_restart = 1 			// allow votes to restart
	var/allow_vote_mode = 1				// allow votes to change mode
	var/vote_delay = 60					// minimum time between voting sessions (seconds)
	var/vote_period = 60				// length of voting period (seconds)
	var/vote_no_default = 0				// vote does not default to nochange/norestart (tbi)
	var/vote_no_dead = 0				// dead people can't vote (tbi)

	var/list/mode_names = list()
	var/list/modes = list()				// allowed modes
	var/list/votable_modes = list()		// votable modes
	var/list/probabilities = list()		// relative probability of each mode
	var/respawn = 1

	New()
		for (var/T in (typesof(/datum/game_mode) - /datum/game_mode))
			var/datum/game_mode/M = new T()
			var/id = copytext("[T]", 18)
			world.log << "Adding game mode [M.name] ([id]) to configuration."
			src.modes += id
			src.mode_names[id] = M.name
			probabilities[id] = 0
			del(M)

		probabilities["meteor"] = 2
		probabilities["nuclear"] = 3
		probabilities["traitor"] = 6

	proc/pick_random_mode()
		var/total = 0
		for(var/k in probabilities)
			total += probabilities[k]
		total = rand(0, total-1)
		for(var/k in probabilities)
			if(total < probabilities[k])
				return k
			else
				total -= probabilities[k]
		CRASH("No mode selected!")

	proc/pick_mode(id)
		var/path = text2path("/datum/game_mode/[id]")
		if(!path)
			return null
		return new path()