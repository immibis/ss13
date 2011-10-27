/proc/messageadmins(text as text)
	for(var/mob/M in world)
		if(M && M.client && M.client.holder)
			M << "[text]"

var/list/adminranks = list(
	/obj/admins/verb/force_restart_vote = list("Moderator", "Administrator", "Primary Administrator"),
	/obj/admins/verb/force_mode_vote = list("Moderator", "Administrator", "Primary Administrator"),
	/obj/admins/verb/abort_vote = list("Moderator", "Administrator", "Primary Administrator"),
	/obj/admins/verb/toggle_restart_vote = list("Administrator", "Primary Administrator"),
	/obj/admins/verb/toggle_mode_vote = list("Administrator", "Primary Administrator"),
	/obj/admins/verb/boot_player = list("Moderator", "Administrator", "Primary Administrator"),
	/obj/admins/verb/manage_bans = list("Administrator", "Primary Administrator"),
	"ban admins" = list("Primary Administrator"),
	"boot admins" = list("Primary Administrator"),
	/obj/admins/verb/manage_mutes = list("Moderator", "Administrator", "Primary Administrator"),
	"mute admins" = list("Primary Administrator"),
	/obj/admins/verb/restart_world = list("Administrator", "Primary Administrator"),
	/obj/admins/verb/restart_world_now = list("Administrator", "Primary Administrator"),
	/obj/admins/verb/force_mode_change = list("Moderator", "Administrator", "Primary Administrator"),
	/obj/admins/verb/list_banned_keys = list("Moderator", "Administrator", "Primary Administrator"),
	/obj/admins/verb/list_keys = list("Moderator", "Administrator", "Primary Administrator"),
	"monkeyize" = list("Administrator", "Primary Administrator"),
	"force speech" = list("Primary Administrator"),
	"send to prison" = list("Administrator", "Primary Administrator"),
	/obj/admins/verb/list_players = list("Moderator", "Administrator", "Primary Administrator"),
	/obj/admins/verb/announce = list("Moderator", "Administrator", "Primary Administrator"),
	/obj/admins/verb/privmsg = list("Moderator", "Administrator", "Primary Administrator"),
	/obj/admins/verb/create_object = list("Administrator", "Primary Administrator"),
	/obj/admins/verb/delay_round_start = list("Administrator", "Primary Administrator"),
	/obj/admins/verb/use_secret = list("Administrator", "Primary Administrator"),
	/obj/admins/verb/toggle_respawn = list("Administrator", "Primary Administrator"),
	/obj/admins/verb/show_dna = list("Administrator", "Primary Administrator"),
	/obj/admins/verb/toggle_ooc = list("Moderator", "Administrator", "Primary Administrator"),
	/obj/admins/verb/start_now = list("Administrator", "Primary Administrator"),
	/obj/admins/verb/toggle_enter = list("Administrator", "Primary Administrator")
	)

