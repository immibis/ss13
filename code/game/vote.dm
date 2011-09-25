var/const
	RESTART_VOTE = 0
	CHANGE_MODE_VOTE = 1

var/list/VOTE_MODE_DESCRIPTION = list("restart", "change game mode")

/datum/vote/New()
	nextvotetime = world.timeofday // + 10*config.vote_delay


/datum/vote/proc/canvote()
	var/excess = world.timeofday - vote.nextvotetime

	if(excess < -10000)		// handle clock-wrapping problems - very long delay (>20 hrs) if wrapped
		vote.nextvotetime = world.timeofday
		return 1
	return (excess >= 0)

/datum/vote/proc/nextwait()
	return timetext( round( (nextvotetime - world.timeofday)/10) )

/datum/vote/proc/endwait()
	return timetext( round( (votetime - world.timeofday)/10) )

/datum/vote/proc/timetext(var/interval)
	var/minutes = round(interval / 60)
	var/seconds = round(interval % 60)

	var/tmin = "[minutes>0?num2text(minutes)+"min":null]"
	var/tsec = "[seconds>0?num2text(seconds)+"sec":null]"

	if(tmin && tsec)				// hack to skip inter-space if either field is blank
		return "[tmin] [tsec]"
	else
		if(!tmin && !tsec)		// return '0sec' if 0 time left
			return "0sec"
		return "[tmin][tsec]"

/datum/vote/proc/getvotes()
	var/list/L = list()
	for(var/mob/M in world)
		if(M.client && M.client.inactivity < 1200)		// clients inactive for 2 minutes don't count
			L[M.client.vote] += 1

	return L


/datum/vote/proc/endvote()

	if(!voting)		// means that voting was aborted by an admin
		return

	world << "\red <B>***Voting has closed.</B>"

	world.log_vote("Voting closed, result was [winner]")

	voting = 0
	nextvotetime = world.timeofday + 10*config.vote_delay

	for(var/mob/M in world)		// clear vote window from all clients
		if(M.client)
			M << browse(null, "window=vote")
			M.client.showvote = 0

	calcwin()

	if(mode == CHANGE_MODE_VOTE)
		var/wintext = capitalize(winner)
		if(winner=="default")
			world << "Result is: \red No change."
			return
		world << "Result is: \red change to [wintext]"

		var/F = file(persistent_file)
		fdel(F)
		F << winner

		if(ticker)
			world <<"\red <B>World will reboot in 10 seconds</B>"
			sleep(100)
			world.log_game("Rebooting due to mode vote")
			world.Reboot()
		else
			master_mode = winner

	else if(mode == RESTART_VOTE)
		if(winner=="default")
			world << "Result is \red No restart."
			return

		world << "Result is \red Restart round."
		world <<"\red <B>World will reboot in 5 seconds</B>"
		sleep(50)
		world.log_game("Rebooting due to restart vote")
		world.Reboot()
	return


/datum/vote/proc/calcwin()

	var/list/votes = getvotes()

	if(vote.mode)
		var/best = -1

		for(var/v in votes)
			if(v=="none")
				continue
			if(best < votes[v])
				best = votes[v]


		var/list/winners = list()

		for(var/v in votes)
			if(votes[v] == best)
				winners += v

		var/ret = ""


		for(var/w in winners)
			if(lentext(ret) > 0)
				ret += "/"
			if(w=="default")
				winners = list("default")
				ret = "No change"
				break
			else
				ret += capitalize(w)



		if(winners.len != 1)
			ret = "Tie: " + ret


		if(winners.len == 0)
			vote.winner = "default"
			ret = "No change"
		else
			vote.winner = pick(winners)

		return ret
	else

		if(votes["default"] < votes["restart"])

			vote.winner = "restart"
			return "Restart"
		else
			vote.winner = "default"
			return "No restart"


