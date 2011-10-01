var/permissions = list(
	"access_power_remote" = "Remotely control power",
	"access_engineering" = "Access engineering",
	"access_bridge" = "Access the bridge",
	"access_eva" = "Access EVA storage",
	"open_external_airlocks" = "Open external airlocks",
	"access_maintenance" = "Access maintenance corridors",
	"access_chemistry" = "Access chemical research",
	"access_genetics" = "Access genetic research",
	"access_teleporter" = "Access the teleporter room",
	"access_toxins" = "Access toxins",
	"access_medbay" = "Access the medical bay",
	"access_morgue" = "Access the morgue",
	"eject_engine" = "Eject the engine",
	"access_apcs" = "Control APCs",
	"access_chapel_office" = "Access the chapel office",
	"access_medical_records" = "View and modify medical records",
	"access_security" = "Access the security lounge",
	"access_brig" = "Access the brig",
	"change_ids" = "Change ID cards",
	"access_comms" = "Use communications consoles",
	"access_security_records" = "View and modify security records",
	"access_captain" = "Access the captain's closet",
	"access_medical_supplies" = "Access medical supplies",
	"access_all_personal_lockers" = "Access all personal lockers",
	"access_atmospherics" = "Access atmospherics",
	"access_trash_disposal" = "Access garbage disposal area",
	"access_courtroom" = "Access courtroom secure area",
	"access_detective" = "Access detective's office",
	"access_quartermaster" = "Access the cargo bay",
	"access_solars" = "Access solar substations",
	"access_ai" = "Access AI Upload"
	)
var/jobs = list(
	"Genetic Researcher" = list(
		"access_genetics", "access_medbay", "access_morgue", "access_medical_supplies",
		list(/obj/item/weapon/clothing/under/genetics_white, slot_w_uniform),
		list(/obj/item/weapon/clothing/shoes/white, slot_shoes),
		list(/obj/item/weapon/clothing/suit/labcoat, slot_wear_suit)
		),
	"Station Engineer" = list(
		"access_engineering", "eject_engine", "access_apcs", "access_power_remote", "access_trash_disposal",
		"access_solars",
		list(/obj/item/weapon/clothing/under/engineering_yellow, slot_w_uniform),
		list(/obj/item/weapon/clothing/shoes/orange, slot_shoes),
		list(/obj/item/weapon/crowbar, slot_in_backpack),
		list(/obj/item/weapon/storage/toolbox, slot_l_hand),
		list(/obj/item/weapon/t_scanner, slot_belt)
		),
	"Assistant" = list(
		"access_maintenance", "open_external_airlocks", "access_trash_disposal", "access_medbay", "access_morgue",
		list(/obj/item/weapon/clothing/under/grey, slot_w_uniform),
		list(/obj/item/weapon/clothing/shoes/black, slot_shoes)
		),
	"Chaplain" = list(
		"access_morgue", "access_chapel_office",
		list(/obj/item/weapon/clothing/under/chaplain_black, slot_w_uniform),
		list(/obj/item/weapon/clothing/shoes/black, slot_shoes)
		),
	"Medical Doctor" = list(
		"access_medbay", "access_morgue", "access_medical_records", "access_medical_supplies",
		list(/obj/item/weapon/clothing/under/white, slot_w_uniform),
		list(/obj/item/weapon/clothing/shoes/white, slot_shoes),
		list(/obj/item/weapon/clothing/suit/labcoat, slot_wear_suit),
		list(/obj/item/weapon/storage/firstaid/regular, slot_l_hand)
		),
	"Captain" = get_all_accesses() + list(
		list(/obj/item/weapon/clothing/under/darkgreen, slot_w_uniform),
		list(/obj/item/weapon/clothing/suit/armor, slot_wear_suit),
		list(/obj/item/weapon/clothing/shoes/brown, slot_shoes),
		list(/obj/item/weapon/clothing/head/helmet/swat_hel, slot_head),
		list(/obj/item/weapon/clothing/glasses/sunglasses, slot_glasses),
		list(/obj/item/weapon/storage/id_kit, slot_in_backpack),
		),
	"Toxin Researcher" = list(
		"access_toxins",
		list(/obj/item/weapon/clothing/under/toxins_white, slot_w_uniform),
		list(/obj/item/weapon/clothing/shoes/white, slot_shoes),
		list(/obj/item/weapon/clothing/mask/gasmask, slot_wear_mask),
		list(/obj/item/weapon/tank/oxygentank, slot_l_hand)
		),
	"Head of Research" = list(
		"access_medbay", "access_morgue", "access_toxins", "access_teleporter", "access_bridge", "access_security",
		"access_atmospherics", "access_maintenance", "access_comms", "access_medical_supplies", "access_upload",
		list(/obj/item/weapon/clothing/under/hor_green, slot_w_uniform),
		list(/obj/item/weapon/clothing/suit/armor, slot_wear_suit),
		list(/obj/item/weapon/clothing/shoes/brown, slot_shoes),
		list(/obj/item/weapon/clothing/head/helmet, slot_head)
		),
	"Head of Personnel" = list(
		"access_security", "access_brig", "access_security_records", "access_medbay", "access_eva", "access_maintenance",
		"change_ids", "access_comms", "access_medical_records", "access_medical_supplies", "access_all_personal_lockers",
		"access_courtroom", "access_detective",
		list(/obj/item/weapon/clothing/under/hop_green, slot_w_uniform),
		list(/obj/item/weapon/clothing/suit/armor, slot_wear_suit),
		list(/obj/item/weapon/clothing/shoes/brown, slot_shoes),
		list(/obj/item/weapon/clothing/head/helmet, slot_head),
		list(/obj/item/weapon/storage/id_kit, slot_in_backpack),
		),
	"Security Officer" = list(
		"access_security", "access_brig", "access_security_records", "access_trash_disposal", "access_courtroom",
		list(/obj/item/weapon/clothing/under/red, slot_w_uniform),
		list(/obj/item/weapon/clothing/suit/armor, slot_wear_suit),
		list(/obj/item/weapon/clothing/head/helmet, slot_head),
		list(/obj/item/weapon/clothing/shoes/brown, slot_shoes),
		list(/obj/item/weapon/handcuffs, slot_in_backpack),
		list(/obj/item/weapon/handcuffs, slot_in_backpack),
		list(/obj/item/weapon/baton, slot_belt)
		),
	"Atmospheric Technician" = list(
		"access_atmospherics", "access_maintenance",
		list(/obj/item/weapon/clothing/under/atmospherics_yellow, slot_w_uniform),
		list(/obj/item/weapon/clothing/shoes/black, slot_shoes),
		list(/obj/item/weapon/storage/toolbox, slot_l_hand),
		list(/obj/item/weapon/crowbar, slot_in_backpack)
		),
	"Detective" = list(
		"access_detective", "access_courtroom", "access_brig", "access_security", "access_security_records",
		"access_medbay", "access_maintenance", "access_all_personal_lockers",
		list(/obj/item/weapon/clothing/under/forensics_red, slot_w_uniform),
		list(/obj/item/weapon/clothing/shoes/brown, slot_shoes),
		list(/obj/item/weapon/clothing/gloves/latex, slot_gloves),
		list(/obj/item/weapon/storage/fcard_kit, slot_in_backpack),
		list(/obj/item/weapon/fcardholder, slot_in_backpack),
		list(/obj/item/weapon/f_print_scanner, slot_in_backpack)
		),
	"Garbage Handler" = list(
		"access_trash_disposal", "access_maintenance",
		list(/obj/item/weapon/clothing/under/maintenance_blue, slot_w_uniform),
		list(/obj/item/weapon/clothing/shoes/brown, slot_shoes),
		list(/obj/item/weapon/clothing/gloves/latex, slot_gloves)
		)
	)

