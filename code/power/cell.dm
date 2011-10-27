// the power cell
// charge from 0 to 100%
// fits in APC to provide backup power

/obj/item/cell/New()
	..()

	charge = charge * maxcharge/100.0		// map obj has charge as percentage, convert to real value here

	spawn(5)
		updateicon()


/obj/item/cell/proc/updateicon()

	if(maxcharge <= 2500)
		icon_state = "cell"
	else
		icon_state = "hpcell"

	overlays = null

	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		overlays += image('icons/immibis/power.dmi', "cell-o2")
	else
		overlays += image('icons/immibis/power.dmi', "cell-o1")

/obj/item/cell/proc/percent()		// return % charge of cell
	return 100.0*charge/maxcharge

/obj/item/cell/examine()
	set src in view(1)
	if(usr && !usr.stat)
		if(maxcharge <= 2500)
			usr << "[desc]\nThe manufacturer's label states this cell has a power rating of [maxcharge], and that you should not swallow it.\nThe charge meter reads [round(src.percent() )]%."
		else
			usr << "This power cell has an exciting chrome finish, as it is an uber-capacity cell type! It has a power rating of [maxcharge]!!!\nThe charge meter reads [round(src.percent() )]%."

