turf/space/gaseous
	icon = 'icons/immibis/gascloud.dmi'
	icon_state = ""
	name = "gas cloud"
	updatecell()
		gas.temperature = 2.7
		gas.o2 = 1000000
		gas.plasma = 1000000
		gas.n2 = 1000000
		gas.co2 = 1000000
		gas.n2o = 1000000
		gas.amt_changed()
