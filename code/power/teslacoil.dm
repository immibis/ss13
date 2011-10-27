obj/machinery/power/teslacoil
	var/frequency = 140.5
	var/enabled = 1
	var/n_tag = null
	var/amount = 10000
	var/crackle_ticks = 0
	var/receiving = 0
	var/receiving_amount = 0
	var/last_receiving_amount = 0
	icon = 'icons/immibis/immibis_power.dmi'
	icon_state = "tesla-off"
	name = "Tesla coil"
	proc/send_interference()
		var/list/interfere = new
		for(var/obj/item/radio/R in interfere)
			if(R.freq == frequency)
				R.send_crackle() << "\icon[R] *BUZZ* *HISS* *BUZZ*"

	attack_hand(mob/user)
		add_fingerprint(user)
		if(stat & BROKEN) return
		interact(user)

	attack_ai(mob/user)
		attack_hand(user)

	proc/interact(mob/user)
		if ( (get_dist(src, user) > 1 ))
			if (!istype(user, /mob/ai))
				user.machine = null
				user << browse(null, "window=teslacoil")
				return

		user.machine = src

		var/displayname = n_tag ? "Tesla coil ([n_tag])" : "Tesla coil"
		var/t = "<H1>[displayname]</H1>"
		t += enabled ? "Transmitting power <A href='?src=\ref[src];enabled=0'>Disable</A><BR>" : "Not transmitting power <A href='?src=\ref[src];enabled=1'>Enable</A><BR>"
		t += "Frequency: <A href='?src=\ref[src];freq=-1'>-</A> <A href='?src=\ref[src];freq=-0.2'>-</A> [frequency] <A href='?src=\ref[src];freq=0.2'>+</A> <A href='?src=\ref[src];freq=1'>+</A><BR>"
		t += "Power transfer: <A href='?src=\ref[src];amount=-10000'>-</A> <A href='?src=\ref[src];amount=-1000'>-</A> <A href='?src=\ref[src];amount=-100'>-</A> <A href='?src=\ref[src];amount=-1'>-</A> [amount] <A href='?src=\ref[src];amount=1'>+</A> <A href='?src=\ref[src];amount=100'>+</A> <A href='?src=\ref[src];amount=1000'>+</A> <A href='?src=\ref[src];amount=10000'>+</A> ([TESLA_EFFICIENCY * 100]% efficiency)<BR>"
		t += receiving ? "Receiving power: [last_receiving_amount] W<BR>" : "Not receiving power<BR>"
		t += "<A href='?src=\ref[src];close=1'>Close</A>"

		user << browse(t, "window=teslacoil;size=460x300")

	Topic(href, href_list)
		if("close" in href_list)
			usr.machine = null
			usr << browse(null, "window=teslacoil")
			return

		if("enabled" in href_list)
			enabled = text2num(href_list["enabled"])
			if(!enabled)
				icon_state = "tesla-off"

		if("freq" in href_list)
			frequency += text2num(href_list["freq"])
			frequency = min(146.9, max(140.1, frequency))

		if("amount" in href_list)
			amount += text2num(href_list["amount"])
			amount = min(100000, max(0, amount))

		interact(usr)

	process(href, href_list)
		if(!powernet)
			return
		if(enabled)
			if(surplus() >= TESLA_OVERHEAD)
				add_load(TESLA_OVERHEAD)
				var/list/connected = new
				for(var/obj/machinery/power/teslacoil/T)
					if(T.frequency == frequency && T != src)
						connected += T
				if(connected.len != 0)
					var/transfer_amount = amount
					if(surplus() < transfer_amount/TESLA_EFFICIENCY)
						transfer_amount = surplus()*TESLA_EFFICIENCY
					for(var/obj/machinery/power/teslacoil/T in connected)
						T.add_avail(transfer_amount/connected.len)
						T.receiving = 2
						T.receiving_amount += transfer_amount/connected.len
					add_load(transfer_amount/TESLA_EFFICIENCY)
					if(enabled != 1)
						icon_state = "tesla-on"
						enabled = 1
				else if(enabled != 2)
					if(!receiving)
						icon_state = "tesla-low"
					enabled = 2
				crackle_ticks --
				if(crackle_ticks == 0)
					crackle_ticks = rand(1, 10)
					send_interference()
			else if(enabled != 3)
				if(!receiving)
					icon_state = "tesla-off"
				enabled = 3
		if(receiving > 0)
			receiving --
			icon_state = "tesla-on"
			last_receiving_amount = receiving_amount
			receiving_amount = 0
		else
			receiving = 0