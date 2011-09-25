/obj/secloset
	desc = "An immobile card-locked storage closet."
	name = "Security Locker"
	icon = 'icons/ss13/stationobjs.dmi'
	icon_state = "1secloset0"
	density = 1
	var/opened = 0
	var/locked = 1
	var/broken = 0
/obj/secloset/animal
	name = "Animal Control"
	req_access = list("access_medical_supplies")
/obj/secloset/captains
	name = "Captain's Closet"
	req_access = list("access_captain")
/obj/secloset/medical1
	name = "Medicine Closet"
	req_access = list("access_medical_supplies")
/obj/secloset/medical2
	name = "Anesthetic"
	req_access = list("access_medical_supplies")
/obj/secloset/personal
	desc = "The first card swiped gains control."
	name = "Personal Closet"
	icon_state = "0secloset0"
/obj/secloset/security1
	name = "Security Equipment"
	req_access = list("access_security_lockers")
/obj/secloset/security2
	name = "Forensics Locker"
	req_access = list("access_forensics_lockers")

// todo: remove
/obj/secloset/toxin
	name = "Toxin Researcher Locker"
	req_access = list()