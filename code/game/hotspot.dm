/obj/hotspot
	icon = 'icons/goonstation/hotspot.dmi'
	name = ""
	opacity = 0
	density = 0
	anchored = 1
	luminosity = 2
	layer = TURF_LAYER + 0.1
	Move()
		return 0
	New()
		. = ..()
		verbs -= verbs