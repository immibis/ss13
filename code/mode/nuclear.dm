/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"

/datum/game_mode/nuclear/announce()
	world << "<B>The current game mode is - Nuclear Emergency!</B>"
	world << "<B>A Syndicate Strike Force is approaching SS13!</B>"
	world << "A nuclear explosive was being transported by Nanotrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around SS13. It was identified by Nanotrasen as a nuclear auth. disk and now Syndicate Operatives have arrived to retake the disk and detonate SS13! Also, most likely Syndicate star ships are in the vicinity so take care not to lose the disk!\n<B>Syndicate</B>: Reclaim the disk and detonate the nuclear bomb anywhere on SS13.\n<B>Personnel</B>: Hold the disk and <B>escape with the disk</B> on the shuttle!"

/datum/game_mode/nuclear/pre_setup()
	var/list/mobs = list(  )
	var/list/synd_list = list ()
	for(var/mob/human/H in world)
		if (H.client && H.start)
			mobs += H
			if(H.be_syndicate)
				synd_list += H
	var/obj/O = locate("landmark*Syndicate-Spawn")
	var/amount = 1
	if (mobs.len >= 4)
		amount = round((mobs.len - 1) / 3) + 1

	amount = min(5, amount)
	while(amount > 0)
		amount--
		var/mob/human/H = null
		if(synd_list.len < 1)
			H = pick(mobs)
		else
			H = pick(synd_list)
			synd_list -= H
		mobs -= H
		if (istype(H, /mob/human))
			H.loc = O.loc
			if (ticker.killer)
				H.rname = text("Syndicate Operative #[]", amount + 1)
			else
				H.rname = "Syndicate Leader"
				ticker.killer = H
			H.already_placed = 1
			//H.jumpsuit = null
			del(H.wear_suit)
			H.w_uniform = new /obj/item/weapon/clothing/under/black( H )
			H.w_uniform.layer = 20
			//H.shoes = null
			del(H.shoes)
			H.wear_suit = new /obj/item/weapon/clothing/suit/heavy_armor( H )
			H.wear_suit.layer = 20
			H.shoes = new /obj/item/weapon/clothing/shoes/black( H )
			H.shoes.layer = 20
			H.gloves = new /obj/item/weapon/clothing/gloves/swat( H )
			H.gloves.layer = 20
			H.head = new /obj/item/weapon/clothing/head/helmet/swat_hel( H )
			H.head.layer = 20
			H.glasses = new /obj/item/weapon/clothing/glasses/sunglasses( H )
			H.glasses.layer = 20
			H.back = new /obj/item/weapon/storage/backpack( H )
			H.back.layer = 20
			var/obj/item/weapon/ammo/a357/W = new /obj/item/weapon/ammo/a357( H.back )
			W.layer = 20
			W = new /obj/item/weapon/m_pill/cyanide( H.back )
			W.layer = 20
			var/obj/item/weapon/gun/revolver/G = new /obj/item/weapon/gun/revolver( H )
			G.bullets = 7
			G.layer = 20
			H.belt = G
			var/obj/item/weapon/radio/R = new /obj/item/weapon/radio/headset( H )
			R.freq = 146.5
			R.layer = 20
			H.w_radio = R

