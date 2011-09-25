/mob/verb/who()
	set name = "Who"

	var/total = 0
	usr << "<b>Current Players:</b>"

	for (var/mob/M in world)
		if (!M.client)
			continue

		total++

		usr << "\t[M.client]"

	usr << "<b>Total Players: [total]</b>"