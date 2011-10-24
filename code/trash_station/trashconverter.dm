#define TRASHCONVERTER_TRASH_RATIO 0.0002	// ratio of input gas to weight of trash used
#define TRASHCONVERTER_GAS_RATIO 2			// ratio of output gas to input gas
#define TRASHCONVERTER_MIN_GAS 1			// how much gas to 'pretend' there is, used for starting the converter with no gas available
#define TRASHCONVERTER_HEAT_RATIO 10		// heat energy per unit of output gas

obj/machinery/trashconverter
	icon = 'icons/immibis/trashconverter.dmi'
	density = 1
	opacity = 0
	anchored = 1
	trash_acceptor
		name = "trash converter"
		icon_state = "trash_acceptor"
		layer = OBJ_LAYER + 1

		density = 0

		var/obj/machinery/trashconverter/main/connect = null

		New()
			..()
			spawn(5)
				while(!connect)
					connect = locate() in get_step(src, WEST)
					sleep(5)

		CheckPass(O, oldloc)
			return isobj(O)

		process()
			if((stat & BROKEN) || !connect)
				return
			var/matter = 0
			for(var/obj/O in loc)
				if(O == src)
					continue
				matter += O.weight
				del(O)
			connect.avail_matter += matter

	main
		icon = 'icons/immibis/trashconverter.dmi'
		parent_type = /obj/machinery/atmospherics/unary
		density = 1
		opacity = 0
		anchored = 1
		name = "trash converter"
		icon_state = "main"
		var
			obj/substance/gas/ngas
			avail_matter = 0
		capmult = 1
		New()
			ngas = new
			p_dir = SOUTH
			dir = SOUTH
			..()

		process()
			ngas.copy_from(gas)

			// uses co2, n2, or n2o (and matter) to create o2 and plasma (and heat)
			var/source_gas = max(gas.co2 + gas.n2 + gas.n2o, TRASHCONVERTER_MIN_GAS)*0.8
			var/matter = source_gas / TRASHCONVERTER_TRASH_RATIO
			if(matter > avail_matter)
				if(!matter)
					return
				source_gas *= avail_matter / matter
				matter = avail_matter
			avail_matter -= matter

			if(gas.co2 + gas.n2 + gas.n2o > TRASHCONVERTER_MIN_GAS)
				var/co2_fraction = gas.co2 / (gas.co2 + gas.n2 + gas.n2o)
				var/n2_fraction = gas.n2 / (gas.co2 + gas.n2 + gas.n2o)
				var/n2o_fraction = gas.n2o / (gas.co2 + gas.n2 + gas.n2o)
				ngas.co2 -= co2_fraction * source_gas
				ngas.n2 -= n2_fraction * source_gas
				ngas.n2o -= n2o_fraction * source_gas

			// try to make the o2 and plasma amounts in the pipe equal
			var/bias = gas.o2 - gas.plasma
			var/produced_total = source_gas * TRASHCONVERTER_GAS_RATIO
			var/produced_o2 = 0
			var/produced_plasma = 0
			var/produced_heat = 0
			if(bias < 0)
				produced_o2 = -bias
			else
				produced_plasma = bias
			produced_total -= abs(bias)
			produced_o2 += produced_total/2
			produced_plasma += produced_total/2
			produced_heat = (produced_o2 + produced_plasma) * TRASHCONVERTER_HEAT_RATIO

			ngas.plasma += produced_plasma
			ngas.o2 += produced_o2
			ngas.amt_changed()
			if(ngas.total_moles)
				ngas.set_heat(ngas.get_heat() + produced_heat)

			gas.copy_from(ngas)
