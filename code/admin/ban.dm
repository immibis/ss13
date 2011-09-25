var
	crban_bannedmsg="<font color=red><big><tt>You have been banned from [world.name]</tt></big></font>"
	crban_preventbannedclients = 0 // Don't enable this, it'll throw null runtime errors due to the convolted way ss13 logs you in
	crban_keylist[0]  // Banned keys and their associated IP addresses
	crban_reason[0]	// Banned key+reason
	crban_time[0]	// Banned key+time
	crban_bannedby[0]	// who banned them
	crban_iplist[0]   // Banned IP addresses
	crban_ipranges[0] // Banned IP ranges
	crban_unbanned[0] // So we can remove bans (list of ckeys)
	crban_runonce	// Updates legacy bans with new info

/proc/crban_fullban(mob/M, reason, banner)
	// Ban the mob using as many methods as possible, and then boot them for good measure
	if (!M || !M.key || !M.client) return
	crban_removeunban(M.ckey)
	crban_key(M.ckey, M.client.address)
	crban_IP(M.client.address, M.ckey)
	crban_client(M.client)
	crban_ie(M)
	//Reason+time
	if(!reason)	reason = "No reason specified"
	if(!crban_reason.Find(M.ckey))
		crban_reason.Add(M.ckey)
		crban_reason[M.ckey] = reason
	if(!banner)	banner = "Unspecified"
	if(!crban_bannedby.Find(M.ckey))
		crban_bannedby.Add(M.ckey)
		crban_bannedby[M.ckey] = banner
	if(!crban_time.Find(M.ckey))
		crban_time.Add(M.ckey)
		var/time = time2text(world.realtime,"DD-MMM-YYYY")
		crban_time[M.ckey] = time
	//need to put above into functions
	crban_savebanfile()
	del M


/proc/crban_fullbanclient(client/C, reason, banner)
	// Equivalent to above, but is passed a client
	if (!C) return
	crban_removeunban(C.ckey)
	crban_key(C.ckey, C.address)
	crban_IP(C.address, C.ckey)
	crban_client(C)
	crban_ie(C)
	//Reason+time
	if(!reason)	reason = "No reason specified"
	if(!crban_reason.Find(C.ckey))
		crban_reason.Add(C.ckey)
		crban_reason[C.ckey] = reason
	if(!banner)	banner = "Unspecified"
	if(!crban_bannedby.Find(C.ckey))
		crban_bannedby.Add(C.ckey)
		crban_bannedby[C.ckey] = banner
	if(!crban_time.Find(C.ckey))
		crban_time.Add(C.ckey)
		var/time = time2text(world.realtime,"DD-MMM-YYYY")
		crban_time[C.ckey] = time
	//need to put above into functions
	crban_savebanfile()
	del C

/proc/crban_isbanned(X)
	// When given a mob, client, key, or IP address:
	// Returns 1 if that person is banned.
	// Returns 0 if they are not banned.
	// Only considers basic key and IP bans; but that is sufficient for most purposes.
	if (istype(X,/mob)) X=X:ckey
	if (istype(X,/client)) X=X:ckey
	if (ckey(X) in crban_unbanned) return 0
	if ((X in crban_iplist) || (ckey(X) in crban_keylist)) return 1
	else return 0

/proc/crban_isunbanned(X)
	X=ckey(X)
	if(crban_unbanned.Find(X))
		return 1
	return 0

/proc/crban_removeunban(X)
	X=ckey(X)
	if(crban_unbanned.Find(X))
		crban_unbanned.Remove(X)
		crban_savebanfile()
		return 1
	return 0

/proc/crban_getworldid()
	var/worldid=world.address
	while (findtext(worldid,"."))
		worldid=copytext(worldid,1,findtext(worldid,"."))+"_"+copytext(worldid,findtext(worldid,".")+1)
	return worldid

/proc/crban_ie(mob/M)
	var/html="<html><body onLoad=\"document.cookie='cr[crban_getworldid()]=k; \
expires=Fri, 31 Dec 2060 23:59:59 UTC'\"; document.write(document.cookie)></body></html>"
	M << browse(html,"window=crban;titlebar=0;size=1x1;border=0;clear=1;can_resize=0")
	sleep(3)
	M << browse(null,"window=crban")

/proc/crban_IP(address, key)
	if (!crban_iplist.Find(address) && address && address!="localhost" && address!="127.0.0.1")
		crban_iplist.Add(address)
		crban_iplist[address] = ckey(key)

