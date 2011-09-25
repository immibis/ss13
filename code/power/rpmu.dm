obj/machinery/power/remote_monitor
	icon_state = "rpmu"
	icon = 'icons/immibis/immibis_power.dmi'

	var/n_tag = null

	name = "Remote Power Monitor"

	process()
		. = ..()
		// use power, but still work without it
		add_load(min(surplus(), REMOTE_MONITOR_POWER))