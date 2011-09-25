/obj/machinery/oneway/New()
	..()
	gas1 = new/obj/substance/gas(src)
	ngas1 = new/obj/substance/gas()
	gas2 = new/obj/substance/gas(src)
	ngas2 = new/obj/substance/gas()

	gasflowlist += src
	p_dir = dir|turn(dir, 180)

/obj/machinery/oneway/buildnodes()
	var/turf/T = src.loc

	node1 = get_machine(level, T, dir )
	node2 = get_machine(level, T , turn(dir, 180) )

	if(node1) vnode1 = node1.getline()
	if(node2) vnode2 = node2.getline()

	return

/obj/machinery/oneway/gas_flow()
	gas1.replace_by(ngas1)
	gas2.replace_by(ngas2)

/obj/machinery/oneway/process()

	var/delta_gt

	if(vnode1)
		delta_gt = FLOWFRAC * ( vnode1.get_gas_val(src) - gas1.tot_gas() / capmult)
		calc_delta( src, gas1, ngas1, vnode1, delta_gt)

	else
		leak_to_turf(1)

	if(vnode2)
		delta_gt = FLOWFRAC * ( vnode2.get_gas_val(src) - gas2.tot_gas() / capmult)
		calc_delta( src, gas2, ngas2, vnode2, delta_gt)

	else
		leak_to_turf(2)


	delta_gt = FLOWFRAC * (gas1.tot_gas() / capmult - gas2.tot_gas() / capmult)
	var/obj/substance/gas/ndelta = new()

	if(delta_gt < 0)		// then flowing from R2 to R1
		ndelta.set_frac(gas2, -delta_gt)
		ngas2.sub_delta(ndelta)
		ngas1.add_delta(ndelta)

/obj/machinery/oneway/get_gas_val(from)
	if(from == vnode2)
		return gas2.tot_gas()/capmult
	else
		return gas1.tot_gas()/capmult

/obj/machinery/oneway/get_gas(from)
	if(from == vnode2)
		return gas2
	return gas1

/obj/machinery/oneway/proc/leak_to_turf(var/port)
	var/turf/T

	switch(port)
		if(1)
			T = get_step(src, dir)
		if(2)
			T = get_step(src, turn(dir, 180) )

	if(T.density)
		T = src.loc
		if(T.density)
			return

	if(port==1)
		flow_to_turf(gas1, ngas1, T)
	else
		flow_to_turf(gas2, ngas2, T)

