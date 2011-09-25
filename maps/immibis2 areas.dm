/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)
	music = "music/music.ogg"		(defaults to "music/music.ogg")
	primary_permission = "whatever"	(defaults to nothing)

*/

area
	corridor
		name = "Corridor"
		escape/name = "Escape corridor"
		sec_left
		sec_right
		sec_south
		bridge_south
		bridge_left
		bridge_right
		research
	bridge/name = "Bridge"
	bridge_lobby/name = "Bridge lobby"
	medical
		medbay/name = "Medbay"
		lobby/name = "Medbay lobby"
		cryo/name = "Cryo"
		robotics/name = "Robotics"
		storage/name = "Medical storage"
		freezer/name = "Freezer room"
		hallway/name = "Medbay hallway"
	security/name = "Security"
	detective/name = "Detective's office"
	brig/name = "Brig"
	atmospherics/name = "Atmospherics"
	engineering/name = "Engineering"
	cargobay/name = "Cargo bay"
	checkpoint/name = "Security checkpoint"
	gc_research/name = "Genetics/Chemistry"
	robotics/name = "Robotics"
	morgue/name = "Morgue"
	chapel/name = "Chapel"
	chapel/office/name = "Chapel office"
	maintenance
		name = "Maintenance"
		security
		southwest
		research_n
		research_c
		research_e
		chapel_s
		chapel
	pathology/name = "Pathology"
	toxins/name = "Toxins"
	prototype
		name = "Prototype Engine"
		smes/name = "Prototype Engine SMES room"
	turret_protected
		ai_upload/name = "AI Upload"
		ai_core/name = "AI Core"
