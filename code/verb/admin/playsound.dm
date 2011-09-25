/client/proc/play_sound(S as sound)
	set category = "Debug"
	set name = "play sound"

	if(!src.holder)
		src << "Only administrators may use this command."
		return

	world.log_admin("[src] played sound [S]")
	messageadmins("[src] played sound [S]")
	world << sound(S,0,0,1)