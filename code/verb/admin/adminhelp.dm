/mob/verb/adminhelp(msg as text)
	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	world.log_ooc("HELP: [src.name]/[src.key] : [msg]")

	var/yep = 0
	if (!src.muted)
		for(var/mob/M in world)
			if (M.client && M.client.holder)
				M << "\blue <b>HELP: <a href='?src=\ref[usr];priv_msg=\ref[usr]'>[src.key]</a>/([src.rname]):</b> [msg]"
				yep = 1

	if (yep)
		src << "Your message has been broadcast to administrators."
	else
		src << "Sorry, no administrators are on to hear your plea for help. Your message has been logged."
		world.log_admin("HELP: [src.key]/[src.rname]: [msg]")