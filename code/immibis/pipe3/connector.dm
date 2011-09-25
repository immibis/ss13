
obj/machinery/atmospherics/unary/connector
	name = "Connector"
	icon = 'icons/ss13/pipes.dmi'
	desc = "A connector for gas canisters."
	icon_state = "connector"
	anchored = 1.0
	p_dir = 2
	var/capacity = 6000000.0
	capmult = 2
	var/flag = 0
	var/obj/machinery/atmoalter/connected = null

	New()
		..()
		gasflowlist += src
		spawn(5)
			var/obj/machinery/atmoalter/A = locate(/obj/machinery/atmoalter, src.loc)

			if(A)
				connected = A
				A.anchored = 1
				A.c_status = 3

	examine()
		set src in oview()
		..()
		if(connected)
			usr << "It is connected to \an [connected.name]."
		else
			usr << "It is unconnected."




	process()
		if(connected)
			if(connected.c_status == 1 || connected.c_status == 2)
				equalize_gas(connected.gas, gas)


