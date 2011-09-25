area/immibis
	engine
		icon_state = "engine"
		hot_loop/name = "Engine hot loop"
		cold_loop/name = "Engine cold loop"
		storage/name = "Engine storage"
		combustion/name = "Engine combustion chamber"
		name = "Engine"
		monitoring/name = "Engine monitoring"
		hallway/name = "Engine hallway"
	engineering/name = "Engineering"
	quartermasters/name = "Quartermaster's office"
	atmospherics
		name = "Atmospherics"
		gas_storage
			plasma/name = "Plasma storage"
			n2o/name = "N2O storage"
			oxy/name = "Oxygen storage"
			n2/name = "Nitrogen storage"
			co2/name = "CO2 storage"
			empty/name = "Excess gas storage"
	hallway
		primary
			north/name = "North Primary Hallway"
			east/name = "East Primary Hallway"
			west/name = "West Primary Hallway"
			south/name = "South Primary Hallway"
		secondary
			north/name = "North Secondary Hallway"
			east/name = "East Secondary Hallway"
			west/name = "West Secondary Hallway"
			south/name = "South Secondary Hallway"
		arrivals/name = "Arrival Shuttle Hallway"
	maintenance
		primary
			south/name = "South Primary Maintenance"
			east/name = "East Primary Maintenance"
			west/name = "West Primary Maintenance"
			north/name = "North Primary Maintenance"
		secondary
			north/name = "North Secondary Maintenance"
			west/name = "West Secondary Maintenance"
			se/name = "Southeast Secondary Maintenance"
		brig/name = "Brig Area Maintenance"
	bridge/name = "Bridge"
	checkpoint/name = "Security Checkpoint"
	med_research
		lobby/name = "Medical Research"
		genetics/name = "Genetics"
		chemistry/name = "Chemistry (INCOMPLETE)"
	toxins/name = "Toxins"
	teleporter/name = "Teleporter"
	solars
		north/name = "North Solar Array"
	security/name = "Security"
	eva/name = "EVA Storage"
	storage
		central/name = "Storage"
		sw/name = "Storage"
	det_office/name = "Detective's office"
	courtroom/name = "Courtroom"
	brig/name = "Brig"
	shuttle
		supply/name = "Supply shuttle"
		trash/name = "Garbage shuttle"
	trash/name = "Garbage disposal area"
	morgue/name = "Morgue"
	medbay/name = "Medical bay"
	ai_solar/name = "AI Solar Array"
	prototype/name = "Prototype engine"
	chapel/name = "Chapel"
	chapel_office/name = "Chapel office"
	recon_dock/name = "Recon pod dock"

area/turret_protected/immibis
	ai_upload/name = "AI Upload"
	ai/name = "AI Core"
	ai_maint/name = "AI Maintenance Tunnel"

area/immibis_trash_station
	docking_bay/name = "Garbage station docking bay"
	operations/name = "Garbage station operations"
	main/name = "Garbage station main area"
	compactor/name = "Trash compactor"
	incinerator/name = "Incinerator"
	north/name = "Garbage station"
	recycler/name = "Recycler"
	calc_lighting()
		if(lightswitch && power_light)
			used_light += numturfs * 4 // otherwise the power requirement is way too high