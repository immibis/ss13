obj/item/sheet/metal/proc
	make_rods()
		var/obj/item/rods/R = new /obj/item/rods( usr.loc )
		R.amount = 2
	make_chair()
		var/obj/stool/chair/C = new /obj/stool/chair( usr.loc )
		C.dir = usr.dir
		if (C.dir == NORTH)
			C.layer = 5
	make_oxycan()
		var/obj/machinery/atmoalter/canister/oxygencanister/C = new /obj/machinery/atmoalter/canister/oxygencanister( usr.loc )
		C.gas.o2 = 0
	make_plcan()
		var/obj/machinery/atmoalter/canister/poisoncanister/C = new /obj/machinery/atmoalter/canister/poisoncanister( usr.loc )
		C.gas.plasma = 0
	make_n2can()
		var/obj/machinery/atmoalter/canister/n2canister/C = new /obj/machinery/atmoalter/canister/n2canister( usr.loc )
		C.gas.n2 = 0
	make_n2ocan()
		var/obj/machinery/atmoalter/canister/anesthcanister/C = new /obj/machinery/atmoalter/canister/anesthcanister( usr.loc )
		C.gas.n2o = 0
	make_co2can()
		var/obj/machinery/atmoalter/canister/co2canister/C = new /obj/machinery/atmoalter/canister/co2canister( usr.loc )
		C.gas.co2 = 0
	make_aircan()
		var/obj/machinery/atmoalter/canister/aircanister/C = new /obj/machinery/atmoalter/canister/aircanister( usr.loc )
		C.gas.n2 = 0
		C.gas.o2 = 0
	make_reinforced_metal()
		var/obj/item/sheet/r_metal/C = new /obj/item/sheet/r_metal( usr.loc )
		C.amount = 1
	make_tiles()
		var/obj/item/tile/R = new /obj/item/tile( usr.loc )
		R.amount = 4
	construct_wall()
		if (src.amount < 2)
			return 1
		var/turf/F = usr.loc
		if (!istype(F, /turf/simulated/floor))
			return 1
		src.amount -= 2
		var/turf/simulated/wall/W = F.ReplaceWithWall()
		W.icon_state = "girder"
		W.updatecell = 1
		W.opacity = 0
		W.state = 1
		W.density = 1
		W.levelupdate()
		W.buildlinks()

	construct_teg()
		var/turf/W = get_step(usr.loc, WEST)
		var/turf/E = get_step(usr.loc, EAST)
		var/turf/C = usr.loc
		if(!W || !E || !C || !isturf(W) || !isturf(E) || !isturf(C) || W.density || E.density)
			usr << "\blue Not enough space."
			return 1
		if(!W.isempty() || !E.isempty())
			usr << "\blue There is an object in the way."
			return 1
		var/obj/machinery/atmospherics/binary/circulator/circW = new(W)
		var/obj/machinery/atmospherics/binary/circulator/circE = new(E)
		circW.side = 1
		circE.side = 2
		circW.updateicon()
		circE.updateicon()
		var/obj/machinery/power/generator/gen = new(C)
		gen.updateicon()

	construct_turbine()
		var/turf/W = get_step(usr.loc, WEST)
		var/turf/C = usr.loc
		if(!W || !C || !isturf(W) || !isturf(C) || W.density)
			usr << "\blue Not enough space."
			return 1
		if(!W.isempty())
			usr << "\blue There is an object in the way."
			return 1
		new /obj/machinery/compressor(W)
		new /obj/machinery/power/turbine(C)

var/list/buildable_with_metal = list(
	// "id" = list("description", amount, type-or-proc),
	// procs can return 1 to cancel (and not use any metal)
	"rods" = list("Make 2 metal rods", 1, "make_rods"),
	"table" = list("Make table parts", 2, /obj/item/table_parts),
	"stool" = list("Make stool", 1, /obj/stool),
	"chair" = list("Make chair", 1, "make_chair"),
	"rack" = list("Make rack parts", 1, /obj/item/rack_parts),
	"o2can" = list("Make empty O2 canister", 2, "make_oxycan"),
	"plcan" = list("Make empty plasma canister", 2, "make_plcan"),
	//"n2can" = list("Make empty N2 canister", 2, "make_n2can"),
	//"n2ocan" = list("Make empty N2O canister", 2, "make_n2ocan"),
	//"co2can" = list("Make empty CO2 canister", 2, "make_co2can"),
	//"aircan" = list("Make empty air canister", 2, "make_aircan"),
	"closet" = list("Make closet", 2, /obj/closet),
	"reinforced" = list("Make reinforced sheet", 2, "make_reinforced"),
	"tiles" = list("Make 4 floor tiles", 1, "make_tiles"),
	"bed" = list("Make bed", 1, /obj/stool/bed),
	"wall" = list("Construct wall", 1, "construct_wall")

	// Why the fuck did I ever add these?
//	"generator" = list("Construct thermo-electric generator", 3, "construct_teg"),
//	"turbine" = list("Construct gas turbine", 2, "construct_turbine")
	)

/obj/item/sheet/metal/attack_hand(mob/user as mob)
	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/sheet/metal/F = new /obj/item/sheet/metal( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			del(src)
			return
	else
		..()
	src.force = 5
	return

/obj/item/sheet/metal/attackby(obj/item/sheet/metal/W as obj, mob/user as mob)
	if (!( istype(W, /obj/item/sheet/metal) ))
		return
	if (W.amount >= 5)
		return
	if (W.amount + src.amount > 5)
		src.amount = W.amount + src.amount - 5
		W.amount = 5
	else
		W.amount += src.amount
		//SN src = null
		del(src)
		return
	return

/obj/item/sheet/metal/examine()
	set src in view(1)
	..()
	usr << "There are [amount] metal sheet\s on the stack."

/obj/item/sheet/metal/attack_self(mob/user as mob)
	var/t1 = "<HTML><HEAD></HEAD><BODY><span style='font-size: small;'><TT>Amount Left: [src.amount] <BR>"
	for(var/item in buildable_with_metal)
		var/list/data = buildable_with_metal[item]
		if(src.amount >= data[2])
			t1 += "<A href='?src=\ref[src];make=[item]'>[data[1]]</A> ([data[2]] metal)<BR>"
		else
			t1 += "[item[1]] (<span style='color: red;'>need [data[2]] metal</span>)<BR>"
	t1 += "</TT></span></HTML>"
	user << browse(t1, "window=metal_sheet")
	return

/obj/item/sheet/metal/Topic(href, href_list)
	..()
	if ((usr.restrained() || usr.stat || usr.equipped() != src))
		return
	if (href_list["make"])
		if (src.amount < 1)
			del(src)
			return
		var/item = buildable_with_metal[href_list["make"]]
		if(src.amount < item[2])
			return
		if(ispath(item[3]))
			var/path = item[3]
			src.amount -= item[2]
			new path(usr.loc)
		else if(istext(item[3]))
			// hascall is buggy if the name has a _ in it
			//if(!hascall(src, item[3]))
			//	CRASH("Build callback doesn't exist in /obj/item/sheet/metal: [item[3]]")
			if(call(src, item[3])() != 1)
				src.amount -= item[2]
		else
			CRASH("Build callback not a path or text: [item[3]]")
		if(src.amount <= 0)
			usr.unequip(src)
			del(src)
			usr << browse(null, "window=met_sheet")
			return
	spawn(0)
		src.attack_self(usr)