obj/begin
	name = "teleporter"
	icon = 'icons/ss13/stationobjs.dmi'
	density = 1
	anchored = 1.0
	anchored = 1
	hub
		icon_state = "tele1"
		CheckPass(mob/M)
			if(M.client)
				ready(M)
			return 0
	station
		icon_state = "controller"
	computer
		icon_state = "tele_computer"
		Click()
			var/mob/human/M = usr
			if(istype(M))
				M.char_setup()

	info
		name = "information"
		icon = 'icons/immibis/begin.dmi'
		icon_state = "information"
		Click()
			usr << "To join the game, step into the teleporter."
			usr << "To access the character setup window, walk up to the computer and click on it."

	proc/ready(mob/human/M)
		if (!enter_allowed)
			M << "\blue There is an administrative lock on entering the game!"
			return

		if (!istype(M, /mob/human) || usr.start)
			M << "You have already started!"
			return

		for(var/mob/human/H in world)
			if(H.start && cmptext(H.rname,M.rname))
				usr << "You are using a name that is very similar to a currently used name, please choose another one using Character Setup."
				return
		if(cmptext("Unknown",M.rname))
			usr << "This name is reserved for use by the game, please choose another one using Character Setup."
			return
		src.get_dna_ready(M)

		/*if (ticker)
			var/list/L = assistant_occupations
			var/job
			if (L.Find(M.occupation1))
				job = M.occupation1
			else if (L.Find(M.occupation2))
				job = M.occupation2
			else if (L.Find(M.occupation3))
				job = M.occupation3
			else
				job = pick(L)
			var/joined_late = 1
			M.Assign_Rank(job, joined_late)*/

		if(ticker)
			M.PickLateJoinerJob()

		M.start = 1
		M.update_face()
		M.update_body()

		enter(M)

	proc/enter(mob/human/M)
		if (!M.start || !istype(M, /mob/human))
			M << "\blue <B>You aren't ready! Use the ready verb on this pad to set up your character!</B>"
			return

		world.log_game("[M.key] entered as [M.name]")

		if (ticker)
			//world << "\blue [M.rname] has arrived on the station!"
			M << "<B>Game mode is [ticker.mode.name].</B>"

		var/area/A = locate(ticker ? /area/arrival/start : /area/pregame)
		var/list/L = list()
		for(var/turf/T in A)
			if(T.isempty())
				L += T

		while(!L.len)
			M << "\blue <B>You were unable to enter because the arrival shuttle has been destroyed! The game will reattempt to spawn you in 30 seconds!</B>"
			sleep(300)
			for(var/turf/T in A)
				if(T.isempty())
					L += T

		if(ticker)
			reg_dna[M.primary.uni_identity] = M.rname
			if(ticker.mode.name == "sandbox")
				M.CanBuild()


		M << "\blue Now teleporting."
		M.loc = pick(L)

	proc/get_dna_ready(var/mob/user as mob)
		var/mob/human/M = user

		if (!M.primary)
			var/t2

			M.r_hair = M.nr_hair
			M.b_hair = M.nb_hair
			M.g_hair = M.ng_hair
			M.s_tone = M.ns_tone
			var/t1 = rand(1000, 1500)
			dna_ident += t1
			if (dna_ident > 65536)
				dna_ident = rand(1, 1500)
			M.primary = new /obj/dna(null)
			M.primary.uni_identity  = add_zero(num2hex(dna_ident), 4)
			M.primary.uni_identity += add_zero(num2hex(M.nr_hair), 2)
			M.primary.uni_identity += add_zero(num2hex(M.ng_hair), 2)
			M.primary.uni_identity += add_zero(num2hex(M.nb_hair), 2)
			M.primary.uni_identity += add_zero(num2hex(M.r_eyes), 2)
			M.primary.uni_identity += add_zero(num2hex(M.g_eyes), 2)
			M.primary.uni_identity += add_zero(num2hex(M.b_eyes), 2)
			M.primary.uni_identity += add_zero(num2hex(-M.ns_tone + 35), 2)

			if (M.gender == "male")
				t2 = "[num2hex(rand(  1, 124))]"
			else
				t2 = "[num2hex(rand(127, 250))]"

			if (length(t2) < 2)
				M.primary.uni_identity = text("[]0[]", M.primary.uni_identity, t2)
			else
				M.primary.uni_identity = text("[][]", M.primary.uni_identity, t2)

			M.primary.spec_identity = "5BDFE293BA5500F9FFFD500AAFFE"
			M.primary.struc_enzyme = "CDE375C9A6C25A7DBDA50EC05AC6CEB63"

			/*if (rand(1, 3125) == 13)
				M.need_gl = 1
				M.be_epil = 1
				M.be_cough = 1
				M.be_tur = 1
				M.be_stut = 1*/

			var/b_vis
			if (M.need_gl)
				b_vis = add_zero(text("[]", num2hex(rand(10, 1400))), 3)
				M.disabilities = M.disabilities | 1
				M << "\blue You need glasses!"
			else
				b_vis = "5A7"

			var/epil
			if (M.be_epil)
				epil = add_zero(text("[]", num2hex(rand(10, 1400))), 3)
				M.disabilities = M.disabilities | 2
				M << "\blue You are epileptic!"
			else
				epil = "6CE"

			var/cough
			if (M.be_cough)
				cough = add_zero(text("[]", num2hex(rand(10, 1400))), 3)
				M.disabilities = M.disabilities | 4
				M << "\blue You have a chronic coughing syndrome!"
			else
				cough = "EC0"

			var/Tourette
			if (M.be_tur)
				epil = add_zero(text("[]", num2hex(rand(10, 1400))), 3)
				M.disabilities = M.disabilities | 8
				M << "\blue You have Tourette syndrome!"
			else
				Tourette = "5AC"

			var/stutter
			if (M.be_stut)
				stutter = add_zero(text("[]", num2hex(rand(10, 1400))), 3)
				M.disabilities = M.disabilities | 16
				M << "\blue You have a stuttering problem!"
			else
				stutter = "A50"

			M.primary.struc_enzyme = "CDE375C9A6C2[b_vis]DBD[stutter][cough][Tourette][epil]B63"
			M.primary.use_enzyme = "493DB249EB6D13236100A37000800AB71"
			M.primary.n_chromo = 28