/world/New()
	..()
	crban_loadbanfile()
	crban_updatelegacybans()

	spawn(0)
		SetupOccupationsList()
		return
	return

/mob/human/proc/char_setup()
	if (src.start)
		return
	src.ShowChoices()
	return

/mob/human/proc/ShowChoices()

	var/list/destructive = assistant_occupations.Copy()
	var/dat = "<html><body>"
	dat += "<b>Name:</b> <a href=\"byond://?src=\ref[src];rname=input\"><b>[rname]</b></a> (<A href=\"byond://?src=\ref[src];rname=random\">&reg;</A>)<br>"
	dat += "<b>Gender:</b> <a href=\"byond://?src=\ref[src];gender=input\"><b>[gender == "male" ? "Male" : "Female"]</b></a><br>"
	dat += "<b>Age</b> - <a href='byond://?src=\ref[src];age=input'>[age]</a><hr>"
	dat += "<hr><b>Occupation Choices</b>:<br>"
	if (destructive.Find(occupation1))
		dat += "\t<a href=\"byond://?src=\ref[src];occ=1\"><b>[occupation1]</b></a><br>"
	else
		if (src.occupation1 != "No Preference")
			dat += "\tFirst Choice: <a href=\"byond://?src=\ref[src];occ=1\"><b>[occupation1]</b></a><br>"
			if (destructive.Find(src.occupation2))
				dat += text("\tSecond Choice: <a href=\"byond://?src=\ref[];occ=2\"><b>[]</b></a><BR>", src, src.occupation2)
			else
				if (src.occupation2 != "No Preference")
					dat += text("\tSecond Choice: <a href=\"byond://?src=\ref[];occ=2\"><b>[]</b></a><BR>", src, src.occupation2)
					if (destructive.Find(src.occupation3))
						dat += text("\tLast Choice: <a href=\"byond://?src=\ref[];occ=3\"><b>[]</b></a><BR>", src, src.occupation3)
					else
						if (src.occupation3 != "No Preference")
							dat += text("\tLast Choice: <a href=\"byond://?src=\ref[];occ=3\"><b>[]</b></a><BR>", src, src.occupation3)
						else
							dat += text("\tLast Choice: <a href=\"byond://?src=\ref[];occ=3\">No Preference</a><br>", src)
				else
					dat += text("\tSecond Choice: <a href=\"byond://?src=\ref[];occ=2\">No Preference</a><br>", src)
		else
			dat += text("\t<a href=\"byond://?src=\ref[];occ=1\">No Preference</a><br>", src)
	dat += "<hr><b>Body Data</b><br>"
	dat += text("<b>Blood Type:</b> <a href='byond://?src=\ref[];b_type=input'>[]</a><br>", src, src.b_type)
	dat += text("<b>Skin Tone:</b> <a href='byond://?src=\ref[];ns_tone=input'>[]/220</a><br>", src,  -src.ns_tone + 35)
	dat += text("<b>Hair Color:</b> <font color=\"#[][][]\">test</font><br>", num2hex(src.nr_hair, 2), num2hex(src.ng_hair, 2), num2hex(src.nb_hair))
	dat += text(" <b><font color=\"#[]0000\">Red</font></b> - <a href='byond://?src=\ref[];nr_hair=input'>[]</a>", num2hex(src.nr_hair, 2), src, src.nr_hair)
	dat += text(" <b><font color=\"#00[]00\">Green</font></b> - <a href='byond://?src=\ref[];ng_hair=input'>[]</a>", num2hex(src.ng_hair, 2), src, src.ng_hair)
	dat += text(" <b><font color=\"#0000[]\">Blue</font></b> - <a href='byond://?src=\ref[];nb_hair=input'>[]</a>", num2hex(src.nb_hair, 2), src, src.nb_hair)
	dat += text("<br> <b>Style</b> - <a href='byond://?src=\ref[];h_style=input'>[]</a>", src, src.h_style)
	dat += text("<br><b>Eye Color:</b> <font color=\"#[][][]\">test</font><br>", num2hex(src.r_eyes, 2), num2hex(src.g_eyes, 2), num2hex(src.b_eyes, 2))
	dat += text(" <b><font color=\"#[]0000\">Red</font></b> - <a href='byond://?src=\ref[];r_eyes=input'>[]</a>", num2hex(src.r_eyes, 2), src, src.r_eyes)
	dat += text(" <b><font color=\"#00[]00\">Green</font></b> - <a href='byond://?src=\ref[];g_eyes=input'>[]</a>", num2hex(src.g_eyes, 2), src, src.g_eyes)
	dat += text(" <b><font color=\"#0000[]\">Blue</font></b> - <a href='byond://?src=\ref[];b_eyes=input'>[]</a>", num2hex(src.b_eyes, 2), src, src.b_eyes)
	dat += "<hr><b>Disabilities</b><br>"
	dat += "<hr><i>It is more than likely pretty fucking stupid to enable any of these.</i><br>"
	dat += text("Need Glasses: <a href=\"byond://?src=\ref[];n_gl=1\"><b>[]</b></a><br>", src, (src.need_gl ? "Yes" : "No"))
	dat += text("Epileptic: <a href=\"byond://?src=\ref[];b_ep=1\"><b>[]</b></a><br>", src, (src.be_epil ? "Yes" : "No"))
	dat += text("Tourette Syndrome: <a href=\"byond://?src=\ref[];b_tur=1\"><b>[]</b></a><br>", src, (src.be_tur ? "Yes" : "No"))
	dat += text("Chronic Cough: <a href=\"byond://?src=\ref[];b_co=1\"><b>[]</b></a><br>", src, (src.be_cough ? "Yes" : "No"))
	dat += text("Stutter: <a href=\"byond://?src=\ref[];b_stut=1\"><b>[]</b></a><br>", src, (src.be_stut ? "Yes" : "No"))
	dat += "<hr>"