var/list/occupations = list()
var/list/assistant_occupations = list("Assistant")

world/New()
	. = ..()
	for(var/job in jobs)
		var/list/jobinfo = jobs[job]
		for(var/permission in jobinfo)
			if(istext(permission) && !(permission in permissions))
				world.log << "Job [job] has unrecognized permission [permission]"
	for(var/obj/start/S)
		if(!(S.name in jobs))
			world.log << "Start location found for unrecognized job [S.name]"
		else
			occupations += S.name

obj/var/list/req_access = null
obj/var/req_access_txt = ""
obj/New()
	if(src.req_access_txt)
		var/req_access_str = params2list(req_access_txt)
		var/req_access_changed = 0
		for(var/x in req_access_str)
			if(!(x in permissions))
				world.log << "[src] ([src.type]): [x] is not a recognized permission"
				continue
			if(!req_access_changed)
				req_access = list()
				req_access_changed = 1
			req_access += x
	..()

//returns 1 if this mob has sufficient access to use this object
obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return 1
	if(istype(M, /mob/ai))
		//AI can do whatever s/he wants
		return 1
	else if(istype(M, /mob/human))
		var/mob/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(src.check_access(H.equipped()) || src.check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/monkey))
		var/mob/monkey/george = M
		//they can only hold things :(
		if(src.check_access(george.equipped()))
			return 1
	return 0

/obj/proc/check_access(obj/item/weapon/card/id/I)
	if(!src.req_access) //no requirements
		return 1
	if(!istype(src.req_access, /list)) //something's very wrong
		return 1
	var/list/L = src.req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in src.req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	return 1

/proc/get_access(job)
	if(job in jobs)
		var/list/ac = new
		for(var/p in jobs[job])
			if(istext(p))
				ac += p
		return ac
	else
		world.log << "Unknown job [job]"
		return list()

/proc/get_all_accesses()
	return permissions

/proc/get_access_desc(A)
	return permissions[A]

/proc/get_all_jobs()
	return jobs

jobitem
	var/path
	var/slot

/proc/GetJobItems(job)
	if(job in jobs)
		var/list/i = new
		for(var/list/l in jobs[job])
			if(istype(l, /list))
				var/jobitem/j = new
				j.path = l[1]
				j.slot = l[2]
				i += j
		return i
	else
		world.log << "Unknown job [job]"
		return list()

