/obj/machinery/door/proc/checkForMultipleDoors()
	if(!src.loc)
		return 0
	for(var/obj/machinery/door/D in src.loc)
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return 0
	if(istype(src.loc, /turf/simulated/wall/false_wall) && src.loc.density)
		return 0
	if(istype(src.loc, /turf/simulated/wall/false_rwall) && src.loc.density)
		return 0
	return 1

/turf/simulated/wall/proc/checkForMultipleDoors()
	for(var/obj/machinery/door/D in locate(src.x,src.y,src.z))
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return 0
	//There are no false wall checks because that would be fucking retarded
	return 1