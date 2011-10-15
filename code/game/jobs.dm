/proc/SetupOccupationsList()
	var/list/new_occupations = list()

	for(var/occupation in occupations)
		if (!(new_occupations.Find(occupation)))
			new_occupations[occupation] = 1
		else
			new_occupations[occupation] += 1

	occupations = new_occupations
	return

/proc/FindOccupationCandidates(list/unassigned, job, level)
	var/list/candidates = list()

	for (var/mob/human/M in unassigned)
		if (level == 1 && M.occupation1 == job)
			candidates += M

		if (level == 2 && M.occupation2 == job)
			candidates += M

		if (level == 3 && M.occupation3 == job)
			candidates += M

	return candidates

/proc/PickOccupationCandidate(list/candidates)
	if (candidates.len > 0)
		var/list/randomcandidates = shuffle(candidates)
		candidates -= randomcandidates[1]
		return randomcandidates[1]

	return null

var/list/occupation_eligible = null

/proc/DivideOccupations()
	var/list/unassigned = list()
	var/list/occupation_choices = occupations.Copy()
	occupation_eligible = occupations.Copy()
	occupation_choices = shuffle(occupation_choices)

	for (var/mob/human/M in world)
		if (M.client && M.start && !M.already_placed)
			unassigned += M

	if (unassigned.len == 0)
		return

	var/mob/human/captain_choice = null
	for (var/level = 1 to 3)
		var/list/captains = FindOccupationCandidates(unassigned, "Captain", level)
		var/mob/human/candidate = PickOccupationCandidate(captains)

		if (candidate != null)
			captain_choice = candidate
			unassigned -= captain_choice
			break

	if (captain_choice == null && unassigned.len > 1)
		unassigned = shuffle(unassigned)
		captain_choice = unassigned[1]
		unassigned -= captain_choice

	if (captain_choice == null)
		world << text("Captainship not forced on someone since this is a one-player game.")
	else
		captain_choice.Assign_Rank("Captain")

	for (var/level = 1 to 3)
		if (unassigned.len == 0)
			break

		for (var/occupation in assistant_occupations)
			if (unassigned.len == 0)
				break
			var/list/candidates = FindOccupationCandidates(unassigned, occupation, level)
			for (var/mob/human/candidate in candidates)
				candidate.Assign_Rank(occupation)
				unassigned -= candidate

		for (var/occupation in occupation_choices)
			if (unassigned.len == 0)
				break
			var/eligible = occupation_eligible[occupation]
			if (eligible == 0)
				continue
			var/list/candidates = FindOccupationCandidates(unassigned, occupation, level)
			var/eligiblechange = 0
			//world << text("occupation [], level [] - [] eligible - [] candidates", level, occupation, eligible, candidates.len)
			while (eligible--)
				var/mob/human/candidate = PickOccupationCandidate(candidates)
				if (candidate == null)
					break
				//world << text("candidate []", candidate)
				candidate.Assign_Rank(occupation)
				unassigned -= candidate
				eligiblechange++
			occupation_eligible[occupation] -= eligiblechange

	if (unassigned.len)
		unassigned = shuffle(unassigned)
		for (var/occupation in occupation_choices)
			if (unassigned.len == 0)
				break
			var/eligible = occupation_eligible[occupation]
			while (eligible-- && unassigned.len > 0)
				var/mob/human/candidate = unassigned[1]
				if (candidate == null)
					break
				candidate.Assign_Rank(occupation)
				unassigned -= candidate

	for(var/occupation in occupation_choices)
		var/assigned = 0
		if(occupation == "AI")
			continue
		for(var/mob/human/M)
			if(M.wear_id && M.wear_id.assignment == occupation)
				assigned = 1
				break
		if(assigned)
			continue
		var/mob/human/npc/M = CreateNPC(occupation)
		if(M)
			world << "[occupation] job filled by NPC"
			M.Assign_Rank(occupation)
		else
			world << "Unassigned job: [occupation]"

	for (var/mob/human/M in unassigned)
		M.Assign_Rank(pick(assistant_occupations))

	for (var/mob/ai/aiPlayer in world)
		spawn(0)
			var/randomname = pick(ai_names)
			var/newname = input(
				aiPlayer,
				"You are the AI. Would you like to change your name to something else?", "Name change",
				randomname)

			if (length(newname) == 0)
				newname = randomname

			if (newname)
				if (length(newname) >= 26)
					newname = copytext(newname, 1, 26)
				newname = dd_replacetext(newname, ">", "'")
				aiPlayer.rname = newname
				aiPlayer.name = newname

			world << text("<b>[] is the AI!</b>", aiPlayer.rname)

	return

mob/human/proc/PickLateJoinerJob()
	if((occupation1 in occupation_eligible) && occupation_eligible[occupation1])
		occupation_eligible[occupation1] --
		Assign_Rank(occupation1, 0)
	else if((occupation2 in occupation_eligible) && occupation_eligible[occupation2])
		occupation_eligible[occupation2] --
		Assign_Rank(occupation2, 0)
	else if((occupation3 in occupation_eligible) && occupation_eligible[occupation3])
		occupation_eligible[occupation3] --
		Assign_Rank(occupation3, 0)
	else
		Assign_Rank(pick(assistant_occupations), 1)