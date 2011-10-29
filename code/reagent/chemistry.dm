/datum/reagent
	alkysine
		name = "alkysine"
		reacts_from = list(.chlorine, .nitrogen, .antitoxins)
		// treats catastrophic injuries

	arithrazine
		name = "arithrazine"
		reacts_from = list(.hyronalin, .hydrogen)
		// treats high radiation poisoning

	ammonia
		name = "ammonia"
		reacts_from = list(.hydrogen, .nitrogen)
		class = list(fertilizer=1)

	cryoxadone
		name = "cryoxadone"
		reacts_from = list(.dexalin, .water, .oxygen)
		// unknown

	cryptobiolin
		name = "cryptobiolin"
		reacts_from = list(.potassium, .oxygen, .sugar)
		// causes confusion

	cryostylane
		name = "cryostylane"
		reacts_from = list(.leporazine, .water, .oxygen)
		// freezes

	dexalin
		name = "Dexalin"
		reacts_from = list(.plasma, .oxygen)
		// treats oxygen deprivation

	dexalin_plus
		name = "Dexalin Plus"
		reacts_from = list(.dexalin, .carbon, .iron)
		// treats oxygen deprivation superbly

	diethylamine
		name = "diethylamine"
		reacts_from = list(.ammonia, .ethanol)
		class = list(fertilizer=2.5)
		// a better fertilizer

	flash_powder
		name = "flash powder"
		reacts_from = list(.aluminium, .potassium, .sulfur)

	foam
		name = "foam"
		reacts_from = list(.carbon, .fluorine, .sulfuric_acid)
		// todo: "The more fluorine the better"
		// todo: requires water to work in a grenade (but water must be added separately)

	foaming_agent
		name = "foaming agent"
		reacts_from = list(.lithium, .hydrogen)
		// todo: requires water to work in a grenade (but water must be added separately)

	hyperzine
		name = "hyperzine"
		reacts_from = list(.sugar, .phosphorous, .sulfur)
		// increases muscle strength temporarily

	hyronalin
		name = "hyronalin"
		reacts_from = list(.radium, .antitoxins)
		// treats radiation poisoning

	impedrezene
		name = "impedrezene"
		reacts_from = list(.mercury, .oxygen, .sugar)
		// impedes movement

	kelotane
		name = "kelotane"
		reacts_from = list(.silicon, .carbon)
		// treats burn damage

	leporazine
		name = "leporazine"
		reacts_from = list(.silicon, .plasma)
		// stabilizes body temperature

	lsd
		name = "LSD"
		reacts_from = list(.space_fungus, .diethylamine)
		// makes you see trippy things

	napalm
		name = "napalm"
		reacts_from = list(.aluminium, .plasma, .sulfuric_acid)
		// basically liquid fire

	unstable_mutagen
		name = "unstable mutagen"
		reacts_from = list(.radium, .phosphorous, .chlorine)
		// gives random genetic mutations

	polytrinic_acid
		name = "polytrinic acid"
		reacts_from = list(.sulfuric_acid, .chlorine, .potassium)
		// an acid which is useful to make other substances

	ryetalyn
		name = "Ryetalyn"
		reacts_from = list(.radium, .carbon, .hydrogen, .antitoxins)
		// removes some genetic defects

	silicate
		name = "silicate"
		reacts_from = list(.silicon, .oxygen, .aluminium)
		// reinforces windows

	smoke_powder
		name = "smoke powder"
		reacts_from = list(.potassium, .sugar, .phosphorous)
		// used in smoke grenades

	spaceacillin
		name = "spaceacillin"
		reacts_from = list(.cryptobiolin, .inaprovaline)
		// heals clown disease

	space_drugs
		name = "space drugs"
		reacts_from = list(.mercury, .sugar, .lithium)
		// drugs... in space

	space_lube
		name = "space lube"
		reacts_from = list(.silicon, .oxygen, .water)
		// causes people to slip even if they're walking

 	stable_mutagen
 		name = "stable mutagen"
 		reacts_from = list(.unstable_mutagen, .space_drugs, .mercury)
 		// Add blood to it in syringe to change a person's DNA structure to person who you extracted the blood from

 	activated_stable_mutagen
 		name = "activated stable mutagen"
 		reacts_from = list(.stable_mutagen, .blood)

	synthflesh
		name = "synthflesh"
		reacts_from = list(.blood, .inaprovaline, .carbon)
		// fake flesh

	synaptizine
		name = "synaptizine"
		reacts_from = list(.sugar, .lithium, .water)
		// unknown

	thermite
		name = "thermite"
		reacts_from = list(.oxygen, .iron, .aluminium)
		// can be applied to things and then used with a welding tool to melt them

	tricordrazine
		name = "tricordrazine"
		reacts_from = list(.antitoxins, .inaprovaline)
		// transfers brute damage to burn damage, then progressively heals brute damage

 	space_cleaner
 		name = "space cleaner"
 		reacts_from = list(.ammonia, .water)

	metal_foam
		name = "metal foam"
		reacts_from = list(.foaming_agent, .polytrinic_acid, .aluminium)

