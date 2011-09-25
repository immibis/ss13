/obj/machinery/hologram_ai/New()
	..()

/obj/machinery/hologram_ai/attack_ai(user as mob)
	src.show_console(user)
	return

/obj/machinery/hologram_ai/proc/render()
	var/icon/I = new /icon( 'icons/ss13/human.dmi', "male" )
	if (src.lumens >= 0)
		I.Blend(rgb(src.lumens, src.lumens, src.lumens), 0)
	else
		I.Blend(rgb(- src.lumens,  -src.lumens,  -src.lumens), 1)
	I.Blend(new /icon( 'icons/ss13/human.dmi', "mouth" ), 3)
	var/icon/U = new /icon( 'icons/ss13/human.dmi', "diaper" )
	U.Blend(U, 3)
	U = new /icon( 'icons/ss13/mob.dmi', "hair_a" )
	U.Blend(rgb(src.h_r, src.h_g, src.h_b), 0)
	I.Blend(U, 3)
	src.projection.icon = I
	return

/obj/machinery/hologram_ai/proc/show_console(var/mob/user as mob)
	var/dat
	user.machine = src
	if (src.temp)
		dat = text("[]<BR><BR><A href='?src=\ref[];temp=1'>Clear</A>", src.temp, src)
	else
		dat = text("<B>Hologram Status:</B><HR>\nPower: <A href='?src=\ref[];power=1'>[]</A><HR>\n<B>Hologram Control:</B><BR>\nColor Luminosity: []/220 <A href='?src=\ref[];reset=1'>\[Reset\]</A><BR>\nLighten: <A href='?src=\ref[];light=1'>1</A> <A href='?src=\ref[];light=10'>10</A><BR>\nDarken: <A href='?src=\ref[];light=-1'>1</A> <A href='?src=\ref[];light=-10'>10</A><BR>\n<BR>\nHair Color: ([],[],[]) <A href='?src=\ref[];h_reset=1'>\[Reset\]</A><BR>\nRed (0-255): <A href='?src=\ref[];h_r=-300'>\[0\]</A> <A href='?src=\ref[];h_r=-10'>-10</A> <A href='?src=\ref[];h_r=-1'>-1</A> [] <A href='?src=\ref[];h_r=1'>1</A> <A href='?src=\ref[];h_r=10'>10</A> <A href='?src=\ref[];h_r=300'>\[255\]</A><BR>\nGreen (0-255): <A href='?src=\ref[];h_g=-300'>\[0\]</A> <A href='?src=\ref[];h_g=-10'>-10</A> <A href='?src=\ref[];h_g=-1'>-1</A> [] <A href='?src=\ref[];h_g=1'>1</A> <A href='?src=\ref[];h_g=10'>10</A> <A href='?src=\ref[];h_g=300'>\[255\]</A><BR>\nBlue (0-255): <A href='?src=\ref[];h_b=-300'>\[0\]</A> <A href='?src=\ref[];h_b=-10'>-10</A> <A href='?src=\ref[];h_b=-1'>-1</A> [] <A href='?src=\ref[];h_b=1'>1</A> <A href='?src=\ref[];h_b=10'>10</A> <A href='?src=\ref[];h_b=300'>\[255\]</A><BR>", src, (src.projection ? "On" : "Off"),  -src.lumens + 35, src, src, src, src, src, src.h_r, src.h_g, src.h_b, src, src, src, src, src.h_r, src, src, src, src, src, src, src.h_g, src, src, src, src, src, src, src.h_b, src, src, src)
	user << browse(dat, "window=hologram_console")
	return

/obj/machinery/hologram_ai/Topic(href, href_list)
	..()
	if (!istype(usr, /mob/ai))
		return

	if (href_list["power"])
		if (src.projection)
			src.icon_state = "hologram0"
			//src.projector.projection = null
			del(src.projection)
		else
			src.projection = new /obj/projection( src.loc )
			src.projection.icon = 'icons/ss13/human.dmi'
			src.projection.icon_state = "male"
			src.icon_state = "hologram1"
			src.render()
	else if (href_list["h_r"])
		if (src.projection)
			src.h_r += text2num(href_list["h_r"])
			src.h_r = min(max(src.h_r, 0), 255)
			render()
	else if (href_list["h_g"])
		if (src.projection)
			src.h_g += text2num(href_list["h_g"])
			src.h_g = min(max(src.h_g, 0), 255)
			render()
	else if (href_list["h_b"])
		if (src.projection)
			src.h_b += text2num(href_list["h_b"])
			src.h_b = min(max(src.h_b, 0), 255)
			render()
	else if (href_list["light"])
		if (src.projection)
			src.lumens += text2num(href_list["light"])
			src.lumens = min(max(src.lumens, -185.0), 35)
			render()
	else if (href_list["reset"])
		if (src.projection)
			src.lumens = 0
			render()
	else if (href_list["temp"])
		src.temp = null
	src.show_console(usr)