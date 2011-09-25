/area
	var/fire = null
	var/atmos = 1
	var/poweralm = 1
	level = null
	name = "Space"
	icon = 'icons/ss13/areas.dmi'
	icon_state = "unknown"
	layer = 10
	mouse_opacity = 0
	var/lightswitch = 1

	var/eject = null

	var/requires_power = 1
	var/power_equip = 1
	var/power_light = 1
	var/power_environ = 1
	var/music = "music/music.ogg"
	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0

	var/numturfs = 0
	var/linkarea = null
	var/area/linked = null
	var/no_air = null

	var/primary_permission = null

/area/pregame
	icon_state = "start"
	requires_power = 0

/area/engine/

/area/turret_protected/

/area/arrival/start
	name = "Arrival Area"
	icon_state = "start"
	requires_power = 0

/area/arrival/shuttle
	name = "Arrival Shuttle"
	icon_state = "shuttle"
	requires_power = 0

/area/shuttle
	requires_power = 0
	name = "Escape Shuttle"
	icon_state = "shuttle"
	music = "music/escape.ogg"
	requires_power = 0

// === Trying to remove these areas:

/area/airtunnel1/      // referenced in airtunnel.dm:759

/area/dummy/           // Referenced in engine.dm:261

/area/shuttle_prison/  // referenced in shuttle.dm:57 and :86
	requires_power = 0
	name = "Prison Shuttle"
	icon_state = "shuttle"

/area/start            // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"
	requires_power = 0

// ===

/area/New()
	..()
	src.icon = 'icons/ss13/alert.dmi'
	src.layer = 10

	if(!requires_power)
		power_light = 1
		power_equip = 1
		power_environ = 1

	spawn(5)
		for(var/turf/T in src)		// count the number of turfs (for lighting calc)
			numturfs++				// spawned with a delay so turfs can finish loading
			if(no_air)
				T.gas.remove_all_gas()
				//T.res_vars()

		if(linkarea)
			linked = locate(text2path("/area/[linkarea]"))		// area linked to this for power calcs

	spawn(10)
		if(requires_power && !linked)
			for(var/obj/machinery/power/apc/APC in src)
				return
			world.log << "Area [src.type] should require power, but has no APC and is not linked"

	spawn(15)
		src.power_change()		// all machines set to current power level, also updates lighting icon

/proc/get_area(area/A)
	while(!istype(A, /area) && A)
		A = A.loc
	return A

/area/proc/atmosalert(var/state, var/obj/machinery/alarm/source)
	// state 2 == normal, 1 == recovering, 0 == alarm
	var/list/cameras = list()
	for (var/obj/machinery/camera/C in src)
		cameras += C
	for (var/mob/ai/aiPlayer in world)
		// maybe it'll just be easier to check the retval from trigger/cancel
		if (state == 0)
			// send off a trigger
			aiPlayer.triggerAlarm("Atmosphere", src, cameras, source)
			atmos = 0
		else if (state == 2)
			var/retval = aiPlayer.cancelAlarm("Atmosphere", src, source)
			if (retval == 0) // alarm(s) cleared
				atmos = 1
	return 1

/area/proc/poweralert(var/state, var/source)
	if (state != poweralm)
		poweralm = state
		var/list/cameras = list()
		for (var/obj/machinery/camera/C in src)
			cameras += C
		for (var/mob/ai/aiPlayer in world)
			if (state == 1)
				aiPlayer.cancelAlarm("Power", src, source)
			else
				aiPlayer.triggerAlarm("Power", src, cameras, source)
	return


/area/proc/firealert()
	if(src.name == "Space") //no fire alarms in space
		return
	if (!( src.fire ))
		src.fire = 1
		src.updateicon()
		src.mouse_opacity = 0
		for(var/obj/machinery/door/firedoor/D in src)
			if(D.operating)
				D.nextstate = CLOSED
			else if(!D.density)
				spawn(0)
					D.closefire()
		var/list/cameras = list()
		for (var/obj/machinery/camera/C in src)
			cameras += C
		for (var/mob/ai/aiPlayer in world)
			aiPlayer.triggerAlarm("Fire", src, cameras, src)
	return

/area/proc/firereset()
	if (src.fire)
		src.fire = 0
		src.mouse_opacity = 0
		src.updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			if(D.operating)
				D.nextstate = OPEN
			else if(D.density)
				spawn(0)
					D.openfire()
		for (var/mob/ai/aiPlayer in world)
			aiPlayer.cancelAlarm("Fire", src, src)
	return

/area/proc/updateicon()
	if ((fire || eject) && power_environ)
		if(fire && !eject)
			icon_state = "blue"
		else if(!fire && eject)
			icon_state = "red"
		else
			icon_state = "blue-red"
	else
		if(lightswitch && power_light)
			icon_state = null
		else
			icon_state = "dark128"
	if(lightswitch && power_light)
		luminosity = 1;
	else
		luminosity = 0;

/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(var/chan)		// return true if the area has power to given channel
	if(!requires_power)
		return 1
	switch(chan)
		if(EQUIP)
			return power_equip
		if(LIGHT)
			return power_light
		if(ENVIRON)
			return power_environ

	return 0

// called when power status changes

/area/proc/power_change()
	for(var/obj/machinery/M in src)		// for each machine in the area
		M.power_change()				// reverify power status (to update icons etc.)

	spawn(rand(15,25))
		src.updateicon()

	if(linked)
		linked.power_equip = power_equip
		linked.power_light = power_light
		linked.power_environ = power_environ
		linked.power_change()

/area/proc/usage(var/chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += used_light
		if(EQUIP)
			used += used_equip
		if(ENVIRON)
			used += used_environ
		if(TOTAL)
			used += used_light + used_equip + used_environ

	if(linked)
		return linked.usage(chan) + used
	else
		return used

/area/proc/clear_usage()
	if(linked)
		linked.clear_usage()
	used_equip = 0
	used_light = 0
	used_environ = 0

/area/proc/use_power(var/amount, var/chan)
	switch(chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount

/area/proc/calc_lighting()
	if(lightswitch && power_light)
		used_light += numturfs * LIGHTING_POWER