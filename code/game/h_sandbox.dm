var
	hsboxspawn = 1
	list
		hrefs = list(
					"hsbsuit" = "Suit Up (Space Travel Gear)",
					"hsbmetal" = "Spawn 50 Metal",
					"hsbglass" = "Spawn 50 Glass",
					"hsbairlock" = "Spawn Airlock",
					"hsbregulator" = "Spawn Air Regulator",
					"hsbfilter" = "Spawn Air Filter",
					"hsbcanister" = "Spawn Canister",
					"hsbfueltank" = "Spawn Welding Fuel Tank",
					"hsbwatertank" = "Spawn Water Tank",
					"hsbtoolbox" = "Spawn Toolbox",
					"hsbmedkit" = "Spawn Medical Kit")

mob
	var
		datum/hSB/sandbox = null
	proc
		CanBuild()
			if(master_mode == "sandbox")
				sandbox = new/datum/hSB
				sandbox.owner = src.ckey
				if(src.client.holder)
					sandbox.admin = 1
				verbs += new/mob/proc/sandbox_panel
		sandbox_panel()
			if(sandbox)
				sandbox.update()

datum/hSB
	var
		owner = null
		admin = 0
	proc
		update()
			var/hsbpanel = "<center><b>h_Sandbox Panel</b></center><hr>"
			if(admin)
				hsbpanel += "<b>Administration Tools:</b><br>"
				hsbpanel += "- <a href=\"?\ref[src];hsb=hsbtobj\">Toggle Object Spawning</a><br><br>"
			hsbpanel += "<b>Regular Tools:</b><br>"
			for(var/T in hrefs)
				hsbpanel += "- <a href=\"?\ref[src];hsb=[T]\">[hrefs[T]]</a><br>"
			if(hsboxspawn)
				hsbpanel += "- <a href=\"?\ref[src];hsb=hsbobj\">Spawn Object</a><br><br>"
			usr << browse(hsbpanel, "window=hsbpanel")
	Topic(href, href_list)
		if(!(src.owner == usr.ckey)) return
		if(!usr) return //I guess this is possible if they log out or die with the panel open? It happened.
		if(href_list["hsb"])
			switch(href_list["hsb"])
				if("hsbtobj")
					if(!admin) return
					if(hsboxspawn)
						world << "<b>Sandbox:  [usr.key] has disabled object spawning!</b>"
						hsboxspawn = 0
						return
					if(!hsboxspawn)
						world << "<b>Sandbox:  [usr.key] has enabled object spawning!</b>"
						hsboxspawn = 1
						return
				if("hsbsuit")
					var/mob/human/P = usr
					if(P.wear_suit)
						P.wear_suit.loc = P.loc
						P.wear_suit.layer = initial(P.wear_suit.layer)
						P.wear_suit = null
					P.wear_suit = new/obj/item/weapon/clothing/suit/sp_suit(P)
					P.wear_suit.layer = 20
					if(P.head)
						P.head.loc = P.loc
						P.head.layer = initial(P.head.layer)
						P.head = null
					P.head = new/obj/item/weapon/clothing/head/s_helmet(P)
					P.head.layer = 20
					if(P.wear_mask)
						P.wear_mask.loc = P.loc
						P.wear_mask.layer = initial(P.wear_mask.layer)
						P.wear_mask = null
					P.wear_mask = new/obj/item/weapon/clothing/mask/gasmask(P)
					P.wear_mask.layer = 20
					if(P.back)
						P.back.loc = P.loc
						P.back.layer = initial(P.back.layer)
						P.back = null
					P.back = new/obj/item/weapon/tank/jetpack(P)
					P.back.layer = 20
					P.internal = P.back
				if("hsbmetal")
					var/obj/item/weapon/sheet/hsb = new/obj/item/weapon/sheet/metal
					hsb.amount = 50
					hsb.loc = usr.loc
				if("hsbglass")
					var/obj/item/weapon/sheet/hsb = new/obj/item/weapon/sheet/glass
					hsb.amount = 50
					hsb.loc = usr.loc
				if("hsbairlock")
					var/obj/machinery/door/hsb = new/obj/machinery/door/airlock

					//TODO: make this better, with an HTML window or something instead of 15 popups
					hsb.req_access = list()
					var/accesses = get_all_accesses()
					for(var/A in accesses)
						if(alert(usr, "Will this airlock require [get_access_desc(A)] access?", "Sandbox:", "Yes", "No") == "Yes")
							hsb.req_access += A

					hsb.loc = usr.loc
					hsb.loc.buildlinks()
					usr << "<b>Sandbox:  Created an airlock."
				if("hsbregulator")
					var/obj/machinery/atmoalter/siphs/fullairsiphon/hsb = new/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent
					hsb.loc = usr.loc
				if("hsbfilter")
					var/obj/machinery/atmoalter/siphs/scrubbers/hsb = new/obj/machinery/atmoalter/siphs/scrubbers/air_filter
					hsb.loc = usr.loc
				if("hsbcanister")
					var/list/hsbcanisters = typesof(/obj/machinery/atmoalter/canister/) - /obj/machinery/atmoalter/canister/
					var/hsbcanister = input(usr, "Choose a canister to spawn.", "Sandbox:") in hsbcanisters + "Cancel"
					if(!(hsbcanister == "Cancel"))
						new hsbcanister(usr.loc)
				if("hsbfueltank")
					var/obj/hsb = new/obj/largetank/weldfuel
					hsb.loc = usr.loc
				if("hsbwatertank")
					var/obj/hsb = new/obj/largetank/water
					hsb.loc = usr.loc
				if("hsbtoolbox")
					var/obj/item/weapon/storage/hsb = new/obj/item/weapon/storage/toolbox
					for(var/obj/item/weapon/radio/T in hsb)
						del(T)
					new/obj/item/weapon/crowbar (hsb)
					hsb.loc = usr.loc
				if("hsbmedkit")
					var/obj/item/weapon/storage/firstaid/hsb = new/obj/item/weapon/storage/firstaid/regular
					hsb.loc = usr.loc
				if("hsbobj")
					if(!hsboxspawn) return
					var/list/hsbitems = typesof(/obj/) - typesof(/obj/examine, /obj/item/weapon/organ, /obj/admins, /obj/mark, /obj/machinery/nuclearbomb, /obj/datacore, /obj/begin, /obj/beam/, /obj/list_container/, /obj/landmark, /obj/manifest, /obj/effects/, /obj/overlay, /obj/point, /obj/screen/, /obj/shut_controller, /obj/portal,  /obj/barrier, /obj/machinery/shuttle,  /obj/bomb, /obj/bullet, /obj/bullet/electrode, /obj/dna, /obj/equip_e, /obj/equip_e/human, /obj/equip_e/monkey, /obj/hud, /obj/item, /obj/item/weapon/assembly/m_i_ptank, /obj/item/weapon/assembly/prox_ignite, /obj/item/weapon/assembly/r_i_ptank, /obj/item/weapon/assembly/time_ignite, /obj/item/weapon/assembly/t_i_ptank, /obj/laser) + typesof(/obj/item/weapon/card)
					var/hsbitem = input(usr, "Choose an object to spawn.", "Sandbox:") in hsbitems + "Cancel"
					if(!(hsbitem == "Cancel"))
						new hsbitem(usr.loc)