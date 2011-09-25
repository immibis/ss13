obj/machinery/atmospherics/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger."
	icon = 'icons/ss13/pipes.dmi'
	icon_state = "circ1-off"
	p_dir = 3		// N & S
	var/side = 1 // 1=left 2=right
	var/status = 0
	var/rate = 1000000

	var/capacity = 6000000.0

	anchored = 1.0
	density = 1
	capmult = 1

	//var/obj/machinery/power/teg/master = null
	New()
		..()
		updateicon()

	proc/control(var/on, var/prate)
		rate = prate/100*capacity

		if(status == 1)
			if(!on)
				status = 2
				spawn(30)
					if(status == 2)
						status = 0
						updateicon()
		else if(status == 0)
			if(on)
				status = 1
		else	// status ==2
			if(on)
				status = 1

		updateicon()


	proc/updateicon()

		if(stat & NOPOWER)
			icon_state = "circ[side]-p"
			return

		var/is
		switch(status)
			if(0)
				is = "off"
			if(1)
				is = "run"
			if(2)
				is = "slow"

		icon_state = "circ[side]-[is]"

	power_change()
		..()
		updateicon()

	process()

		// if operating, pump from resv1 to resv2

		if(! (stat & NOPOWER) )				// only do circulator step if powered; still do rest of gas flow at all times
			if(status==1 || status==2)
				gas2.transfer_from(gas1, status==1? rate : rate/2)
				use_power(rate/capacity * CIRCULATOR_POWER)
			//ngas1.replace_by(gas1)
			//ngas2.replace_by(gas2)