//	dat += text("Music Toggle: <a href =\"byond://?src=\ref[];b_music=1\"><b>[]</b></a><br>", src, (src.be_music ? "Yes" : "No"))
	dat += text("Be syndicate?: <a href =\"byond://?src=\ref[];b_syndicate=1\"><b>[]</b></a><br>", src, (src.be_syndicate ? "Yes" : "No"))
	dat += text("<a href='byond://?src=\ref[];load=1'>Load Setup</a><br>", src)
	dat += text("<a href='byond://?src=\ref[];save=1'>Save Setup</a><br>", src)
	dat += text("<a href='byond://?src=\ref[];reset_all=1'>Reset Setup</a><br>", src)
	dat += "</body></html>"
	src << browse(dat, "window=mob_occupations;size=300x640")
	return

/mob/human/proc/SetChoices(occ)

	if (occ == null)
		occ = 1
	var/HTML = "<body>"
	HTML += "<tt><center>"
	switch(occ)
		if(1.0)
			HTML += "<b>Which occupation would you like most?</b><br><br>"
		if(2.0)
			HTML += "<b>Which occupation would you like if you couldn't have your first?</b><br><br>"
		if(3.0)
			HTML += "<b>Which occupation would you like if you couldn't have the others?</b><br><br>"
		else
	for(var/job in uniquelist(occupations + assistant_occupations) )
		HTML += text("<a href=\"byond://?src=\ref[];occ=[];job=[]\">[]</a><br>", src, occ, job, job)
	HTML += text("<a href=\"byond://?src=\ref[];occ=[];job=Captain\">Captain</a><br>", src, occ)
	HTML += "<br>"
	HTML += text("<a href=\"byond://?src=\ref[];occ=[];job=No Preference\">\[No Preference\]</a><br>", src, occ)
	HTML += text("<a href=\"byond://?src=\ref[];occ=[];cancel\">\[Cancel\]</a>", src, occ)
	HTML += "</center></tt>"
	usr << browse(HTML, "window=mob_occupation;size=320x500")
	return

/mob/human/proc/SetJob(occ, job)
	if (occ == null)
		occ = 1
	if (job == null)
		job = "Captain"
	if ((!( occupations.Find(job) ) && !( assistant_occupations.Find(job) ) && job != "Captain"))
		return
	switch(occ)
		if(1.0)
			if (job == src.occupation1)
				usr << browse(null, "window=mob_occupation")
				return
			else
				if (job == "No Preference")
					src.occupation1 = "No Preference"
				else
					if (job == src.occupation2)
						job = src.occupation1
						src.occupation1 = src.occupation2
						src.occupation2 = job
					else
						if (job == src.occupation3)
							job = src.occupation1
							src.occupation1 = src.occupation3
							src.occupation3 = job
						else
							src.occupation1 = job
		if(2.0)
			if (job == src.occupation2)
				src << browse(null, "window=mob_occupation")
				return
			else
				if (job == "No Preference")
					if (src.occupation3 != "No Preference")
						src.occupation2 = src.occupation3
						src.occupation3 = "No Preference"
					else
						src.occupation2 = "No Preference"
				else
					if (job == src.occupation1)
						if (src.occupation2 == "No Preference")
							src << browse(null, "window=mob_occupation")
							return
						job = src.occupation2
						src.occupation2 = src.occupation1
						src.occupation1 = job
					else
						if (job == src.occupation3)
							job = src.occupation2
							src.occupation2 = src.occupation3
							src.occupation3 = job
						else
							src.occupation2 = job
		if(3.0)
			if (job == src.occupation3)
				usr << browse(null, "window=mob_occupation")
				return
			else
				if (job == "No Preference")
					src.occupation3 = "No Preference"
				else
					if (job == src.occupation1)
						if (src.occupation3 == "No Preference")
							src << browse(null, "window=mob_occupation")
							return
						job = src.occupation3
						src.occupation3 = src.occupation1
						src.occupation1 = job
					else
						if (job == src.occupation2)
							if (src.occupation3 == "No Preference")
								src << browse(null, "window=mob_occupation")
								return
							job = src.occupation3
							src.occupation3 = src.occupation2
							src.occupation2 = job
						else
							src.occupation3 = job
		else
	src.ShowChoices()
	src << browse(null, "window=mob_occupation")
	return