/proc/crban_iprange(partialaddress as text, appendperiod=1)
	//// Bans a range of IP addresses, given by "partialaddress". See the comments at the top of this file.
	//// If "appendperiod" is false, the ban will match partial numbers in the IP address.
	//// Again, see the comments at the top of this file.
	//// Returns the range of IP addresses banned, or null upon failure (e.g. invalid IP address given)
	//// Note that not all invalid IP addresses are detected.

	// Parse for valid IP address
	partialaddress=crban_parseiprange(partialaddress, appendperiod)

	// We don't want to end up banning everyone
	if (!partialaddress) return null

	// Add IP range
	if (partialaddress in crban_ipranges)
		usr << "The IP range '[partialaddress]' is already banned."
	else
		crban_ipranges += partialaddress

	// Ban affected clients
	for (var/client/C)
		if (!C.mob) continue // Sanity check
		if (copytext(C.address,1,length(partialaddress)+1)==partialaddress)
			usr << "Key '[C.key]' [C.mob.name!=C.key ? "([C.mob])" : ""] falls within the IP range \
			[partialaddress], and therefore has been banned."
			crban_fullban(C.mob)

	// Return what we banned
	return partialaddress

/proc/crban_parseiprange(partialaddress, appendperiod=1)
	// Remove invalid characters (everything except digits and periods)
	var/charnum=1
	while (charnum<=length(partialaddress))
		var/char=copytext(partialaddress,charnum,charnum+1)
		if (char==",")
			// Replace commas with periods (common typo)
			partialaddress=copytext(partialaddress,1,charnum)+"."+copytext(partialaddress,charnum+1)
		else if (!(char in list("0","1","2","3","4","5","6","7","8","9",".")))
			// Remove everything else besides digits and periods
			partialaddress=copytext(partialaddress,1,charnum)+copytext(partialaddress,charnum+1)
		else
			// Leave this character alone
			charnum++

	// If all of the characters were invalid, quit while we're a head
	if (!partialaddress) return null

	// Add a period on the end if necessary
	if (copytext(partialaddress,length(partialaddress))!=".")
		// Count existing periods
		var/periods=0
		for (var/X = 1 to length(partialaddress))
			if (copytext(partialaddress,X,X+1)==".") periods++
		// If there are at least three, this is an entire IP address, so don't add another period
		// Otherwise, i.e. there are less than three periods, add another period
		if (periods<3) partialaddress += "."

	return partialaddress

/proc/crban_key(key as text,address as text)
	var/ckey=ckey(key)
	crban_unbanned.Remove(ckey)
	if (!crban_keylist.Find(ckey))
		crban_keylist.Add(ckey)
	crban_keylist[ckey] = address

/proc/crban_unban(key as text, by as text)
	//Unban a key and associated IP address
	var/ckey=ckey(key)
	if (key && crban_keylist.Find(ckey))
		crban_iplist.Remove(crban_keylist[ckey])
		crban_keylist.Remove(ckey)
		crban_reason.Remove(ckey)
		crban_time.Remove(ckey)
		crban_unbanned.Add(ckey)
		crban_unbanned[ckey] = by
		crban_savebanfile()
		return 1
	return 0

/proc/crban_client(client/C)
	var/F=C.Import()
	var/savefile/S = F ? new(F) : new()
	S["[ckey(world.url)]"]<<1
	C.Export(S)

/proc/crban_loadbanfile()
	var/savefile/S=new("cr_full.ban")
	S["key[0]"] >> crban_keylist
	world.log_admin("Loading crban_keylist")
	S["reason[0]"] >> crban_reason
	world.log_admin("Loading crban_reason")
	S["time[0]"] >> crban_time
	world.log_admin("Loading crban_time")
	S["bannedby[0]"] >> crban_bannedby
	world.log_admin("Loading crban_bannedby")
	S["IP[0]"] >> crban_iplist
	world.log_admin("Loading crban_iplist")
	S["unban[0]"] >> crban_unbanned
	world.log_admin("Loading crban_unbanned")
	S["runonce"] >> crban_runonce

	if (!length(crban_keylist))
		crban_keylist=list()
		world.log_admin("crban_keylist was empty")
	if (!length(crban_reason))
		crban_reason=list()
		world.log_admin("crban_reason was empty")
	if (!length(crban_time))
		crban_time=list()
		world.log_admin("crban_time was empty")
	if (!length(crban_bannedby))
		crban_bannedby=list()
		world.log_admin("crban_bannedby was empty")
	if (!length(crban_iplist))
		crban_iplist=list()
		world.log_admin("crban_iplist was empty")
	if (!length(crban_unbanned))
		crban_unbanned=list()
		world.log_admin("crban_unbanned was empty")

/proc/crban_savebanfile()
	var/savefile/S=new("cr_full.ban")
	S["key[0]"] << crban_keylist
	S["reason[0]"] << crban_reason
	S["time[0]"] << crban_time
	S["bannedby[0]"] << crban_bannedby
	S["IP[0]"] << crban_iplist
	S["unban[0]"] << crban_unbanned
	S["runonce"] << crban_runonce

