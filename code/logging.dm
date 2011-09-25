/world/proc/log_admin(text)
	if (config.log_admin)
		world.log << "ADMIN: [text]"

/world/proc/log_game(text)
	if (config.log_game)
		world.log << "GAME: [text]"

/world/proc/log_vote(text)
	if (config.log_vote)
		world.log << "VOTE: [text]"

/world/proc/log_access(text)
	if (config.log_access)
		world.log << "ACCESS: [text]"

/world/proc/log_say(text)
	if (config.log_say)
		world.log << "SAY: [text]"

/world/proc/log_ooc(text)
	if (config.log_ooc)
		world.log << "OOC: [text]"