// pure chemicals
datum/reagent
	chlorine/name = "chlorine"
	nitrogen/name = "nitrogen"
	hydrogen/name = "hydrogen"
	water/name = "water"
	oxygen/name = "oxygen"
	potassium/name = "potassium"
	sugar/name = "sugar"
	plasma/name = "plasma"
	carbon/name = "carbon"
	iron/name = "iron"
	ethanol/name = "ethanol"
	aluminium/name = "aluminium"
	sulfur/name = "sulfur"
	fluorine/name = "fluorine"
	sulfuric_acid/name = "sulfuric acid"
	lithium/name = "lithium"
	phosphorous/name = "phosphorous"
	radium/name = "radium"
	mercury/name = "mercury"
	silicon/name = "silicon"
	space_fungus/name = "space fungus"
	inaprovaline/name = "inaprovaline"
	blood/name = "blood"

	welding_fuel
		name = "welding fuel"
		class = list(toxic=1, plant_toxic=1)

	poo
		name = "poo"
		class = list(fertilizer=1)

	space_cleaner/name = "space cleaner"

var/list/chemistry_base_reagents = list(
/datum/reagent/chlorine,
/datum/reagent/nitrogen,
/datum/reagent/hydrogen,
/datum/reagent/oxygen,
/datum/reagent/potassium,
/datum/reagent/sugar,
/datum/reagent/plasma,
/datum/reagent/carbon,
/datum/reagent/iron,
/datum/reagent/ethanol,
/datum/reagent/aluminium,
/datum/reagent/sulfur,
/datum/reagent/fluorine,
/datum/reagent/sulfuric_acid,
/datum/reagent/lithium,
/datum/reagent/phosphorous,
/datum/reagent/radium,
/datum/reagent/mercury,
/datum/reagent/silicon)

obj/machinery/chem_dispenser
	icon = 'icons/immibis/chemistry.dmi'
	icon_state = "dispenser-goonstation"

	var/list/reagent_names = list()
	var/obj/item/container = null
	var/datum/reagent_container/chem = null
	New()
		. = ..()
		spawn
			for(var/P in chemistry_base_reagents)
				var/datum/reagent/R = new P
				reagent_names["[P]"] = R.name
				del(R)

	// doesn't need power

	attackby(obj/item/O, mob/user)
		if(!container && "chem" in O.vars && O.Move(src))
			container = O
			chem = O:chem
		else
			. = ..()

	attack_hand(mob/user)
		interact(user)
		user.machine = src

	proc/interact(mob/user)
		var/html = "<B>ChemMaster 9000 Chemical Dispenser</B><HR>"

		if(!container)
			html += "No container loaded!<BR>"
		else
			html += "\The [container] contains [chem.describe()]. <A href=\"?src=\ref[src];eject=1\">Eject container</A><BR>"

			for(var/X in chemistry_base_reagents)
				html += "<A href=\"?src=\ref[src];path=[X]\">Dispense [reagent_names["[X]"]]</A><BR>"

		user << browse(html, "window=chemdispenser")

	Topic(href, href_list)
		if("eject" in href_list)
			if(container.Move(loc))
				container = null
				chem = null
				UpdateInteraction(src)
		else if(chem)
			var/P = text2path(href_list["path"])
			if(!P) return
			var/datum/reagent/R = new P
			R.amount = chem.max_volume - chem.cur_volume
			chem.add_reagent(chem)
			UpdateInteraction(src)

/obj/item/reagent/beaker
	name = "Beaker"
	icon_state = "beaker0"
	icon = 'icons/goonstation/obj/chemical.dmi'

	max_volume = 70
	transfer_size = 70

/obj/item/storage/beaker_box
	name = "Beakers"
	icon_state = "beaker"
	s_istate = "syringe_kit"
	New()
		. = ..()
		for(var/k = 1 to 7)
			new /obj/item/reagent/beaker(src)

/obj/item/storage/syringe
	name = "Syringes (Biohazard Alert)"
	icon_state = "syringe"
	s_istate = "syringe_kit"
	New()
		. = ..()
		for(var/k = 1 to 7)
			new /obj/item/syringe(src)