/proc/crban_updatelegacybans()
	if(!crban_runonce)
		world.log_admin("Updating banfile!")
		// Updates bans.. Or fixes them. Either way.
		for(var/T in crban_keylist)
			if(!T)	continue
			var/reason = "Legacy Ban"
			if(!crban_reason.Find(T))
				crban_reason.Add(T)
				crban_reason[T] = reason
			var/bannedby = "Legacy"
			if(!crban_bannedby.Find(T))
				crban_bannedby.Add(T)
				crban_bannedby[T] = bannedby
			if(!crban_time.Find(T))
				crban_time.Add(T)
				var/time = time2text(world.realtime,"DD-MMM-YYYY")
				crban_time[T] = time
				world.log_admin("Updating [T]'s legacy ban!")
		for(var/U in crban_unbanned)
			if(!U)	continue
			if(crban_reason.Find(U))
				crban_reason.Remove(U)
			if(crban_time.Find(U))
				crban_time.Remove(U)
			crban_unbanned[U] = "Legacy"
		for(var/I in crban_iplist)
			if(!I) continue
			crban_iplist[I] = "Legacy"
		crban_runonce++	//don't run this update again

/world/IsBanned(key, ip)
	.=..()
	if (!. && crban_preventbannedclients)
		//// Key check
		if (crban_keylist.Find(ckey(key)))
			if (key!="Guest")
				crban_IP(ip)
			// Disallow login
			src << crban_bannedmsg
			return 1
		//// IP check
		if (crban_iplist.Find(address))
			if (crban_unbanned.Find(ckey(key)))
				//We've been unbanned
				crban_iplist.Remove(address)
			else
				//We're still banned
				crban_fullbanclient(src)
				src << crban_bannedmsg
				return 1
		//// IP range check
		for (var/X in crban_ipranges)
			if (findtext(address,X)==1)
				src << crban_bannedmsg
				return 1

/client/Topic(href, href_list[])
	if (href_list["cr"]=="ban")
		src << browse(null,"window=crban")
		if (href_list["cr"+crban_getworldid()]=="k")
			if (crban_unbanned.Find(ckey))
				// Unban
				var/html="<html><body onLoad=\"document.cookie='cr[crban_getworldid()]=n; \
				expires=Fri, 31 Dec 2060 23:59:59 UTC'\"></body></html>"
				mob << browse(html,"window=crunban;titlebar=0;size=1x1;border=0;clear=1;can_resize=0")
				spawn(10) mob << browse(null,"window=crunban")
			else
				world.log_access("Failed Login: [src] Reason: Cookie Banned")
				src << crban_bannedmsg
				var/reason = "Cookie banned (Multikey)"
				messageadmins("<font color='blue'>[src] was autobanned. Reason: [reason]</font>")
				crban_fullbanclient(src, reason)
				del src
	else	return ..()
// Debug code
/*
/client/verb/debugban()
	set category = "Debug"
	world <<	"DEBUGBAN()"
	world <<	"Banned Message: [crban_bannedmsg]"
	world <<	"preventbannedclients = [crban_preventbannedclients]"
	for(var/t in crban_keylist)
		world << "[t]"
		for(var/A in crban_keylist[t])
			world << "[crban_keylist[A]]"
	for(var/f in crban_iplist)
		world << "[f]"
	for(var/l in crban_ipranges)
		world << "[l]"
	for(var/k in crban_unbanned)
		world << "[k]"

/client/verb/savebans()
	set category = "Debug"
	var/savefile/S=new("cr_full.ban")
	world << "Saving to [S]"
	S["key[0]"] << crban_keylist
	world << "Saving crban_keylist"
	S["IP"] << crban_iplist
	world << "Saving crban_iplist"
	S["unban"] << crban_unbanned
	world << "Saving crban_unbanned"
	world << "Saved bans"

/client/verb/loadbans()
	set category = "Debug"
	var/savefile/S=new("cr_full.ban")
	world << "Loading from [S]"
	S["key[0]"] >> crban_keylist
	world << "Loading crban_keylist"
	S["IP"] >> crban_iplist
	world << "Loading crban_iplist"
	S["unban"] >> crban_unbanned
	world << "Loading crban_unbanned"
	if (!length(crban_keylist))
		crban_keylist=list()
		world << "crban_keylist was empty"
	if (!length(crban_iplist))
		crban_iplist=list()
		world << "crban_iplist was empty"
	if (!length(crban_unbanned))
		crban_unbanned=list()
		world << "crban_unbanned was empty"
	world << "Loaded bans"

/client/verb/addiptoban(key as text,address as text)
	set category ="Debug"
	var/ckey=ckey(key)
	crban_unbanned.Remove(ckey)
	if (!crban_keylist.Find(ckey))
		crban_keylist.Add(ckey)
	for(var/A in crban_keylist[ckey])
		if(A == address)	return
	crban_keylist[ckey] += "address"
*/