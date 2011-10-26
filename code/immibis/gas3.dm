var/const // gmol^-1
	MOLAR_MASS_CO2 = 44.01
	MOLAR_MASS_N2 = 28.01
	MOLAR_MASS_O2 = 32.00
	MOLAR_MASS_PLASMA = 114.23 // used octane
	MOLAR_MASS_N2O = 44.013

	// used the values for http://www.engineeringtoolbox.com/ at 275K (except for N2O)
	// converted from kJ/(K.kg) to J/(K.mol) with:
	// hc_mol = hc_kg * molar_mass
	// Also, since this is a game, they don't need to be exact
	HEAT_CAPACITY_CO2 = 36.04
	HEAT_CAPACITY_N2 = 29.10
	HEAT_CAPACITY_O2 = 29.28
	HEAT_CAPACITY_PLASMA = 245.6 // used octane - this would make plasma good for heat transfer, except that it explodes
	HEAT_CAPACITY_N2O = 29.00

var/const
	REGNAULT_CONSTANT = 8.314472 // constant in ideal gas equation

obj/minor_gas
	name = "generic minor gas"
	var/molar_mass = 1 // gmol^-1
	var/amount = 0 // mol
	var/heat_capacity = 1 // J(K.mol)^-1  -- ie Joules per Kelvin per mole

	proc/copy_from(obj/minor_gas/o)
		amount = o.amount

	proc/add_from(obj/minor_gas/o)
		amount += o.amount

obj/substance/gas
	name = "gas"

	// moles
	var/co2 = 0
	var/n2 = 0
	var/o2 = 0
	var/plasma = 0
	var/n2o = 0

	var/volume = 1 // cubic meters
	var/temperature = T20C // kelvins
	var/pressure = 0 // pascals
	var/heat_capacity = 0 // joules per kelvin, updated at the same time as total_moles
	var/total_moles = 0 // mol

	var/list/minor = new // list of (path)=(/obj/minor_gas instance)

	proc/tostring()
		return "v=[volume] t=[temperature] p=[pressure] hc=[heat_capacity] moles=[total_moles] co2=[co2] n2=[n2] plasma=[plasma] o2=[o2] n2o=[n2o]"

	// interface procs
	proc
		set_volume(v) // change volume and update pressure (amount and temperature are constant)
			volume = v
			_calc_pressure()

		set_temp(t) // change temperature and update pressure (amount and volume are constant)
			temperature = t
			_calc_pressure()

		set_heat(h)
			var/shc = heat_capacity
			if(h == 0 && shc != 0)
				//CRASH("Tried to set 0 heat")
				return
			if(h != 0 && shc == 0)
				//CRASH("Tried to add heat to empty gas mixture")
				return
			if(shc == 0)
				return
			temperature = h / shc
			_calc_pressure()

		add_delta(obj/substance/gas/g) // add amount and update pressure (without changing volume or temperature)
			var/heat = get_heat() + g.get_heat()
			co2 += g.co2
			n2 += g.n2
			o2 += g.o2
			plasma += g.plasma
			n2o += g.n2o
			for(var/mg_path in g.minor)
				var/obj/minor_gas/mg = g.minor[mg_path]
				var/obj/minor_gas/mg2
				if(!(mg.type in minor))
					mg2 = new mg.type()
					mg2.copy_from(mg)
					minor[mg.type] = mg2
				else
					mg2 = minor[mg.type]
					mg2.add_from(mg)
			_calc_total()
			set_heat(heat)
			_calc_pressure()

		sub_delta(obj/substance/gas/g) // subtract amount and update pressure (without changing volume or temperature)
			var/heat = get_heat() - g.get_heat()
			co2 -= g.co2
			n2 -= g.n2
			o2 -= g.o2
			plasma -= g.plasma
			n2o -= g.n2o
			for(var/mg_path in g.minor)
				var/obj/minor_gas/mg = g.minor[mg_path]
				var/obj/minor_gas/mg2
				if(mg.type in minor)
					mg2 = minor[mg.type]
					mg2.amount -= mg.amount
					if(mg2.amount <= 0)
						minor -= mg2
						del(mg2)
			_calc_total()
			set_heat(heat)
			_calc_pressure()

		get_heat()
			return temperature * heat_capacity

		add_co2(var/amt)
			co2 += amt
			total_moles += amt
			heat_capacity += amt*HEAT_CAPACITY_CO2
			_calc_pressure()
		add_n2(var/amt)
			n2 += amt
			total_moles += amt
			heat_capacity += amt*HEAT_CAPACITY_N2
			_calc_pressure()
		add_o2(var/amt)
			o2 += amt
			total_moles += amt
			heat_capacity += amt*HEAT_CAPACITY_O2
			_calc_pressure()
		add_plasma(var/amt)
			plasma += amt
			total_moles += amt
			heat_capacity += amt*HEAT_CAPACITY_PLASMA
			_calc_pressure()
		add_n2o(var/amt)
			n2o += amt
			total_moles += amt
			heat_capacity += amt*HEAT_CAPACITY_N2O
			_calc_pressure()

		// you can alter the gas amounts directly if you call this afterwards
		amt_changed()
			_calc_total()
			_calc_pressure()

		remove_all_gas()
			if(total_moles == 0)
				return
			co2 = 0
			n2 = 0
			o2 = 0
			plasma = 0
			n2o = 0
			temperature = 2.7
			if(minor.len > 0)
				for(var/mg_path in minor)
					del(minor[mg_path])
				minor = list()
			total_moles = 0
			pressure = 0

		divide_scalar(n)
			co2 /= n
			n2 /= n
			o2 /= n
			plasma /= n
			n2o /= n
			temperature /= n
			total_moles /= n
			for(var/mg_path in minor)
				var/obj/minor_gas/mg = minor[mg_path]
				mg.amount /= n
			_calc_pressure()

		partial_pressure_to_moles(pp)
			// pV = nRT
			// n = pV/RT
			return pp * volume / (REGNAULT_CONSTANT * temperature)

		copy_from(obj/substance/gas/g) // copy all attributes, including volume
			co2 = g.co2
			n2 = g.n2
			o2 = g.o2
			plasma = g.plasma
			n2o = g.n2o
			/*if(minor.len > 0)
				for(var/mg_path in minor)
					del(minor[mg_path])
				minor = list()
			for(var/mg_path in g.minor)
				var/obj/minor_gas/mg = g.minor[mg_path]
				var/obj/minor_gas/mg2 = new mg.type()
				mg2.copy_from(mg)
				minor[mg.type] = mg2*/
			pressure = g.pressure
			temperature = g.temperature
			total_moles = g.total_moles
			heat_capacity = g.heat_capacity
			volume = g.volume

		get_frac(f)
			f = min(max(f, 0), 1)
			var/obj/substance/gas/ret = new
			ret.co2 = co2 * f
			ret.n2 = n2 * f
			ret.o2 = o2 * f
			ret.plasma = plasma * f
			ret.n2o = n2o * f
			ret.heat_capacity = heat_capacity * f
			ret.temperature = temperature
			if(minor.len > 0)
				for(var/mg_path in minor)
					var/obj/minor_gas/mg = minor[mg_path]
					var/obj/minor_gas/mg2 = new mg.type()
					mg2.copy_from(mg)
					mg2.amount *= f
					ret.minor[mg.type] = mg2
			ret.amt_changed()
			return ret

	// internal procs
	proc
		_calc_pressure()
			pressure = total_moles * REGNAULT_CONSTANT * temperature / volume

		_calc_total()
			var/t = co2 + n2 + o2 + plasma + n2o
			for(var/obj/minor_gas/mg in minor)
				t += mg.amount
			total_moles = t

			t = 0
			t += co2*HEAT_CAPACITY_CO2
			t += n2*HEAT_CAPACITY_N2
			t += o2*HEAT_CAPACITY_O2
			t += plasma*HEAT_CAPACITY_PLASMA
			t += n2o*HEAT_CAPACITY_N2O
			for(var/mg_path in minor)
				var/obj/minor_gas/mg = minor[mg_path]
				t += mg.heat_capacity * mg.amount
			heat_capacity = t

	// compatibility procs
	proc
		transfer_from(obj/substance/gas/G, var/amt)
			if(G.total_moles == 0)
				return
			if(amt > G.total_moles)
				amt = G.total_moles
			var/obj/substance/gas/delta = G.get_frac(amt / G.total_moles)
			G.sub_delta(delta)
			add_delta(delta)





