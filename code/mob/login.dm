/mob/Login()
	world.log_access("Login: [src.key] from [src.client.address]")
	src.lastKnownIP = src.client.address
	if (config.log_access)
		for (var/mob/M in world)
			if(M == src)
				continue
			if(M.client && M.client.address == src.client.address)
				world.log_access("Notice: [src.key] has same IP address as [M.key]")
				messageadmins("<font color='blue'><B>Notice:</B> [src.key] has same IP address as [M.key]</font>")
			else if (M.lastKnownIP && M.lastKnownIP == src.client.address && M.ckey != src.ckey && M.key)
				world.log_access("Notice: [src.key] has same IP address as [M.key] did ([M.key] is no longer logged in).")
				messageadmins("<font color='blue'><B>Notice:</B> [src.key] has same IP address as [M.key] did ([M.key] is no longer logged in).</font>")
				if (crban_isbanned(M.ckey))
					world.log_access("Further notice: [M.key] was banned.")
					messageadmins("<font color='blue'><B>Further notice:</B> [M.key] was banned.</font>")

	src.client.screen -= main_hud1.contents
	world.update_stat()
	if (!src.hud_used)
		src.hud_used = main_hud1
	src.next_move = 1
	if (!src.rname)
		src.rname = capitalize(pick(first_names) + " " + capitalize(pick(last_names)))

	src.sight |= SEE_SELF

	. = ..()