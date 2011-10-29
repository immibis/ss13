/obj/item/flamethrower
	name = "flamethrower"
	icon_state = "flamethrower"
	s_istate = "flamethrower_0"
	desc = "You are a firestarter!"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	var/processing = 0
	var/obj/item/tank/plasma/attached = null
	var/throw_amount = 100
	var/lit = 0	//on or off
	var/turf/previousturf = null

/obj/item/flamethrower/proc/process()
	if(src.processing) //already doing this
		return
	src.processing = 1

	while(src.lit)
		var/turf/location = src.loc
		if(istype(location, /mob/))
			var/mob/M = location
			if(M.l_hand == src || M.r_hand == src)
				location = M.loc

		if(isturf(location)) //start a fire if possible
			location.firelevel = max(location.firelevel, location.gas.plasma + 1)

		sleep(10)
	processing = 0	//we're done

/obj/item/flamethrower/attackby(obj/item/tank/plasma/W as obj, mob/user as mob)
	if (istype(W,/obj/item/tank/plasma))
		if(attached)
			user << "\red There is already be a plasma tank loaded in the flamethrower!"
			return
		attached = W
		W.loc = src
		if (user.client)
			user.client.screen -= W
		user.unequip(W)
		lit = 0
		force = 3
		damtype = "brute"
		icon_state = "flamethrower_loaded_0"
		s_istate = "flamethrower_0"
	else if (istype(W, /obj/item/analyzer) && get_dist(user, src) <= 1 && attached)
		var/obj/item/icon = src
		for (var/mob/O in viewers(user, null))
			O << "\red [user] has used the analyzer on \icon[icon]"
			var/total = src.attached.gas.total_moles
			var/t1 = 0
			user << "\blue Results of analysis of \icon[icon]"
			if (total)
				user << "\blue Overall: [total] / [src.attached.maximum]"
				t1 = round( src.attached.gas.n2 / total * 100 , 0.0010)
				user << "\blue Nitrogen: [t1]%"
				t1 = round( src.attached.gas.o2 / total * 100 , 0.0010)
				user << "\blue Oxygen: [t1]%"
				t1 = round( src.attached.gas.plasma / total * 100 , 0.0010)
				user << "\blue Plasma: [t1]%"
				t1 = round( src.attached.gas.co2 / total * 100 , 0.0010)
				user << "\blue CO2: [t1]%"
				t1 = round( src.attached.gas.n2o / total * 100 , 0.0010)
				user << "\blue N2O: [t1]%"
				user << text("\blue Temperature: []&deg;C", src.attached.gas.temperature-T0C)
			else
				user << "\blue Tank is empty!"
	else	return	..()
	return

/obj/item/flamethrower/Topic(href,href_list[])
	if (href_list["close"])
		usr.machine = null
		usr << browse(null, "window=tank")
		return
	if(usr.stat || usr.restrained() || usr.lying)
		return
	usr.machine = src
	if (href_list["light"])
		if(!attached)	return
		if(attached.gas.plasma < 0.001)	return
		lit = !(lit)
		if(lit)
			icon_state = "flamethrower_loaded_1"
			s_istate = "flamethrower_1"
			force = 17
			damtype = "fire"
			spawn(0)	src.process()
		else
			icon_state = "flamethrower_loaded_0"
			s_istate = "flamethrower_0"
			force = 3
			damtype = "brute"
	if (href_list["amount"])
		src.throw_amount = src.throw_amount + text2num(href_list["amount"])
		src.throw_amount = max(0,min(5000,src.throw_amount))
	if (href_list["remove"])
		if(!attached)	return
		var/obj/item/tank/plasma/A = attached
		A.loc = get_turf(src)
		A.layer = initial(A.layer)
		attached = null
		lit = 0
		force = 3
		damtype = "brute"
		icon_state = "flamethrower"
		s_istate = "flamethrower_0"
		usr.machine = null
		usr << browse(null, "window=flamethrower")
	for(var/mob/M in viewers(1, src.loc))
		if ((M.client && M.machine == src))
			src.attack_self(M)
	return


/obj/item/flamethrower/attack_self(mob/user as mob)
	user.machine = src
	if (!src.attached)
		user << "\red Attach a plasma tank first!"
		return
	var/dat = text("<TT><B>Flamethrower (<A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>\nTank pressure: [round(attached.gas.pressure / 1000, 0.1)] kPa<BR>\nAmount to throw: <A HREF='?src=\ref[src];amount=-100'>-</A> <A HREF='?src=\ref[src];amount=-10'>-</A> <A HREF='?src=\ref[src];amount=-1'>-</A> [src.throw_amount] <A HREF='?src=\ref[src];amount=1'>+</A> <A HREF='?src=\ref[src];amount=10'>+</A> <A HREF='?src=\ref[src];amount=100'>+</A><BR>\n<A HREF='?src=\ref[src];remove=1'>Remove plasma</A> - <A HREF='?src=\ref[src];close'>Close</A></TT>")
	user << browse(dat, "window=flamethrower;size=600x300")
	return


// gets this from turf.dm turf/dblclick
/obj/item/flamethrower/proc/flame_turf(turflist)
	if(!lit)	return
	for(var/turf/T in turflist)
		if(T.density || istype(T, /turf/space))	return
		if(previousturf && LinkBlocked(previousturf, T))	return
		torch_turf(T)
	for(var/mob/M in viewers(1, src.loc))
		if ((M.client && M.machine == src))
			src.attack_self(M)
	return

/obj/item/flamethrower/proc/torch_turf(turf/T as turf)
	if (src.attached)
		if ((src.attached.gas.plasma - src.throw_amount*100) > 0)
			src.attached.gas.plasma -= src.throw_amount*100
			T.gas.plasma += src.throw_amount*1000	//flamethrowers add an extra 0 on just cause
			T.firelevel = max(src.attached.gas.temperature*25, T.firelevel)
			T.AddHotspot()
			sleep(1) //no instant line of fire silly
		else if(src.attached.gas.plasma > 0)
			T.gas.plasma += src.attached.gas.plasma
			src.attached.gas.plasma = 0
			T.firelevel = max(src.attached.gas.temperature*25, T.firelevel)
			T.AddHotspot()
			sleep(1)
		else
			lit = 0
			force = 3
			damtype = "brute"
			icon_state = "flamethrower_loaded_0"
			s_istate = "flamethrower_0"

		var/obj/substance/gas/delta = attached.gas.get_frac(1.0/3.0)
		delta.plasma = 0
		delta.amt_changed()
		T.gas.add_delta(delta)
		attached.gas.sub_delta(delta)

		previousturf = T
	return