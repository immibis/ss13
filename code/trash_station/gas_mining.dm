var/obj/substance/gas/gspace_gas = new

turf/space/gaseous
	icon = 'icons/immibis/gascloud.dmi'
	icon_state = ""
	name = "gas cloud"

	New()
		. = ..()
		gas = gspace_gas
		ngas = gspace_gas