var/const
	slot_back = 1
	slot_wear_mask = 2
	slot_handcuffed = 3
	slot_l_hand = 4
	slot_r_hand = 5
	slot_belt = 6
	slot_wear_id = 7
	slot_ears = 8
	slot_glasses = 9
	slot_gloves = 10
	slot_head = 11
	slot_shoes = 12
	slot_wear_suit = 13
	slot_w_uniform = 14
	slot_l_store = 15
	slot_r_store = 16
	slot_w_radio = 17
	slot_in_backpack = 18

/mob/human/proc/equip_if_possible(obj/item/weapon/W, slot) // since byond doesn't seem to have pointers, this seems like the best way to do this :/
	//warning: icky code
	var/equipped = 0
	if((slot == l_store || slot == r_store || slot == belt || slot == wear_id) && !src.w_uniform)
		del(W)
		return
	switch(slot)
		if(slot_back)
			if(!src.back)
				src.back = W
				equipped = 1
		if(slot_wear_mask)
			if(!src.wear_mask)
				src.wear_mask = W
				equipped = 1
		if(slot_handcuffed)
			if(!src.handcuffed)
				src.handcuffed = W
				equipped = 1
		if(slot_l_hand)
			if(!src.l_hand)
				src.l_hand = W
				equipped = 1
		if(slot_r_hand)
			if(!src.r_hand)
				src.r_hand = W
				equipped = 1
		if(slot_belt)
			if(!src.belt)
				src.belt = W
				equipped = 1
		if(slot_wear_id)
			if(!src.wear_id)
				src.wear_id = W
				equipped = 1
		if(slot_ears)
			if(!src.ears)
				src.ears = W
				equipped = 1
		if(slot_glasses)
			if(!src.glasses)
				src.glasses = W
				equipped = 1
		if(slot_gloves)
			if(!src.gloves)
				src.gloves = W
				equipped = 1
		if(slot_head)
			if(!src.head)
				src.head = W
				equipped = 1
		if(slot_shoes)
			if(!src.shoes)
				src.shoes = W
				equipped = 1
		if(slot_wear_suit)
			if(!src.wear_suit)
				src.wear_suit = W
				equipped = 1
		if(slot_w_uniform)
			if(!src.w_uniform)
				src.w_uniform = W
				equipped = 1
		if(slot_l_store)
			if(!src.l_store)
				src.l_store = W
				equipped = 1
		if(slot_r_store)
			if(!src.r_store)
				src.r_store = W
				equipped = 1
		if(slot_w_radio)
			if(!src.w_radio)
				src.w_radio = W
				equipped = 1
		if(slot_in_backpack)
			if (src.back && istype(src.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = src.back
				if(B.contents.len < 7 && W.w_class <= 3)
					W.loc = B
					equipped = 1
	if(equipped)
		W.layer = 20
	else
		del(W)


/mob/human/proc/Assign_Rank(rank, joined_late)
	if (rank == "AI")
		var/obj/S = locate(text("start*[]", rank))
		if ((istype(S, /obj/start) && istype(S.loc, /turf)))
			src.loc = S.loc
			src.AIize()
		return
	src.equip_if_possible(new /obj/item/weapon/radio/headset(src), slot_w_radio)
	src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
	if (src.disabilities & 1)
		src.equip_if_possible(new /obj/item/weapon/clothing/glasses/regular(src), slot_glasses)
	var/list/items = GetJobItems(rank)
	for(var/jobitem/i in items)
		src.equip_if_possible(new i.path(src), i.slot)
	var/obj/item/weapon/card/id/C = new /obj/item/weapon/card/id(src)
	C.registered = src.rname
	C.assignment = rank
	C.name = "[C.registered]'s ID Card ([C.assignment])"
	C.access = get_access(C.assignment)
	src.equip_if_possible(C, slot_wear_id)
	src.equip_if_possible(new /obj/item/weapon/pen(src), slot_r_store)
	src.equip_if_possible(new /obj/item/weapon/radio/signaler(src), slot_belt)
	if(rank == "Captain")
		world << "<b>[src] is the captain!</b>"
	src << "<B>You are the [rank].</B>"
	if(!joined_late)
		var/obj/S = null
		for(var/obj/start/sloc in world)
			if (sloc.name != rank)
				continue
			if (locate(/mob) in sloc.loc)
				continue
			S = sloc
			break
		if (!S)
			S = locate("start*[rank]") // use old stype
		if (istype(S, /obj/start) && istype(S.loc, /turf))
			src.loc = S.loc
	return

/proc/AutoUpdateAI(obj/subject)
	if (subject!=null)
		for(var/mob/ai/M in world)
			if ((M.client && M.machine == subject))
				subject.attack_ai(M)

/proc/UpdateInteraction(obj/machine)
	for(var/mob/M)
		if(M.client && M.machine == machine)
			machine:interact(M)