/datum/game_mode/nuclear/post_setup()
	spawn (50)
		var/obj/L = locate("landmark*Nuclear-Disk")
		if (L)
			new /obj/item/weapon/disk/nuclear(L.loc)

		L = locate("landmark*Nuclear-Closet")
		if (L)
			new /obj/closet/syndicate/nuclear(L.loc)

		L = locate("landmark*Nuclear-Bomb")
		if (L)
			var/obj/machinery/nuclearbomb/NB = new /obj/machinery/nuclearbomb(L.loc)
			NB.r_code = text("[]", rand(10000, 99999.0))
			if (ticker.killer)
				ticker.killer.memory += text("<B>Syndicate Nuclear Bomb Code</B>: []<BR>", NB.r_code)
				ticker.killer << text("The nuclear authorization code is: <B>[]</B>\]", NB.r_code)
				ticker.killer << text("Nuclear Explosives 101:\n\tHello and thank you for choosing the Syndicate for your nuclear information needs.\nToday's crash course will deal with the operation of a Fusion Class Nanotrasen made Nuclear Device.\nFirst and foremost, DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.\nPressing any button on the compacted bomb will cause it to extend and bolt itself into place.\nIf this is done to unbolt it one must compeltely log in which at this time may not be possible.\nTo make the device functional:\n1. Place bomb in designated detonation zone\n2. Extend and anchor bomb (attack with hand).\n3. Insert Nuclear Auth. Disk into slot.\n4. Type numeric code into keypad ([]).\n\tNote: If you make a mistake press R to reset the device.\n5. Press the E button to log onto the device\nYou now have activated the device. To deactivate the buttons at anytime for example when\nyou've already prepped the bomb for detonation remove the auth disk OR press the R ont he keypad.\nNow the bomb CAN ONLY be detonated using the timer. A manual det. is not an option.\n\tNote: Nanotrasen is a pain in the neck.\nToggle off the SAFETY.\n\tNote: You wouldn't believe how many Syndicate Operatives with doctorates have forgotten this step\nSo use the - - and + + to set a det time between 5 seconds and 10 minutes.\nThen press the timer toggle button to start the countdown.\nNow remove the auth. disk so that the buttons deactivate.\n\tNote: THE BOMB IS STILL SET AND WILL DETONATE\nNow before you remvoe the disk if you need to mvoe the bomb you can:\nToggle off the anchor, move it, and re-anchor.\n\nGood luck. Remember the order:\nDisk, Code, Safety, Timer, Disk, RUN\nGood luck.\nIntelligence Analysts believe that they are hiding the disk in the control room emergency room", NB.r_code)
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(ticker.killer.loc)
				P.info = text("The nuclear authorization code is: <b>[]</b>", NB.r_code)
				P.name = "nuclear bomb code"

		for (var/obj/landmark/A in world)
			if (A.name == "Syndicate-Gear-Closet")
				new /obj/closet/syndicate/personal(A.loc)
				del(A)
				continue

			if (A.name == "Syndicate-Bomb")
				var/obj/item/weapon/assembly/t_i_ptank/R = new /obj/item/weapon/assembly/t_i_ptank(A.loc )
				var/obj/item/weapon/timer/p1 = new /obj/item/weapon/timer(R)
				var/obj/item/weapon/igniter/p2 = new /obj/item/weapon/igniter(R)
				var/obj/item/weapon/tank/plasmatank/p3 = new /obj/item/weapon/tank/plasmatank(R)
				R.part1 = p1
				R.part2 = p2
				R.part3 = p3
				p1.master = R
				p2.master = R
				p3.master = R
				R.status = 1
				p3.gas.temperature = 650 +T0C
				p2.status = 1
				del(A)
				continue

	spawn (0)
		ticker.extend_process()

/datum/game_mode/nuclear/check_win()
	var/area/A = locate(/area/shuttle)

	if (ticker.objective != "Success")
		var/disk_on_shuttle = 0
		for(var/obj/item/weapon/disk/nuclear/N in world)
			if (N.loc)
				var/turf/T = get_turf(N)
				if ((T in A))
					disk_on_shuttle = 1
			//Foreach goto(1327)
		if (disk_on_shuttle)
			world << "<FONT size = 3><B>The Research Staff has stopped the Syndicate Operatives!</B></FONT>"
			for(var/mob/human/H in world)
				if ((H.client && !( findtext(H.rname, "Syndicate ", 1, null) )))
					if (H.stat != 2)
						world << text("<B>[] was []</B>", H.key, H.rname)
					else
						world << text("[] was [] (Dead)", H.key, H.rname)
				//Foreach goto(1414)
		else
			world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
			world << "<B>The Syndicate recovered the abandoned auth. disk but detonation of SS13 was averted.</B> Next time, don't lose the disk!"
	return 1