/mob/verb/vote()
	set name = "Vote"
	usr.client.showvote = 1


	var/text = "<HTML><HEAD><TITLE>Voting</TITLE></HEAD><BODY scroll=no>"

	var/footer = "<HR><A href='?src=\ref[vote];voter=\ref[src];vclose=1'>Close</A></BODY></HTML>"


	if(config.vote_no_dead && usr.stat == 2)
		text += "Voting while dead has been disallowed."
		text += footer
		usr << browse(text, "window=vote")
		usr.client.showvote = 0
		usr.client.vote = "none"
		return

	if(vote.voting)
		// vote in progress, do the current

		text += "Vote to [vote.mode?"change mode":"restart round"] in progress.<BR>"
		text += "[vote.endwait()] until voting is closed.<BR>"

		var/list/votes = vote.getvotes()

		if(vote.mode == CHANGE_MODE_VOTE)
			text += "Current game mode is: <B>[master_mode]</B>.<BR>Select the mode to change to:<UL>"
			for(var/md in config.votable_modes)
				var/disp = capitalize(md)
				if(md=="default")
					disp = "No change"
				if(src.client.vote == md)
					text += "<LI><B>[disp]</B>"
				else
					text += "<LI><A href='?src=\ref[vote];voter=\ref[src];vote=[md]'>[disp]</A>"
				if(votes[md] > 0)
					text += " - [votes[md]] vote\s"
				text += "<BR>"
			text += "</UL>"
			text +="<p>Current winner: <B>[vote.calcwin()]</B><BR>"
			text += footer
			usr << browse(text, "window=vote")

		else if(vote.mode == RESTART_VOTE)
			text += "Restart the world?<BR><UL>"
			var/list/VL = list("default","restart")
			for(var/md in VL)
				var/disp = (md=="default"? "No":"Yes")
				if(src.client.vote == md)
					text += "<LI><B>[disp]</B>"
				else
					text += "<LI><A href='?src=\ref[vote];voter=\ref[src];vote=[md]'>[disp]</A>"
				if(votes[md] > 0)
					text += " - [votes[md]] vote\s"
				text += "<BR>"
			text += "</UL>"
			text +="<p>Current winner: <B>[vote.calcwin()]</B><BR>"
			text += footer
			usr << browse(text, "window=vote")

	else		//no vote in progress

		if(!config.allow_vote_restart && !config.allow_vote_mode)
			usr << "\blue Player voting is disabled."
			return

		if(!vote.canvote())		// not time to vote yet
			if(config.allow_vote_restart) text+="Voting to restart is enabled.<BR>"
			if(config.allow_vote_mode) text+="Voting to change mode is enabled.<BR>"

			text+="<BR><P>Next vote can begin in [vote.nextwait()]."
			text+=footer

			usr << browse(text, "window=vote")

		else			// voting can begin
			if(config.allow_vote_restart)
				text += "<A href='?src=\ref[vote];voter=\ref[src];vmode=[RESTART_VOTE]'>Begin restart vote.</A><BR>"
			if(config.allow_vote_mode)
				text += "<A href='?src=\ref[vote];voter=\ref[src];vmode=[CHANGE_MODE_VOTE]'>Begin change mode vote.</A><BR>"

			text += footer
			usr << browse(text, "window=vote")

	spawn(20)
		if(usr.client && usr.client.showvote)
			usr.vote()
		else
			usr << browse(null, "window=vote")

		return


/datum/vote/Topic(href, href_list)
	..()

	var/mob/M = locate(href_list["voter"])			// mob of player that clicked link

	if("vclose" in href_list)

		if(M)
			M << browse(null, "window=vote")
			M.client.showvote = 0

	else if("vmode" in href_list)
		StartVote(M, text2num(href_list["vmode"]))

		if(M) M.vote()

	else if("vote" in href_list && vote.voting)
		if(M)
			M.client.vote = href_list["vote"]

			//world << "Setting client [M.key]'s vote to: [href_list["vote"]]."

			M.vote()

proc/StartVote(mob/user, type, force=0)
	if(vote.voting)
		return

	if(!user)
		CRASH("StartVote: user is null")

	if(!ismob(user))
		CRASH("StartVote: user is not a mob")

	if(!vote.canvote() && !force)
		return

	vote.mode = type
	vote.voting = 1						// now voting
	vote.votetime = world.timeofday + config.vote_period*10	// when the vote will end

	spawn(config.vote_period*10)
		vote.endvote()

	world << "\red<B>*** A vote to [VOTE_MODE_DESCRIPTION[vote.mode]] has been initiated by <i>[usr.key]</i>.</B>"
	world << "\red     You have [vote.timetext(config.vote_period)] to vote."

	world.log_vote("Voting to [VOTE_MODE_DESCRIPTION[vote.mode]] started by [user.name]/[user.key]")

	for(var/mob/CM in world)
		if(CM.client)
			if(config.vote_no_default || (config.vote_no_dead && CM.stat == 2))
				CM.client.vote = "none"
			else
				CM.client.vote = "default"