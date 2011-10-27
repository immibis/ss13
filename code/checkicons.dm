world/New()
	. = ..()
	spawn(10)
		var/l_path = 'icons/goonstation/mob/items_lefthand.dmi'
		var/l_states = icon_states(l_path)
		for(var/path in typesof(/obj/item))
			var/obj/item/O = new path()

			if(!(O.icon_state in icon_states(O.icon)) && O.icon_state)
				world.log << "[O.icon]:[O.icon_state] does not exist ([path])"
			if(!(O.s_istate in l_states) && O.s_istate)
				world.log << "[l_path]:[O.s_istate] does not exist ([path])"

			del(O)

obj/item/New()
	. = ..()
	if(!(icon_state in icon_states(icon)) && icon_state)
		icon = 'icons/ss13/old_items.dmi'