obj/admins/verb
	force_restart_vote()
		set category = "Admin"
		StartVote(usr, RESTART_VOTE, 1)
		if(vote.mode == RESTART_VOTE)
			world.log_admin("Voting to restart forced by admin [usr.key]")

	force_mode_vote()
		set category = "Admin"
		StartVote(usr, CHANGE_MODE_VOTE, 1)
		if(vote.mode == CHANGE_MODE_VOTE)
			world.log_admin("Voting to change mode forced by admin [usr.key]")

	abort_vote()
		set category = "Admin"
		if(!vote.voting)
			return

		world << "\red <B>***Voting aborted by [usr.key].</B>"
		world.log_admin("Voting aborted by [usr.key]")

		vote.voting = 0
		vote.nextvotetime = world.timeofday + 10*config.vote_delay

		for(var/mob/M in world)		// clear vote window from all clients
			if(M.client)
				M << browse(null, "window=vote")
				M.client.showvote = 0

	toggle_restart_vote(var/v as anything in list("on", "off"))
		set category = "Admin"
		config.allow_vote_restart = (v == "on")
		world << "<B>Player restart voting toggled to [config.allow_vote_restart ? "On" : "Off"]</B>."

		world.log_admin("Restart voting toggled to [config.allow_vote_restart ? "On" : "Off"] by [usr.key].")

		if(config.allow_vote_restart)
			vote.nextvotetime = world.timeofday

	toggle_mode_vote(var/v as anything in list("on", "off"))
		set category = "Admin"
		config.allow_vote_mode = (v == "on")
		world << "<B>Player mode voting toggled to [config.allow_vote_mode ? "On" : "Off"]</B>."
		world.log_admin("Mode voting toggled to [config.allow_vote_mode ? "On" : "Off"] by [usr.key].")

		if(config.allow_vote_mode)
			vote.nextvotetime = world.timeofday

	boot_player()
		set category = "Admin"
		var/dat = "<B>Boot Player:</B><HR>"
		for(var/mob/M in world)
			dat += "<A href='?src=\ref[src];boot2=\ref[M]'>N:[M.name] R:[M.rname] (K:[M.client ? M.client : "No client"]) (IP:[M.lastKnownIP])</A><BR>"
		usr << browse(dat, "window=boot")

	/obj/admins/Topic(href, href_list)
		if("boot2" in href_list)
			var/mob/M = locate(href_list["boot2"])
			if (ismob(M))
				if(M.client && M.client.holder && !(src.rank in adminranks["boot admins"]))
					usr << "\red You do not have a high enough rank to boot other admins."
					return
				world.log_admin("[usr.key] booted [M.key]/[M.rname].")
				messageadmins("\blue[usr.key] booted [M.key]/[M.rname].")
				del(M.client)
		else
			. = ..()

	manage_bans()
		set category = "Admin"
		var/dat = "<B>Ban Player:</B><HR>"
		for(var/mob/M in world)
			dat += text("<A href='?src=\ref[];ban2=\ref[]'>N: <B>[]</B> R: [] (K: []) (IP: [])</A><BR>", src, M, M.name, M.rname, (M.client ? M.client : "No client"), M.lastKnownIP)
		dat += "<HR><B>Unban Player:</B><HR>"
		for(var/t in crban_keylist)
			dat += "<A href='?src=\ref[src];unban2=[ckey(t)]'>K: <B>[t]</B> (IP: [crban_keylist[ckey(t)]]) (Time: [crban_time[ckey(t)]]) (By: [crban_bannedby[ckey(t)]]) (Reason: [crban_reason[ckey(t)]])</A><BR>"
		dat += "<HR><B>Caught IP's:</B><HR>"
		for(var/t in crban_iplist)
			dat += "IP: [t] (N: [crban_iplist[t]])<BR>"
		dat += "<HR><B>Unbanned Key's: (Safe to remove from this list once they have rejoined once!)</B><HR>"
		for(var/t in crban_unbanned)
			dat += "<A href='?src=\ref[src];ununban=[ckey(t)]'>N: [t] (By: [crban_unbanned[ckey(t)]])</A><BR>"
		usr << browse(dat, "window=ban;size=800x600")

	/obj/admins/Topic(href, href_list)
		if(href_list["ununban"])	//NOTE THIS SAYS UNUNBAN. As in un unban them. unbanananananana!
			var/t = href_list["ununban"]
			if(t && crban_isunbanned(t))
				world.log_admin("[usr.key] removed [t]'s unban.")
				messageadmins("\blue[usr.key] removed [t]'s unban.")
				crban_removeunban(t)
				manage_bans()
		else if(href_list["ban2"])
			var/mob/M = locate(href_list["ban2"])
			if (ismob(M))
				if (M.client && M.client.holder && !(src.rank in adminranks["ban admins"]))
					usr << "\red You do not have a high enough rank to ban other admins."
					return
				if (crban_isbanned(M))
					alert("You cannot perform this action. [M] is already banned!")
					return
				var/banreason = input("Enter a reason for this ban. Enter nothing to cancel.", "Ban: [M]", "")
				banreason = copytext(sanitize(banreason), 1, MAX_MESSAGE_LEN)
				if(!banreason)	//so you can go back on banning someone
					return
				world.log_admin("[usr.key] banned [M.key]/[M.rname]. Reason: [banreason]")
				messageadmins("\blue[usr.key] banned [M.key]/[M.rname]. Reason: [banreason]")
				crban_fullban(M, banreason, usr.ckey)
				manage_bans()
		else if(href_list["unban2"])
			var/t = href_list["unban2"]
			if(t && crban_isbanned(t))
				world.log_admin("[usr.key] unbanned [t].")
				messageadmins("\blue[usr.key] unbanned [t]")
				crban_unban(t, usr.ckey)
				manage_bans()
		else . = ..()

	manage_mutes()
		set category = "Admin"
		var/dat = "<B>Mute/Unmute Player:</B><HR>"
		for(var/mob/M in world)
			dat += "<A href='?src=\ref[src];mute2=\ref[M]'>N:[M.name] R:[M.rname] (K:[M.client ? M.client : "No client"]) (IP: [M.lastKnownIP]) \[[M.muted ? "Muted" : "Voiced"]\]</A><BR>"
		usr << browse(dat, "window=mute")

	/obj/admins/Topic(href, href_list)
		if (href_list["mute2"])
			if ((src.rank in list( "Moderator", "Administrator", "Primary Administrator" )))
				var/mob/M = locate(href_list["mute2"])
				if (ismob(M))
					if(M.muted && M.client && M.client.holder && !(src.rank in adminranks["mute admins"]))
						usr << "\red You do not have a high enough rank to mute other admins."
						return
					world.log_admin("[usr.key] altered [M.key]/[M.rname]'s mute status.")
					messageadmins("\blue[usr.key] altered [M.key]/[M.rname]'s mute status.")
					M.muted = !M.muted
					manage_mutes()
		else
			. = ..()

	restart_world()
		set category = "Admin"
		if(input("Are you sure?", "Restart world in 5 seconds") as null|anything in list("Yes", "No") == "Yes")
			world << "\red The world will restart in 5 seconds thanks to [usr.key]."
			world.log_admin("[usr.key] initiated a reboot in 5 seconds.")
			sleep(50)
			world.Reboot()

	restart_world_now()
		set category = "Admin"
		if(input("Are you sure?", "Restart world immediately") as null|anything in list("Yes", "No") == "Yes")
			world << "\red The world will restart immediately thanks to [usr.key]."
			world.log_admin("[usr.key] initiated a reboot immediately.")
			world.Reboot()

	force_mode_change(var/newmode as anything in list("secret", "random", "traitor", "meteor", "extended", "monkey", "nuclear", "blob", "sandbox", "restructuring"))
		set category = "Admin"
		var/F = file(persistent_file)
		fdel(F)
		F << master_mode
		master_mode = newmode
		world.log_admin("[usr.key] changed the mode to [master_mode]")
		messageadmins("\blue[usr.key] changed the mode to [master_mode]")
		world << "\blue <B>The mode is now: [master_mode]"
		if(ticker)
			world.log_admin("Rebooting world to change mode")
			world << "\blue Rebooting world in 5 seconds."
			sleep(50)
			world.Reboot()

	list_banned_keys()
		set category = "Admin"
		var/dat = "<HR><B>Banned Keys:</B><HR>"
		for(var/t in crban_keylist)
			dat += "[ckey(t)]<BR>"
		usr << browse(dat, "window=ban_k")

	list_keys()
		set category = "Admin"
		var/dat = "<B>Keys:</B><HR>"
		for(var/mob/M in world)
			if (M.client)
				dat += "[M.client.ckey]<BR>"
		usr << browse(dat, "window=keys")

	/obj/admins/Topic(href, href_list)
		if (href_list["monkeyone"])
			if (src.rank in adminranks["monkeyize"])
				var/mob/M = locate(href_list["monkeyone"])
				if(!ismob(M))	return
				if(istype(M, /mob/human))
					var/mob/human/N = M
					world.log_admin("[usr.key] attempting to monkeyize [M.name]")
					messageadmins("\blue[usr.key] attempting to monkeyize [M.key]/[M.rname]")
					N.monkeyize()
					href_list["l_players"] = 1 // lets it fall through and refresh
				if(istype(M, /mob/ai))
					alert("The AI can't be monkeyized!", null, null, null, null, null)
					return
			else
				alert("You do not have the rank required to perform this action.")
		else if (href_list["forcespeech"])
			if (src.rank in adminranks["force speech"])
				var/mob/M = locate(href_list["forcespeech"])
				if (ismob(M))
					var/speech = input("What will [M.key]/[M.rname] say?.", "Force speech", "")
					M.say(speech)
					speech = copytext(sanitize(speech), 1, MAX_MESSAGE_LEN)
					world.log_admin("[usr.key] forced [M.key]/[M.rname] to say: [speech]")
					messageadmins("\blue[usr.key] forced [M.key]/[M.rname] to say: [speech]")
					href_list["l_players"] = 1 // lets it fall through and refresh
			else
				alert("You do not have the rank required to perform this action.")
		else if (href_list["sendtoprison"])
			if (src.rank in adminranks["send to prison"])
				var/mob/M = locate(href_list["sendtoprison"])
				if (ismob(M))
					if(istype(M, /mob/ai))
						alert("The AI can't be sent to prison you jerk!", null, null, null, null, null)
						return
					//strip their stuff before they teleport into a cell :downs:
					for(var/obj/item/W in M)
						if(istype(W, /obj/item/organ/external))	continue	//don't strip organs
						M.unequip(W)
						if (M.client)
							M.client.screen -= W
						if (W)
							W.loc = M.loc
							W.dropped(M)
							W.layer = initial(W.layer)
					//teleport person to cell
					M.paralysis += 5
					sleep(5)	//so they black out before warping
					M.loc = pick(prisonwarp)
					if(istype(M, /mob/human))
						var/mob/human/prisoner = M
						prisoner.equip_if_possible(new /obj/item/clothing/under/orange(prisoner), slot_w_uniform)
						prisoner.equip_if_possible(new /obj/item/clothing/shoes/orange(prisoner), slot_shoes)
					spawn(50)	M << "\red You have been sent to the prison station!"
					world.log_admin("[usr.key] sent [M.key]/[M.rname] to the prison station.")
					messageadmins("\blue[usr.key] sent [M.key]/[M.rname] to the prison station.")
					href_list["l_players"] = 1 // lets it fall through and refresh
			else
				alert("You do not have the rank required to perform this action.")
		else
			. = ..()

	list_players()
		set category = "Admin"
		var/dat = "<B>Name/Real Name/Key/IP:</B><HR>"
		for(var/mob/M in world)
			var/foo = ""
			if (ismob(M) && M.client)
				if(M.z != 2)
					foo += text("<A HREF='?src=\ref[];sendtoprison=\ref[]'>Prison</A> | ", src, M)
				else
					foo += text("<B>At Prison</B> | ")
				if(!istype(M, /mob/monkey))
					if(M.start)
						foo += text("<A HREF='?src=\ref[];monkeyone=\ref[]'>Monkeyize</A> | ", src, M)
					else
						foo += "Not in game yet | "
				else
					foo += text("<B>Monkeyized</B> | ")
				foo += text("<A HREF='?src=\ref[];forcespeech=\ref[]'>Say</A> \]", src, M)
			dat += text("N: [] R: [] (K: []) (IP: []) []<BR>", M.name, M.rname, (M.client ? M.client : "No client"), M.lastKnownIP, foo)

		usr << browse(dat, "window=players;size=800x480")

	announce(msg as text)
		set category = "Admin"
		world << "\blue <B>[usr.key] Announces:</B>\n \t [msg]"
		world.log_admin("[usr.key] announces: [msg]")

	privmsg(mob/M as mob in world, msg as text)
		set category = "Admin"
		if (usr.client && usr.client.holder)
			M << "\blue Admin PM from-<B><A href='?src=\ref[M];priv_msg=\ref[usr]'>[usr.key]</A></B>: [msg]"
			usr << "\blue Admin PM to-<B><A href='?src=\ref[usr];priv_msg=\ref[M]'>[M.key]</A></B>: [msg]"
		else
			M << "\blue Reply PM from-<B><A href='?src=\ref[M];priv_msg=\ref[usr]'>[usr.key]</A></B>: [msg]"
			usr << "\blue Reply PM to-<B><A href='?src=\ref[usr];priv_msg=\ref[M]'>[M.key]</A></B>: [msg]"

		world.log_admin("PM: [usr.key]->[M.key] : [msg]")
		for(var/mob/K in world)	//we don't use messageadmins here because the sender/receiver might get it too
			if(K && K.client && K.client.holder && K.key != usr.key && K.key != M.key)
				K << "<B><font color='blue'>PM: <A href='?src=\ref[M];priv_msg=\ref[usr]'>[usr.key]</A>-&gt;<A href='?src=\ref[usr];priv_msg=\ref[M]'>[M.key]</A>:</B> \blue [msg]</font>"

	create_object()
		set category = "Admin"
		return DisplayMenu(usr)

	/obj/admins/Topic(href, href_list)
		if (href_list["ObjectList"])
			if ((src.rank in list( "Administrator", "Primary Administrator" )))
				var/atom/loc = usr.loc
				var/object = href_list["ObjectList"]
				var/list/offset = dd_text2list(href_list["offset"],",")
				var/number = dd_range(1,100,text2num(href_list["number"]))
				var/X = ((offset.len>0)?text2num(offset[1]) : 0)
				var/Y = ((offset.len>1)?text2num(offset[2]) : 0)
				var/Z = ((offset.len>2)?text2num(offset[3]) : 0)

				for(var/i = 1 to number)
					switch(href_list["otype"])
						if("absolute")
							new object(locate(0+X,0+Y,0+Z))
						if("relative")
							if(loc)
								new object(locate(loc.x+X,loc.y+Y,loc.z+Z))
						else
							return
				if(number == 1)
					world.log_admin("[usr.key] created \a [object]")
				else
					world.log_admin("[usr.key] created [number] of [object]")
		else
			. = ..()

	show_dna()
		set category = "Admin"
		var/dat = "<B>Registered DNA sequences:</B><HR>"
		for(var/M in reg_dna)
			dat += text("\t [] = []<BR>", M, reg_dna[text("[]", M)])
		usr << browse(dat, "window=dna")

	toggle_ooc(var/v as anything in list("on", "off"))
		set category = "Admin"
		ooc_allowed = (v == "on")
		if (ooc_allowed)
			world << "<B>The OOC channel has been globally enabled!</B>"
		else
			world << "<B>The OOC channel has been globally disabled!</B>"
		world.log_admin("[usr.key] toggled OOC.")
		messageadmins("<font color='blue'>[usr.key] toggled OOC.</font>")

	start_now()
		set category = "Admin"
		world << "<B>The game will now start immediately thanks to [usr.key]!</B>"
		going = 1
		if (!ticker)
			ticker = new /datum/control/gameticker()
			spawn (0)
				world.log_admin("[usr.key] started the round immediately")
				ticker.process()
			data_core = new /obj/datacore()

	toggle_enter(var/v as anything in list("on", "off"))
		set category = "Admin"
		enter_allowed = (v == "on")
		if (!( enter_allowed ))
			world << "<B>You may no longer enter the game.</B>"
		else
			world << "<B>You may now enter the game.</B>"
		world.log_admin("[usr.key] toggled new player game entering.")
		messageadmins("\blue[usr.key] toggled new player game entering.")
		world.update_stat()

	toggle_respawn(var/v as anything in list("on", "off"))
		set category = "Admin"
		abandon_allowed = (v == "on")
		if (abandon_allowed)
			world << "<B>You may now respawn.</B>"
		else
			world << "<B>You may no longer respawn :(</B>"
		messageadmins("\blue[usr.key] toggled respawn to [abandon_allowed ? "On" : "Off"].")
		world.log_admin("[usr.key] toggled respawn to [abandon_allowed ? "On" : "Off"].")
		world.update_stat()

	delay_round_start()
		set category = "Admin"
		if (ticker)
			return alert("Too late... The game has already started!", null, null, null, null, null)
		going = !( going )
		if (!( going ))
			world << text("<B>The game start has been delayed by [] (Administrator to SS13)</B>", usr.key)
			world.log_admin("[usr.key] delayed the game.")
		else
			world << text("<B>The game will start soon thanks to [] (Administrator to SS13)</B>", usr.key)
			world.log_admin("[usr.key] removed the delay.")

	use_secret()
		set category = "Admin"
		var/dat = {"
<B>What secret do you wish to activate?</B><HR>
<A href='?src=\ref[src];secrets2=sec_clothes'>Remove 'internal' clothing</A><BR>
<A href='?src=\ref[src];secrets2=sec_all_clothes'>Remove ALL clothing</A><BR>
<A href='?src=\ref[src];secrets2=toxic'>Toxic Air (WARNING: dangerous)</A><BR>
<A href='?src=\ref[src];secrets2=monkey'>Turn all humans into monkies</A><BR>
<A href='?src=\ref[src];secrets2=sec_classic1'>Remove firesuits, grilles, and pods</A><BR>
<A href='?src=\ref[src];secrets2=clear_bombs'>Remove all bombs currently  existence</A><BR>
<A href='?src=\ref[src];secrets2=list_bombers'>Show a list of all people who made a bomb</A><BR>
<A href='?src=\ref[src];secrets2=list_signalers'>Show last [length(lastsignalers)] signalers</A><BR>
<A href='?src=\ref[src];secrets2=check_antagonist'>Show the key of the traitor</A><BR>
<A href='?src=\ref[src];secrets2=showailaws'>Show AI Laws</A><BR>
<A href='?src=\ref[src];secrets2=power'>Make all areas powered</A><BR>
<A href='?src=\ref[src];secrets2=unpower'>Make all areas unpowered</A><BR>
<A href='?src=\ref[src];secrets2=toggleprisonstatus'>Toggle Prison Shuttle Status(Use with S/R)</A><BR>
<A href='?src=\ref[src];secrets2=activateprison'>Send Prison Shuttle</A><BR>
<A href='?src=\ref[src];secrets2=deactivateprison'>Return Prison Shuttle</A><BR>
<A href='?src=\ref[src];secrets2=prisonwarp'>Warp all Players to Prison</A><BR>"
<A href='?src=\ref[src];secrets2=flicklights'>Flicker Lights (Pass out to stop)</A><BR>"
<A href='?src=\ref[src];secrets2=shockwave'>Station Shockwave</A><BR>"
<A href='?src=\ref[src];secrets2=wave'>Spawn a wave of meteors</A><BR>"}

		usr << browse(dat, "window=secrets")
	/obj/admins/Topic(href, href_list)
		if (href_list["secrets2"])
			if ((src.rank in list( "Administrator", "Primary Administrator" )))
				var/ok = 0
				switch(href_list["secrets2"])
					if("sec_clothes")
						for(var/obj/item/clothing/under/O in world)
							del(O)
						ok = 1
					if("sec_all_clothes")
						for(var/obj/item/clothing/O in world)
							del(O)
						ok = 1
					if("sec_classic1")
						for(var/obj/item/clothing/suit/firesuit/O in world)
							del(O)
						for(var/obj/grille/O in world)
							del(O)
						for(var/obj/machinery/vehicle/pod/O in world)
							for(var/mob/M in src)
								M.loc = src.loc
								if (M.client)
									M.client.perspective = MOB_PERSPECTIVE
									M.client.eye = M
							del(O)
						ok = 1
					if("clear_bombs")
						for(var/obj/item/assembly/r_i_ptank/O in world)
							del(O)
						for(var/obj/item/assembly/m_i_ptank/O in world)
							del(O)
						for(var/obj/item/assembly/t_i_ptank/O in world)
							del(O)
						ok = 1
					if("list_bombers")
						var/dat = "<B>Don't be insane about this list</B> Get the facts. They also could have disarmed one.<HR>"
						for(var/l in bombers)
							dat += text("[] 'made' a bomb.<BR>", l)
						usr << browse(dat, "window=bombers")
					if("list_signalers")
						var/dat = "<B>Showing last [length(lastsignalers)] signalers.</B><HR>"
						for(var/sig in lastsignalers)
							dat += "[sig]<BR>"
						usr << browse(dat, "window=lastsignalers;size=800x500")
					if("toxic")
						for(var/obj/machinery/atmoalter/siphs/fullairsiphon/O in world)
							O.t_status = 3
						for(var/obj/machinery/atmoalter/siphs/scrubbers/O in world)
							O.t_status = 1
							O.t_per = 1000000.0
						for(var/obj/machinery/atmoalter/canister/O in world)
							if (!( istype(O, /obj/machinery/atmoalter/canister/oxygencanister) ))
								O.t_status = 1
								O.t_per = 1000000.0
							else
								O.t_status = 3
					if("check_antagonist")
						if (ticker)
							if (ticker.killer)
								if (ticker.killer.ckey)
									alert(text("The traitor is [] ([]) @ [].", ticker.killer.rname, ticker.killer.ckey, get_area(ticker.killer)), null, null, null, null, null)
								else
									alert("It seems like the traitor logged out...", null, null, null, null, null)
							else
								alert("There is no traitor.", null, null, null, null, null)
						else
							alert("The game has not started yet.", null, null, null, null, null)
					if("monkey")
						for(var/mob/human/H in world)
							spawn(0)
								H.monkeyize()
						ok = 1
					if("power")
						for(var/obj/item/cell/C in world)
							C.charge = C.maxcharge
						for(var/obj/machinery/power/smes/S in world)
							S.charge = S.capacity
							S.output = 200000
							S.online = 1
							S.updateicon()
							S.power_change()
						for(var/area/A in world)
							if(A.name != "Space" && A.name != "Engine Walls" && A.name != "Toxin Test Chamber" && A.name != "space" && A.name != "Escape Shuttle" && A.name != "Arrival Area" && A.name != "Arrival Shuttle" && A.name != "start area" && A.name != "Engine Combustion Chamber")
								A.power_light = 1
								A.power_equip = 1
								A.power_environ = 1
								A.power_change()
					if("unpower")
						for(var/obj/item/cell/C in world)
							C.charge = 0
						for(var/obj/machinery/power/smes/S in world)
							S.charge = 0
							S.output = 0
							S.online = 0
							S.updateicon()
							S.power_change()
						for(var/area/A in world)
							if(A.name != "Space" && A.name != "Engine Walls" && A.name != "Toxin Test Chamber" && A.name != "Escape Shuttle" && A.name != "Arrival Area" && A.name != "Arrival Shuttle" && A.name != "start area" && A.name != "Engine Combustion Chamber")
								A.power_light = 0
								A.power_equip = 0
								A.power_environ = 0
								A.power_change()
					if("prisonwarp")
						if(!ticker)
							alert("The game hasn't started yet!", null, null, null, null, null)
							return
						messageadmins("\blue [usr.key] teleported all players to the prison station.")
						for(var/mob/human/H in world)
							var/turf/loc = find_loc(H)
							if(!H.start || loc.z > 1 || prisonwarped.Find(H))	//don't warp them if they aren't ready or are already there
								continue
							H.paralysis += 5
							if(!("access_security" in H.wear_id.access))
								//strip their stuff before they teleport into a cell :downs:
								for(var/obj/item/W in H)
									if(istype(W, /obj/item/organ/external))	continue	//don't strip organs
									H.unequip(W)
									if (H.client)
										H.client.screen -= W
									if (W)
										W.loc = H.loc
										W.dropped(H)
										W.layer = initial(W.layer)
								//teleport person to cell
								H.loc = pick(prisonwarp)
								H.equip_if_possible(new /obj/item/clothing/under/orange(H), slot_w_uniform)
								H.equip_if_possible(new /obj/item/clothing/shoes/orange(H), slot_shoes)
							else
								//teleport security person
								H.loc = pick(prisonsecuritywarp)
							prisonwarped += H
					if("showailaws")
						for(var/mob/ai/ai in world)
							var/lawIndex = 0
							usr << "[ai.rname]/[ai.key]'s Laws:"
							for(var/index=1, index<=ai.laws.len, index++)
								var/law = ai.laws[index]
								if (length(law)>0)
									if (index==2 && lawIndex==0)
										lawIndex = 1
									usr << text("[]. []", lawIndex, law)
									lawIndex += 1
					if("flicklights")
						spawn(0)
							while(!usr.stat)	//knock yourself out to stop the ghosts
								for(var/mob/M in world)
									if(M.client && M.stat != 2 && prob(25))
										var/area/AffectedArea = get_area(M)
										if(AffectedArea.name != "Space" && AffectedArea.name != "Arrival Shuttle" && AffectedArea.name != "start area")
											AffectedArea.power_light = 0
											AffectedArea.power_change()
											spawn(rand(55,185))
												AffectedArea.power_light = 1
												AffectedArea.power_change()
											var/Message = rand(1,4)
											switch(Message)
												if(1)
													M.show_message(text("\blue You shudder as if cold..."), 1)
												if(2)
													M.show_message(text("\blue You feel something gliding across your back..."), 1)
												if(3)
													M.show_message(text("\blue Your eyes twitch, you feel like something you can't see is here..."), 1)
												if(4)
													M.show_message(text("\blue You notice something moving out of the corner of your eye, but nothing is there..."), 1)
											for(var/obj/W in orange(5,M))
												if(prob(25) && !W.anchored)
													step_rand(W)
								sleep(rand(100,1000))
							for(var/mob/M in world)
								if(M.client && M.stat != 2)
									M.show_message(text("\blue The chilling wind suddenly stops..."), 1)
					if("shockwave")
						ok = 1
						spawn
							world << "\red <B><big>ALERT: STATION STRESS CRITICAL</big></B>"
							sleep(60)
							world << "\red <B><big>ALERT: STATION STRESS CRITICAL. TOLERABLE LEVELS EXCEEDED!</big></B>"
							sleep(80)
							world << "\red <B><big>ALERT: STATION STRUCTURAL STRESS CRITICAL. SAFETY MECHANISMS FAILED!</big></B>"
							sleep(40)
							for(var/mob/M in world)
								shake_camera(M, 400, 1)
							for(var/obj/window/W in world)
								spawn(rand(10,400))
									W.ex_act(rand(2,1))
							for(var/obj/grille/G in world)
								spawn(rand(20,400))
									G.ex_act(rand(2,1))
							for(var/obj/machinery/door/D in world)
								spawn(rand(20,400))
									D.ex_act(rand(2,1))
							for(var/turf/simulated/floor/Floor in world)
								spawn(rand(30,400))
									Floor.ex_act(rand(2,1))
							for(var/obj/cable/Cable in world)
								spawn(rand(30,400))
									Cable.ex_act(rand(2,1))
							for(var/obj/closet/Closet in world)
								spawn(rand(30,400))
									Closet.ex_act(rand(2,1))
							for(var/obj/machinery/Machinery in world)
								spawn(rand(30,400))
									Machinery.ex_act(rand(1,3))
							for(var/turf/simulated/wall/Wall in world)
								spawn(rand(30,400))
									Wall.ex_act(rand(2,1))
					if("wave")
						spawn
							meteor_wave()
				if (usr)
					world.log_admin("[usr.key] used secret [href_list["secrets2"]]")
					if (ok)
						world << text("<B>A secret has been activated by []!</B>", usr.key)
		else
			. = ..()

obj/admins/proc/update()
	for(var/v in (verbs - typesof(/atom/verb) - typesof(/atom/movable/verb)))
		if(!(v in adminranks))
			world.log << "Unknown permission for admin verb [v]"
		else
			if(!(src.rank in adminranks[v]))
				verbs -= v

	src.invisibility = 0
	src.loc = owner:mob