/obj/item/weapon/flashlight/attack_self(mob/user)
	on = !on
	icon_state = "flight[on]"
	
	if (on)
		src.process()

/obj/item/weapon/flashlight/proc/process()
	lastHolder = null
	
	while (on)
		var/atom/holder = loc
		var/isHeld = 0
		
		if (ismob(holder))
			isHeld = 1
		else
			isHeld = 0
			if (lastHolder != null)
				lastHolder:luminosity = 0
				lastHolder = null
		
		if (isHeld == 1)
			if (holder != lastHolder && lastHolder != null)
				lastHolder:luminosity = 0
			holder:luminosity = 5
			lastHolder = holder
			
		luminosity = 5
		sleep(10)
	
	if (lastHolder != null)
		lastHolder:luminosity = 0
		lastHolder = null
	
	luminosity = 0;
