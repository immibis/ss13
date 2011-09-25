/client/proc/adminsay(msg as text)
	if(!src.holder)
		src << "Only administrators may use this command."
		return

	if(!src.mob)
		return

	var/name = ((src.mob)?(src.mob.name):("No Mob"))

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	world.log_admin("[src.key]/[name] : [msg]")

	if (!msg)
		return

	for(var/mob/M in world)
		if (M.client && M.client.holder)
			M << "\blue <b>ADMIN: <a href='?src=\ref[usr];priv_msg=\ref[usr]'>[src.key]</a>/([name]):</b> [msg]"