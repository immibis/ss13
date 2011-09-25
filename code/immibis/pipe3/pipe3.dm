var/const
	PIPE_NORMAL = 1
	PIPE_HEAT_EXCH = 2
	PIPE_SHUTTLE_PROPULSION = 3


datum/pipe_network
	var/obj/substance/gas/gas = new
	var/list/machines = new
	var/list/leaks = new

	New()
		. = ..()
		pipe3.networks += src

	Del()
		pipe3.networks -= src
		. = ..()

	proc/process()
		var/n = 0
		var/const/SPACE_CONSTANT = 1 // was 3
		for(var/obj/machinery/atmospherics/pipes/P in machines)
			n++
		for(var/obj/machinery/atmospherics/pipes/P in machines)
			var/turf/T = P.loc
			if(!isturf(T))
				continue
			if(T.density)
				continue
			if(P.level != 1)
				if(istype(T, /turf/space))
					P.gas.temperature += (T.gas.temperature - P.gas.temperature) / (SPACE_CONSTANT * P.insulation * n)
				else
					var/delta_T = (T.gas.temperature - P.gas.temperature) / P.insulation / n
					P.gas.temperature += delta_T
					var/tot_turf = max(1, T.gas.specific_heat_capacity())
					var/tot_node = P.gas.specific_heat_capacity()
					T.gas.temperature -= delta_T*min(10, tot_node/tot_turf)
			else
				if(istype(T, /turf/space))
					P.gas.temperature += (T.gas.temperature - P.gas.temperature) / (SPACE_CONSTANT * P.insulation * n)
		for(var/turf/T in leaks)
			flow_to_turf(T)

	proc/flow_to_turf(var/turf/T)
		equalize_gas(gas, T.gas)

obj/machinery/atmospherics

	var/p_type = PIPE_NORMAL

	anchored = 1

	proc
		set_gas(dir, obj/substance/gas/gas)
			CRASH("set_gas not implemented for [type]")
		get_network(dir)
			CRASH("get_network not implemented for [type]")
		set_network(dir, datum/pipe_network/net)
			CRASH("set_network not implemented for [type]")
		get_p_dir()
			return p_dir
		get_p_type(dir)
			return p_type

	// to link two directions together, have them share variables internally
	// (so get_network(EAST) returns the network set with set_network(WEST), for example)

	unary
		var/obj/substance/gas/gas
		var/datum/pipe_network/net

		set_gas(dir, obj/substance/gas/gas)
			if(src.dir == dir)
				src.gas = gas

		get_network(dir)
			if(src.dir == dir)
				return net
			return null

		set_network(dir, datum/pipe_network/net)
			if(src.dir == dir)
				src.net = net

		get_p_dir()
			return dir

	binary
		var/obj/substance/gas/{gas1; gas2}
		var/datum/pipe_network/{net1; net2}

		set_gas(dir, gas)
			if(dir == src.dir)
				gas1 = gas
			else if(dir == turn(src.dir, 180))
				gas2 = gas

		get_network(dir)
			return (dir == src.dir ? net1 : dir == turn(src.dir, 180) ? net2 : null)

		set_network(dir, net)
			if(dir == src.dir)
				net1 = net
			else if(dir == turn(src.dir, 180))
				net2 = net

		get_p_dir()
			return dir | turn(dir, 180)

datum/pipe3
	var/list/queue
	var/list/processed

	var/initializing

	var/list/networks

	proc/find_uninitialized_machine(list/processed)
		if(!initializing)
			CRASH("pipe3.find_uninitialized_machine can only be called while Pipe3 is initializing")
		for(var/obj/machinery/atmospherics/M)
			if(!(M in processed))
				return M
		return null

	proc/init_machine(obj/machinery/atmospherics/M, var/dir = 0)
		if(!initializing)
			CRASH("pipe3.init_machine can only be called while Pipe3 is initializing")
		if(dir == 0)
			var/p_dir = M.get_p_dir()
			if(p_dir & NORTH) init_machine(M, NORTH)
			if(p_dir & SOUTH) init_machine(M, SOUTH)
			if(p_dir & EAST) init_machine(M, EAST)
			if(p_dir & WEST) init_machine(M, WEST)
			return

		var/turf/OT = get_step(M, dir)
		var/o_dir = turn(dir, 180)

		var/ptype = M.get_p_type(dir)

		var/obj/machinery/atmospherics/M2 = null
		for(M2 in OT)
			if((M2.get_p_dir() & o_dir) && (M2.get_p_type(o_dir) == ptype))
				break

		var/datum/pipe_network/net = M.get_network(dir)
		if(!net)
			net = new
			net.machines += M
			M.set_network(dir, net)
			M.set_gas(dir, net.gas)

		if(!M2 || !(M2.get_p_dir() & o_dir) || (M2.get_p_type(o_dir) != ptype))
			if(OT.density)
				OT = M.loc
			if(!OT.density)
				net.leaks += OT
			return

		net.machines += M2
		var/datum/pipe_network/net2 = M2.get_network(o_dir)
		if(net2 && net2 != net)
			merge_nets(net2, net)
		else
			net.machines += M2
			M2.set_network(o_dir, net)
			M2.set_gas(o_dir, net.gas)

		queue += M2

	proc/merge_nets_2(obj/machinery/atmospherics/M, datum/pipe_network/net, datum/pipe_network/net2, dir)
		if(M.get_network(dir) == net2)
			net.machines += M
			M.set_network(dir, net)
			M.set_gas(dir, net.gas)

	proc/merge_nets(datum/pipe_network/net, datum/pipe_network/net2)
		for(var/obj/machinery/atmospherics/M in net2.machines)
			var/p_dir = M.get_p_dir()
			if(p_dir & NORTH) merge_nets_2(M, net, net2, NORTH)
			if(p_dir & SOUTH) merge_nets_2(M, net, net2, SOUTH)
			if(p_dir & EAST) merge_nets_2(M, net, net2, EAST)
			if(p_dir & WEST) merge_nets_2(M, net, net2, WEST)
		del(net2)

	proc/init()
		world.log_game("Initialising Pipe3")
		initializing = 1
		queue = new
		processed = new
		networks = new
		while(1)
			var/obj/machinery/atmospherics/next = find_uninitialized_machine(processed)
			if(!next)
				break
			queue = list(next)
			while(queue.len > 0)
				next = queue[1]
				queue -= next
				if(next in processed)
					continue
				processed += next
				init_machine(next)
		for(var/datum/pipe_network/N in networks)
			N.gas.volume = min(1, N.machines.len * 0.5)
		initializing = 0

var/datum/pipe3/pipe3
world/New()
	. = ..()
	spawn(5)
		pipe3 = new
		pipe3.init()