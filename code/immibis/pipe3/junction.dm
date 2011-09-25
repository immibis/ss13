obj/machinery/atmospherics/junction
	name = "junction"
	icon = 'icons/ss13/junct-pipe.dmi'
	icon_state = "junction"
	desc = "A junction between regular and heat-exchanger pipework."
	anchored = 1
	dir = 2
	p_dir = 3
	capmult = 2

	var/obj/substance/gas/gas
	var/datum/pipe_network/net

	New()
		. = ..()
		p_dir = dir | turn(dir, 180)

	set_gas(dir, gas)
		src.gas = gas
	set_network(dir, net)
		src.net = net
	get_network(dir)
		return net

	get_p_type(dir)
		return (dir == src.dir ? PIPE_HEAT_EXCH : PIPE_NORMAL)

/*

// this intentionally does NOT connect both its sides to the same network,
// in order to slow gas transfer

obj/machinery/atmospherics/junction
	name = "junction"
	icon = 'icons/ss13/junct-pipe.dmi'
	icon_state = "junction"
	desc = "A junction between regular and heat-exchanger pipework."
	var/capacity = 6000000
	anchored = 1
	dir = 2
	p_dir = 3

	capmult = 2

	var
		obj/substance/gas
			p_gas
			h_gas
		datum/pipe_network
			p_net
			h_net

	New()
		. = ..()
		p_dir = dir | turn(dir, 180)

	set_gas(dir, obj/substance/gas/gas)
		if(dir == src.dir)
			h_gas = gas
		else
			p_gas = gas

	get_network(dir)
		return (dir == src.dir ? h_net : p_net)

	set_network(dir, datum/pipe_network/net)
		if(dir == src.dir)
			h_net = net
		else
			p_net = net

	get_p_type(dir)
		return (dir == src.dir ? PIPE_HEAT_EXCH : PIPE_NORMAL)


	process()
		equalize_gas(p_gas, h_gas)
*/