proc/equalize_gas(obj/substance/gas/gas1, obj/substance/gas/gas2)
	var/delta_gt = FLOWFRAC * (gas1.pressure - gas2.pressure) / 2

	var/avg_temp = 0

	if(gas1.heat_capacity > 0.001 && gas2.heat_capacity > 0.001)
		avg_temp = (gas1.temperature * gas1.heat_capacity + gas2.temperature * gas2.heat_capacity) / (gas1.heat_capacity + gas2.heat_capacity)

	var/obj/substance/gas/delta

	if(delta_gt < 0)
		delta = gas2.get_frac(-delta_gt / gas2.pressure)
		gas2.sub_delta(delta)
		gas1.add_delta(delta)
	else if(delta_gt > 0)
		delta = gas1.get_frac(delta_gt / gas1.pressure)
		gas1.sub_delta(delta)
		gas2.add_delta(delta)

	if(avg_temp > 0)
		gas1.set_temp(avg_temp)
		gas2.set_temp(avg_temp)

proc/equalize_gas_multiple(list/gasses)
	// this is O(N^2) but very simple...
	for(var/k in 1 to gasses.len)
		for(var/j in k+1 to gasses.len)
			equalize_gas(gasses[k], gasses[j])


	/*var/total_pressure_times_volume = 0
	var/total_vol = 0
	for(var/obj/substance/gas/G in gasses)
		total_pressure_times_volume += G.pressure * G.volume
		total_vol += G.volume

	var/avg_pressure = total_vol

	*/