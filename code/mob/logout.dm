/mob/Logout()
	world.log_access("Logout: [src.key]")
	if(!src.start)
		del(src)
		return
	else
		..()
	return