// the power cable object

var/list/nwnets = new

/obj/net_cable
	level = 1
	anchored = 1
	var/datum/nwnet/nwnet
	name = "network cable"
	desc = "A flexible cable for data transfer."
	icon = 'icons/immibis/network.dmi'
	icon_state = "0-1"
	var/d1 = 0
	var/d2 = 1
	layer = 2.5

	pixel_x = 3
	pixel_y = 3

	proc/get_connections()
		var/list/L = new
		if(d1)
			// full cable connects to matching cables on adjacent tiles
			var/d = turn(d1, 180)
			for(var/obj/net_cable/C in get_step(loc, d1))
				if(C.d1 == d || C.d2 == d)
					L += C
		else
			// half-cable connects to all other half-cables on the same tile
			for(var/obj/net_cable/C in loc)
				if(!C.d1)
					L += C
		var/d = turn(d2, 180)
		for(var/obj/net_cable/C in get_step(loc, d2))
			if(C.d1 == d || C.d2 == d)
				L += C
		return L

/obj/item/net_cable_coil
	name = "cable coil"
	var/amount = MAXCOIL
	icon = 'icons/immibis/network.dmi'
	icon_state = "coil"
	desc = "A coil of network cable."
	w_class = 2
	flags = TABLEPASS|USEDELAY|FPRINT
	s_istate = "coil"


/obj/net_cable/New()
	..()


	// ensure d1 & d2 reflect the icon_state for entering and exiting cable

	var/dash = findtext(icon_state, "-")

	d1 = text2num( copytext( icon_state, 1, dash ) )

	d2 = text2num( copytext( icon_state, dash+1 ) )

	var/turf/T = src.loc			// hide if turf is not intact

	if(level==1) hide(T.intact)


/obj/net_cable/Del()
	if(!defer_powernet_rebuild)	// set if network will be rebuilt manually
		nwnet.cut_cable(src)
	..()

/obj/net_cable/hide(var/i)

	invisibility = i ? 101 : 0
	updateicon()

/obj/net_cable/proc/updateicon()
	if(invisibility)
		icon_state = "[d1]-[d2]-f"
	else
		icon_state = "[d1]-[d2]"


