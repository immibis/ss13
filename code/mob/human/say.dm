/mob/human/say(message as text)
	message = copytext(sanitize(message), 1, MAX_MESSAGE_LEN)
	if(!message)
		return
	world.log_say("[src.name]/[src.key] : [message]")

	if (src.muted)
		return
	var/alt_name
	if (src.name != src.rname)
		if(src.wear_id && src.wear_id.registered)
			alt_name = " (as [src.wear_id.registered])"
		else
			alt_name = " (as Unknown)"
	if (src.stat == 2)
		for(var/mob/M in world)
			if (M.stat == 2)
				M << text("<B>[]</B>[] []: []", src.rname, alt_name, (src.stat > 1 ? "\[<I>dead</I> \]" : ""), message)
		return
	if(src.stat >= 1)
		return
	if ((copytext(message, 1, 2) == "*" && !( src.stat )))
		src.emote(copytext(message, 2, length(message) + 1))
		return
	if(src.sdisabilities & 2)
		return
	if (!message || istype(src.wear_mask, /obj/item/weapon/clothing/mask/muzzle))
		return
	if (!src.stat)
		var/list/L = list(  )
		var/italics = 0
		var/obj_range = null
		if (findtext(message, ";") == 1) //say it into headset - just uses a ;, because it's the most common use case
			//say "; words" or say ";words"
			message = copytext(message, 2, length(message) + 1)
			if (src.w_radio)
				src.w_radio.talk_into(usr, message)
			L += hearers(1, null)
			obj_range = 1
			italics = 1
		else if (findtext(message, ":r") == 1) //say into right hand - say ":r words" or say ":rwords"
			message = copytext(message, 3, length(message) + 1)
			if (src.r_hand)
				src.r_hand.talk_into(usr, message)
			L += hearers(1, null)
			obj_range = 1
			italics = 1
		else if (findtext(message, ":l") == 1) // left hand
			message = copytext(message, 3, length(message) + 1)
			if (src.l_hand)
				src.l_hand.talk_into(usr, message)
			L += hearers(1, null)
			obj_range = 1
			italics = 1
		else if (findtext(message, ":w") == 1) //whisper
			message = copytext(message, 3, length(message) + 1)
			L += hearers(1, null)
			obj_range = 1
			italics = 1
		else if (findtext(message, ":i") == 1)
			message = copytext(message, 3, length(message) + 1)
			for(var/obj/item/weapon/radio/intercom/I in view(1, null))
				I.talk_into(usr, message)
			L += hearers(1, null)
			obj_range = 1
			italics = 1
		else
			L += hearers(null, null)
		L -= src
		L += src
		var/turf/T = src.loc
		if (src.stuttering)
			message = stutter(message)
		if (italics)
			message = text("<I>[]</I>", message)
		if (((src.oxygen && src.oxygen.icon_state == "oxy0") || (istype(T, /turf) && T.gas.total_moles > 0)))
			for(var/mob/M in L)
				if (istype(M, src.type) || istype(M, /mob/ai))
					M.show_message(text("<B>[]</B>[]: []", src.rname, alt_name, message), 2)
				else
					M.show_message(text("The human: []", stars(message)), 2)
		for(var/obj/O in view(obj_range, null))
			spawn( 0 )
				if (O)
					O.hear_talk(usr, message)
				return
	for(var/mob/M in world)
		if (M.stat > 1)
			M << text("<B>[]</B>[] []: []", src.rname, alt_name, (src.stat > 1 ? "\[<I>dead</I> \]" : ""), message)
	return