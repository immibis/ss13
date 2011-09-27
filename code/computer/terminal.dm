obj/machinery/terminal
	var/base_icon_state
	var/msg_history

	New()
		. = ..()
		base_icon_state = icon_state

	icon = 'icons/goonstation/computer.dmi'
	icon_state = "computer_generic"

	proc/print(msg)
		msg_history += "\n" + msg
		if(lentext(msg_history) > 3000)
			msg_history = copytext(msg_history, 1, 2000)
		for(var/client/C)
			if(C.term_current == src)
				C << output(msg, "termwnd.termout")

	attack_ai(mob/user)
		add_fingerprint(user)
		interact(user)

	attack_hand(mob/user)
		add_fingerprint(user)
		interact(user)

	proc/interact(mob/user)
		if(stat & (BROKEN|NOPOWER))
			return

		user.client.term_open(src)

	Topic(href, href_list[])
		update_icon()

	proc/update_icon()
		if(stat & NOPOWER)
			icon_state = "[base_icon_state]0"
		else if(stat & BROKEN)
			icon_state = "[base_icon_state]b"
		else
			icon_state = base_icon_state

	power_change()
		. = ..()
		update_icon()
		if(stat & (BROKEN|NOPOWER))
			for(var/client/C)
				if(C.term_current == src)
					C.term_close()

	# override these
	proc/opened(mob/M)
	proc/closed()
	proc/command(cmd as text)


client
	var/tmp/obj/machinery/terminal/term_current

	verb/termcmd(cmd as text)
		set hidden = 1
		set name = ".termcmd"
		if(term_current != null)
			term_current.command(cmd)

	verb/termclose()
		set hidden = 1
		set name = ".termclose"
		if(term_current != null)
			term_close()

	proc/term_open(obj/machinery/computer2/terminal)
		if(term_current == terminal)
			return
		if(term_current != null)
			term_close()
		if(terminal == null)
			return
		winset(src, "termwnd.termcmd", "text=")
		src << output(null, "termwnd.termout")
		src << output(terminal.msg_history, "termwnd.termout")
		winshow(src, "termwnd", 1)
		term_current = terminal
		terminal.opened(mob)

	proc/term_close()
		if(term_current == null)
			return
		winshow(src, "termwnd", 0)
		term_current.closed()
		term_current = null

	verb/