/obj/net_cable/attackby(obj/item/W, mob/user)

	var/turf/T = src.loc
	if(T.intact)
		return

	if(istype(W, /obj/item/wirecutters))

		if(src.d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			new/obj/item/net_cable_coil(T, 2)
		else
			new/obj/item/net_cable_coil(T, 1)

		for(var/mob/O in viewers(src, null))
			O.show_message("\red [user] cuts the cable.", 1)

		defer_powernet_rebuild = 0		// to fix no-action bug
		del(src)

	else if(istype(W, /obj/item/net_cable_coil) && src.type == W:cable_type)

		var/obj/item/net_cable_coil/coil = W

		coil.cable_join(src, user)

	src.add_fingerprint(user)

/obj/net_cable/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if (prob(50))
				new /obj/item/net_cable_coil(src.loc, src.d1 ? 2 : 1)
				del(src)

		if(3.0)
			if (prob(25))
				new /obj/item/net_cable_coil(src.loc, src.d1 ? 2 : 1)
				del(src)
	return

/obj/net_cable/burn(fi_amount)
	if(fi_amount > 1800000)
		var/turf/T = src.loc
		if(!T.intact)
			if(prob(10))
				defer_powernet_rebuild = 0
				del(src)

// the cable coil object, used for laying cable

/obj/item/net_cable_coil/New(loc, length = MAXCOIL)
	src.amount = length
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	updateicon()
	..(loc)

/obj/item/net_cable_coil/cut/icon_state = "coil2"

/obj/item/net_cable_coil/cut/New(loc)
	..(loc)
	src.amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	updateicon()

/obj/item/net_cable_coil/proc/updateicon()
	if(amount == 1)
		icon_state = "coil1"
		name = "cable piece"
	else if(amount == 2)
		icon_state = "coil2"
		name = "cable piece"
	else
		icon_state = "coil"
		name = "cable coil"

/obj/item/net_cable_coil/examine()
	set src in view(1)

	if(amount == 1)
		usr << "A short piece of network cable."
	else if(amount == 2)
		usr << "A piece of network cable."
	else
		usr << "A coil of network cable. There are [amount] lengths of cable in the coil."

/obj/item/net_cable_coil/attackby(obj/item/W, mob/user)
	if( istype(W, /obj/item/wirecutters) && src.amount > 1)
		src.amount--
		new src.type(user.loc, 1)
		user << "You cut a piece off the cable coil."
		src.updateicon()
		return

	else if( W.type == src.type )
		var/obj/item/net_cable_coil/C = W
		if(C.amount == MAXCOIL)
			user << "The coil is too long, you cannot add any more cable to it."
			return

		if( (C.amount + src.amount <= MAXCOIL) )
			C.amount += src.amount
			user << "You join the cable coils together."
			C.updateicon()
			del(src)
			return

		else
			user << "You transfer [MAXCOIL - src.amount ] length\s of cable from one coil to the other."
			src.amount -= (MAXCOIL-C.amount)
			src.updateicon()
			C.amount = MAXCOIL
			C.updateicon()
			return

/obj/item/net_cable_coil/proc/use(var/used)
	if(src.amount < used)
		return 0
	else if (src.amount == used)
		del(src)
	else
		amount -= used
		updateicon()
		return 1

// called when net_cable_coil is clicked on a turf/simulated/floor

/obj/item/net_cable_coil/proc/turf_place(turf/simulated/floor/F, mob/user)

	if(!isturf(user.loc))
		return

	if(get_dist(F,user) > 1)
		user << "You can't lay cable at a place that far away."
		return

	if(F.intact)		// if floor is intact, complain
		user << "You can't lay cable there unless the floor tiles are removed."
		return

	else
		var/dirn

		if(user.loc == F)
			dirn = user.dir			// if laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(F, user)

		for(var/obj/net_cable/LC in F)
			if(LC.d1 == dirn || LC.d2 == dirn)
				user << "There's already a cable at that position."
				return

		var/obj/net_cable/C = new(F)
		C.d1 = 0
		C.d2 = dirn
		C.add_fingerprint(user)
		C.updateicon()
		C.update_network()
		use(1)
		//src.laying = 1
		//last = C


// called when net_cable_coil is click on an installed obj/net_cable

/obj/item/net_cable_coil/proc/cable_join(obj/net_cable/C, mob/user)


	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		user << "You can't lay cable at a place that far away."
		return


	if(U == T)		// do nothing if we clicked a cable we're standing on
		return		// may change later if can think of something logical to do

	var/dirn = get_dir(C, user)

	if(C.d1 == dirn || C.d2 == dirn)		// one end of the clicked cable is pointing towards us
		if(U.intact)						// can't place a cable if the floor is complete
			user << "You can't lay cable there unless the floor tiles are removed."
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for(var/obj/net_cable/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					user << "There's already a cable at that position."
					return

			var/obj/net_cable/NC = new(U)
			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint()
			NC.updateicon()
			NC.update_network()
			use(1)
	else if(C.d1 == 0)		// exisiting cable doesn't point at our position, so see if it's a stub
							// if so, make it a full cable pointing from it's old direction to our dirn

		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn

		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/net_cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if(LC.d1 == nd1 || LC.d2 == nd1 || LC.d1 == nd2 || LC.d2 == nd2)	// make sure no cable matches either direction
				user << "There's already a cable at that position."
				return
		del(C)
		var/obj/net_cable/NC = new(T)
		NC.d1 = nd1
		NC.d2 = nd2
		NC.add_fingerprint()
		NC.updateicon()
		NC.update_network()

		use(1)


// called when a new cable is created
// can be 1 of 3 outcomes:
// 1. Isolated cable (or only connects to isolated machine) -> create new powernet
// 2. Joins to end or bridges loop of a single network (may also connect isolated machine) -> add to old network
// 3. Bridges gap between 2 networks -> merge the networks (must rebuild lists also)



/obj/net_cable/proc/update_network()
	// easy way: do /makepowernets again
	makenwnets()
	// do things more logically if this turns out to be too slow
	// may just do this for case 3 anyway (simpler than refreshing list)





