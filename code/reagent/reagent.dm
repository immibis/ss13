datum/reagent
	var/amount = 0

	var/name = "liquid"

	var/reacts_from = null

	// does not check that amount >= amt
	proc/split_and_remove(var/amt)
		var/datum/reagent/R = new type()
		R.amount = amt
		amount -= amt
		return R

	proc/dropper_mob(mob/M)
	proc/inject_mob(mob/M)

	// input is the list of reagent objects
	// note "input" is the name of a built-in proc
	proc/reaction_finish(var/list/in_put)

datum/reaction
	var/list/requirements = new // list of reagent paths
	var/produces // reagent path

var/list/reagent_reactions = new

proc/InitReagentReactions()
	for(var/path in (typesof(/datum/reagent) - /datum/reagent))
		var/datum/reagent/R = new path
		if(R.reacts_from)
			var/datum/reaction/RE = new
			RE.requirements = R.reacts_from
			RE.produces = path
			reagent_reactions += RE
		del(R)

world/New()
	. = ..()
	InitReagentReactions()

datum/reagent_container
	var/datum/reagent/reagents[] = new
	var/max_volume = INFINITY
	var/cur_volume = 0

	New(max_volume)
		if(!max_volume) max_volume = 30
		src.max_volume = max_volume
		. = ..()

	proc/init(path, amt)
		cur_volume = amt
		max_volume = amt
		var/datum/reagent/R = new path()
		R.amount = amt
		reagents = list(R)

	// Does not check the max volume.
	// dont_check_reaction is not normally specified, it is only
	// used if you are adding a lot of reagents and will call check_reaction
	// yourself at the end.
	proc/add_reagent(datum/reagent/R, dont_check_reaction)
		var/datum/reagent/this = locate(R.type) in reagents
		if(!this)
			this = new R.type()
			reagents += this
		this.amount += R.amount
		cur_volume += R
		if(!dont_check_reaction)
			check_reaction()

	// pct is the percentage from 0 to 1, default is "as much as will fit"
	// if pct is specified, then the max volume is not checked.
	proc/pour_into(datum/reagent_container/dest, pct)
		if(pct == null)
			pct = (dest.max_volume - dest.cur_volume) / cur_volume
		if(pct <= 0)
			return
		if(pct > 1)
			pct = 1 // can't transfer more than 100%

		for(var/datum/reagent/R in reagents)
			dest.add_reagent(R.split_and_remove(R.amount * pct), 1)
			if(R.amount == 0)
				reagents -= R
				del(R)
		cur_volume *= (1 - pct)

		dest.check_reaction()

	proc/transfer_from(datum/reagent_container/source, amt)
		amt = min(amt, max_volume - cur_volume)
		source.pour_into(src, amt / source.cur_volume)

	proc/split_and_remove(amt)
		if(amt <= 0)
			return new /datum/reagent_container()
		var/datum/reagent_container/C = new(INFINITY)
		if(amt >= cur_volume)
			C.reagents = reagents
			C.cur_volume = cur_volume
		else
			for(var/datum/reagent/R in reagents)
				C.add_reagent(R.split_and_remove(amt * (R.amount / cur_volume)))
		return C

	proc/dropper_mob(mob/M)
		for(var/datum/reagent/R in reagents)
			R.dropper_mob(M)
		reagents.Cut()
		cur_volume = 0

	proc/transfer_mob(mob/M, amount)
		if(amount != null)
			var/datum/reagent_container/C = split_and_remove(amount)
			C.transfer_mob(M)
			return
		for(var/datum/reagent/R in reagents)
			R.inject_mob(M)
		reagents.Cut()
		cur_volume = 0

	proc/describe()
		if(cur_volume == 0 || reagents.len == 0)
			return "nothing"
		var/t = "[cur_volume] mL of "
		if(reagents.len > 1)
			t += "liquid"
		else
			var/datum/reagent/R = reagents[1]
			t += R.name
		return t

	proc/check_reaction()
		for(var/datum/reaction/R in reagent_reactions)
			var/amt = cur_volume
			for(var/path in R.requirements)
				var/datum/reagent/E = locate(path) in reagents
				if(!E)
					amt = 0
					break
				if(E.amount < amt)
					amt = E.amount
			if(amt > 0)
				var/list/input_ = new
				for(var/path in R.requirements)
					var/datum/reagent/E = locate(path) in reagents
					input_ += E.split_and_remove(amt)
					cur_volume -= amt
					if(E.amount <= 0)
						reagents -= E
				var/output_type = R.produces
				var/datum/reagent/output_ = new output_type()
				output_.amount = amt
				output_.reaction_finish(input_)
				reagents += output_
				cur_volume += amt