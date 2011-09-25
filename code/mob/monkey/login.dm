/mob/monkey/Login()
	..()
	src.throw_icon = new /obj/screen(null)
	src.oxygen = new /obj/screen( null )
	src.i_select = new /obj/screen( null )
	src.m_select = new /obj/screen( null )
	src.toxin = new /obj/screen( null )
	src.internals = new /obj/screen( null )
	src.mach = new /obj/screen( null )
	src.fire = new /obj/screen( null )
	src.bodytemp = new /obj/screen( null )
	src.healths = new /obj/screen( null )
	src.pullin = new /obj/screen( null )
	src.blind = new /obj/screen( null )
	src.flash = new /obj/screen( null )
	src.hands = new /obj/screen( null )
	src.sleep = new /obj/screen( null )
	src.rest = new /obj/screen( null )

	UpdateClothing()
	src.throw_icon.icon_state = "act_throw_off"
	src.oxygen.icon_state = "oxy0"
	src.i_select.icon_state = "selector"
	src.m_select.icon_state = "selector"
	src.toxin.icon_state = "toxin0"
	src.bodytemp.icon_state = "temp1"
	src.internals.icon_state = "internal0"
	src.mach.icon_state = null
	src.fire.icon_state = "fire0"
	src.healths.icon_state = "health0"
	src.pullin.icon_state = "pull0"
	src.blind.icon_state = "black"
	src.hands.icon_state = "hand"
	src.flash.icon_state = "blank"
	src.sleep.icon_state = "sleep0"
	src.rest.icon_state = "rest0"
	src.hands.dir = NORTH
	src.throw_icon.name = "throw"
	src.oxygen.name = "oxygen"
	src.i_select.name = "intent"
	src.m_select.name = "move"
	src.toxin.name = "toxin"
	src.bodytemp.name = "body temperature"
	src.internals.name = "internal"
	src.mach.name = "Reset Machine"
	src.fire.name = "fire"
	src.healths.name = "health"
	src.pullin.name = "pull"
	src.blind.name = " "
	src.hands.name = "hand"
	src.flash.name = "flash"
	src.sleep.name = "sleep"
	src.rest.name = "rest"
	src.throw_icon.screen_loc = "9,1"
	src.oxygen.screen_loc = "15,12"
	src.i_select.screen_loc = "14,15"
	src.m_select.screen_loc = "14,14"
	src.toxin.screen_loc = "15,10"
	src.internals.screen_loc = "15,14"
	src.mach.screen_loc = "14,1"
	src.fire.screen_loc = "15,8"
	src.bodytemp.screen_loc = "15,6"
	src.healths.screen_loc = "15,5"
	src.sleep.screen_loc = "15,3"
	src.rest.screen_loc = "15,2"
	src.pullin.screen_loc = "15,1"
	src.hands.screen_loc = "1,3"
	src.blind.screen_loc = "1,1 to 15,15"
	src.flash.screen_loc = "1,1 to 15,15"
	src.blind.layer = 0
	src.flash.layer = 17
	src.sleep.layer = 20
	src.rest.layer = 20
	src.client.screen.len = null
	src.client.screen -= list( src.throw_icon, src.oxygen, src.i_select, src.m_select, src.toxin, src.bodytemp, src.internals, src.fire, src.hands, src.healths, src.pullin, src.blind, src.flash, src.rest, src.sleep, src.mach )
	src.client.screen += list( src.throw_icon, src.oxygen, src.i_select, src.m_select, src.toxin, src.bodytemp, src.internals, src.fire, src.hands, src.healths, src.pullin, src.blind, src.flash, src.rest, src.sleep, src.mach )
	src.client.screen -= src.hud_used.adding
	src.client.screen += src.hud_used.adding
	src.client.screen -= src.hud_used.mon_blo
	src.client.screen += src.hud_used.mon_blo
	if (!( src.primary ))
		var/t1 = rand(1000, 1500)
		dna_ident += t1
		if (dna_ident > 65536.0)
			dna_ident = rand(1, 1500)
		src.primary = new /obj/dna( null )
		src.primary.uni_identity = text("[]", dna_ident)
		while(length(src.primary.uni_identity) < 4)
			src.primary.uni_identity = text("0[]", src.primary.uni_identity)
		var/t2 = text("[]", rand(1, 256))
		if (length(t2) < 2)
			src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
		else
			src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
		t2 = text("[]", rand(1, 256))
		if (length(t2) < 2)
			src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
		else
			src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
		t2 = text("[]", rand(1, 256))
		if (length(t2) < 2)
			src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
		else
			src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
		t2 = text("[]", rand(1, 256))
		if (length(t2) < 2)
			src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
		else
			src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
		t2 = (src.gender == "male" ? text("[]", rand(1, 124)) : text("[]", rand(127, 250)))
		if (length(t2) < 2)
			src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
		else
			src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
		src.primary.spec_identity = "2B6696D2B127E5A4"
		src.primary.struc_enzyme = "CDEAF5B90AADBC6BA8033DB0A7FD613FA"
		src.primary.use_enzyme = "C8FFFE7EC09D80AEDEDB9A5A0B4085B61"
		src.primary.n_chromo = 16
	if (!src.start)
		src.start = 1
		var/A = locate(/area/start)
		var/list/L = list(  )
		for(var/turf/T in A)
			if(T.isempty() )
				L += T
		src.loc = pick(L)

	if (!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	src.name = text("monkey ([])", copytext(md5(src.primary.uni_identity), 2, 6))
	return