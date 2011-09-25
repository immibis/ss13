#define PROPULSION_PLASMA_USE 1000
#define SHUTTLE_HEATER_GAS_USE 100

/obj/machinery/atmospherics
	unary
		shuttle_propulsion
			p_type = PIPE_SHUTTLE_PROPULSION
			icon = 'icons/ss13/shuttle.dmi'
			icon_state = "propulsion"
			density = 1
			name = "propulsion"

			var/allow_active = 1
			var/active = 1
			var/was_active = 0

			process()
				if(was_active != active)
					was_active = active
					icon_state = active ? "propulsion-1" : "propulsion"

				if(active)
					if(gas.temperature < T0C + 100 || gas.plasma < PROPULSION_PLASMA_USE)
						active = 0
					else
						gas.plasma -= PROPULSION_PLASMA_USE
						gas.temperature *= (gas.plasma / (gas.plasma + PROPULSION_PLASMA_USE))
				else
					if(allow_active && gas.temperature >= T0C + 100 && gas.plasma > PROPULSION_PLASMA_USE * 3)
						active = 1

	shuttle_heater
		icon = 'icons/ss13/shuttle.dmi'
		icon_state = "heater"
		var/active = 1
		var/was_active = 0
		density = 1
		name = "heater"

		var/datum/pipe_network
			p_net
			m_net
		var/obj/substance/gas
			p_gas
			m_gas

		Click()
			. = ..()
			active = !active

		get_network(dir)
			return (dir == src.dir ? p_net : m_net)
		set_network(dir, net)
			if(dir == src.dir)
				p_net = net
			else
				m_net = net
		set_gas(dir, gas)
			if(dir == src.dir)
				p_gas = gas
			else
				m_gas = gas

		get_p_type(dir)
			return (dir == src.dir ? PIPE_SHUTTLE_PROPULSION : PIPE_NORMAL)

		New()
			. = ..()
			p_dir = dir | turn(dir, -90) | turn(dir, 90)

		process()
			if(was_active != active)
				was_active = active
				icon_state = active ? "heater-1" : "heater"

			if(active)
				var/need_temp = 0
				if(p_gas.temperature < T0C + 150)
					need_temp = T0C + 150 - p_gas.temperature
				if(need_temp > 0)
					var/need_fuel = need_temp * SHUTTLE_HEATER_GAS_USE
					if(need_fuel > m_gas.o2 || need_fuel > m_gas.plasma)
						active = 0
						return
					m_gas.o2 -= need_fuel
					m_gas.plasma -= need_fuel
					m_gas.amt_changed()
					p_gas.temperature += need_temp
					p_gas.amt_changed()
				var/need_gas = (10 * PROPULSION_PLASMA_USE - p_gas.plasma) / 5
				if(need_gas > 0)
					if(m_gas.plasma < need_gas)
						need_gas = m_gas.plasma
					if(need_gas == 0)
						active = 0
						return
					p_gas.plasma += need_gas
					p_gas.amt_changed()
