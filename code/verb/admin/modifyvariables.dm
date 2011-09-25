/client/proc/modifyvariables(obj/O as obj|mob|turf|area)
	set category = "Debug"
	set name = "edit variables"
	set desc="(target) Edit a target item's variables"

	if(!src.holder)
		src << "Only administrators may use this command."
		return

	var/variable = input("Which var?","Var") in O.vars
	var/default
	var/typeof = O.vars[variable]
	var/dir

	if(isnull(typeof))
		usr << "Unable to determine variable type."

	else if(isnum(typeof))
		usr << "Variable appears to be <b>NUM</b>."
		default = "num"
		dir = 1

	else if(istext(typeof))
		usr << "Variable appears to be <b>TEXT</b>."
		default = "text"

	else if(isloc(typeof))
		usr << "Variable appears to be <b>REFERENCE</b>."
		default = "reference"

	else if(isicon(typeof))
		usr << "Variable appears to be <b>ICON</b>."
		typeof = "\icon[typeof]"
		default = "icon"

	else if(istype(typeof,/atom) || istype(typeof,/datum))
		usr << "Variable appears to be <b>TYPE</b>."
		default = "type"

	else if(istype(typeof,/list))
		usr << "Variable appears to be <b>LIST</b>."
		default = "cancel"

	else if(istype(typeof,/client))
		usr << "Variable appears to be <b>CLIENT</b>."
		default = "cancel"

	else
		usr << "Variable appears to be <b>FILE</b>."
		default = "file"

	usr << "Variable contains: [typeof]"
	if(dir)
		switch(typeof)
			if(1)
				dir = "NORTH"
			if(2)
				dir = "SOUTH"
			if(4)
				dir = "EAST"
			if(8)
				dir = "WEST"
			if(5)
				dir = "NORTHEAST"
			if(6)
				dir = "SOUTHEAST"
			if(9)
				dir = "NORTHWEST"
			if(10)
				dir = "SOUTHWEST"
			else
				dir = null
		if(dir)
			usr << "If a direction, direction is: [dir]"

	var/class = input("What kind of variable?","Variable Type",default) in list("text",
		"num","type","reference","icon","file","restore to default","cancel")

	switch(class)
		if("cancel")
			return

		if("restore to default")
			O.vars[variable] = initial(O.vars[variable])

		if("text")
			O.vars[variable] = input("Enter new text:","Text",\
				O.vars[variable]) as text

		if("num")
			O.vars[variable] = input("Enter new number:","Num",\
				O.vars[variable]) as num

		if("type")
			O.vars[variable] = input("Enter type:","Type",O.vars[variable]) \
				in typesof(/obj,/mob,/area,/turf)

		if("reference")
			O.vars[variable] = input("Select reference:","Reference",\
				O.vars[variable]) as mob|obj|turf|area in world

		if("file")
			O.vars[variable] = input("Pick file:","File",O.vars[variable]) \
				as file

		if("icon")
			O.vars[variable] = input("Pick icon:","Icon",O.vars[variable]) \
				as icon

	world.log_admin("[src.key] modified [O.name]'s [variable] to [O.vars[variable]]")
	return