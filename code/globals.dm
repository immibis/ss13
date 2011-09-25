/*  To-do list

	Bugs:
	hearing inside closets/pods
	check head protection when hit by tank etc.
	bug with two single-length pipes overlaying - pipeline ends up with no members
	alarm continuing when power out?

	New:
	make regular glass melt in fire
	Blood splatters, can sample DNA & analyze
	also blood stains on clothing - attacker & defender
	whole body anaylzer in medbay - shows damage areas in popup?
	try station map maximizing use of image rather than icon
	useful world/Topic commands
	flow rate maximum for pipes - slowest of two connected notes
	system for breaking / making pipes, handle deletion, pipeline spliting/rejoining etc.
	?give nominal values to all gas.maximum since turf_take depends on them
	add power-off mode for computers & other equipment (with reboot time)
	make grilles conductive for shocks (again)
	for prison warden/sec - baton allows precise targeting
	portable generator - hook to wire system
	modular repair/construction system
	maintainance key
	diagnostic tool
	modules - module construction
	hats/caps
	suit?
	build/unbuild engine floor with rf sheet
	finish compressor/turbine - think about control system, throttle, etc.
	crowbar opens airlocks when no power
*/

var
	savefile_ver = "3"
	SS13_version = "Plasma engine; New pipe system; Modified Kurper Stable/Goonstation"
	datum/air_tunnel/air_tunnel1/SS13_airtunnel = null
	datum/control/cellular/cellcontrol = null
	datum/control/gameticker/ticker = null
	obj/datacore/data_core = null
	obj/overlay/plmaster = null
	obj/overlay/slmaster = null
	going = 1.0
	master_mode = "random"//"extended"

	persistent_file = "mode.txt"

	nuke_code = null
	poll_controller = null
	datum/engine_eject/engine_eject_control = null
	host = null
	obj/hud/main_hud1 = null
	obj/hud/hud2/main_hud2 = null
	ooc_allowed = 1
	dna_ident = 1
	abandon_allowed = 1
	enter_allowed = 1
	shuttle_frozen = 0

	list/bombers = list(  )
	list/lastsignalers = list(	)	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
	list/admins = list(  )
	list/shuttles = list(  )
	list/reg_dna = list(  )
//	Bans handled by Crispy Fullban in /admin/ban.dm now
//	list/banned = list(  )

	CELLRATE = 0.002  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 2 units will be taken from a cell per tick)
	CHARGELEVEL = 0.01 // Cap for how fast cells charge, as a percentage-per-second (I think) (0.01 is 1%)

	shuttle_z = 2	//default
	airtunnel_start = 68 // default
	airtunnel_stop = 68 // default
	airtunnel_bottom = 72 // default
	list/monkeystart = list()
	list/prisonwarp = list()	//prisoners go to these
	list/prisonsecuritywarp = list()	//prison security goes to these
	list/prisonwarped = list()	//list of players already warped
	list/blobstart = list()
	list/blobs = list()
	list/cardinal = list( NORTH, SOUTH, EAST, WEST )


	datum/station_state/start_state = null
	datum/configuration/config = null
	datum/vote/vote = null
	datum/sun/sun = null

	list/plines = list()
	list/gasflowlist = list()
	list/machines = list()

	list/powernets = null

	defer_powernet_rebuild = 0		// true if net rebuild will be called manually after an event

	Debug = 0	// global debug switch

	datum/debug/debugobj

	datum/moduletypes/mods = new()

	wavesecret = 0

	join_motd = "Welcome to SS13!"
	auth_motd = null
	no_auth_motd = null

	//airlockWireColorToIndex takes a number representing the wire color, e.g. the orange wire is always 1, the dark red wire is always 2, etc. It returns the index for whatever that wire does.
	//airlockIndexToWireColor does the opposite thing - it takes the index for what the wire does, for example AIRLOCK_WIRE_IDSCAN is 1, AIRLOCK_WIRE_POWER1 is 2, etc. It returns the wire color number.
	//airlockWireColorToFlag takes the wire color number and returns the flag for it (1, 2, 4, 8, 16, etc)
	list/airlockWireColorToFlag = RandomAirlockWires()
	list/airlockIndexToFlag
	list/airlockIndexToWireColor
	list/airlockWireColorToIndex

	const/FIRE_DAMAGE_MODIFIER = 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
	const/AIR_DAMAGE_MODIFIER = 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
	const/INFINITY = 1e31 //closer then enough

	//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
	const/MAX_MESSAGE_LEN = 1024

	const/shuttle_time_in_station = 1800 // 3 minutes in the station
	const/shuttle_time_to_arrive = 6000 // 10 minutes to arrive

world
	mob = /mob/human
	turf = /turf/space
	area = /area
	view = "15x15"

//  Ricks hub
//	hub = "Slurm.SpaceStation13"
//	hub_password = ""
//	name = "Goonstation 13"

//  Exadv1 hub
//	hub = "Exadv1.spacestation13"
//	hub_password = "kMZy3U5jJHSiBQjr"
//	name = "Space Station 3.14159"

	//visibility = 0
	//loop_checks = 0