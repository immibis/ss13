datum/os/thinkdos
	var/datum/filesystem/FS = new

	var/datum/fs_dir/cur_dir
	var/datum/fs_file/copied = null

	var/datum/comp_program/cur_prog = null

	var/obj/item/card/id/login = null
	var/login_name = null

	// If an AI or cyborg logs in, login is null and login_name is "AIUSR"
	// Use login_name to check whether someone is logged in or not.

	boot()
		. = ..()
		cur_dir = FS.root
		term.print("Welcome to ThinkDOS.")
		term.print("Copyright (C) 2250 ThinkTronic Industries")

	quitprog()
		del(cur_prog)
		term.print("Welcome to ThinkDOS.")

	unboot()
		if(cur_prog != null)
			cur_prog.crash()
			del(cur_prog)

	receive_packet(sender, packet)
		if(cur_prog != null)
			cur_prog.receive_packet(sender, packet)

	command(cmd, mob/user)
		term.print("> [cmd]")

		if(cur_prog != null)
			cur_prog.command(cmd)
			return

		var/list/c_args = split(" ", cmd)
		cmd = c_args[1]
		c_args.Cut(1,2)

		var/datum/fs_dir/dir
		var/datum/fs_file/file

		if(cmd == "cls")
			term.clear_screen()
		else if(cmd == "cd")
			if(c_args.len != 1)
				term.print("Usage: cd DIRECTORY")
			else
				dir = FS.find_path(cur_dir, c_args[1])
				if(dir && istype(dir))
					term.print("Directory changed")
					cur_dir = dir
				else
					term.print("Directory not found")
		else if(cmd == "dir")
			for(var/name in cur_dir.contents)
				file = cur_dir.contents[name]
				if(istype(file))
					term.print("[name] [file.filetype]")
				else
					dir = file
					term.print("[name] DIR")
		else if(cmd == "root")
			cur_dir = FS.root
			term.print("Directory changed")
		else if(cmd == "rename")
			if(c_args.len != 2)
				term.print("Usage: rename OLDNAME NEWNAME")
			else
				var/oldn = c_args[1]
				var/newn = c_args[2]
				if(!cur_dir.get(oldn))
					term.print("File not found")
				else
					cur_dir.put(newn, cur_dir.get(oldn))
					cur_dir.remove(oldn)
					term.print("File renamed")
		else if(cmd == "copy")
			if(c_args.len != 1)
				term.print("Usage: copy FILENAME")
			else
				if(!cur_dir.get(args[1]))
					term.print("File not found")
				else
					file = cur_dir.get(args[1])
					if(!istype(file))
						term.print("Cannot copy directories.")
					else
						term.print("File copied.")
						copied = file
		else if(cmd == "paste")
			if(c_args.len != 1)
				term.print("Usage: paste FILENAME")
			else
				if(cur_dir.get(c_args[1]))
					term.print("A file or directory already exists with that name.")
				else
					cur_dir.put(c_args[1], new/datum/fs_file(copied.filetype, copied.data))
					term.print("File pasted.")
		else if(cmd == "makedir" || cmd == "mkdir")
			if(c_args.len != 1)
				term.print("Usage: mkdir FILENAME")
			else
				if(cur_dir.get(c_args[1]))
					term.print("A file or directory already exists with that name.")
				else
					var/err = FS.set_path(cur_dir, c_args[1], new/datum/fs_dir)
					if(err)
						term.print(err)
					else
						term.print("Directory created.")
		else if(cmd == "delete" || cmd == "del" || cmd == "rm")
			if(c_args.len != 1)
				term.print("Usage: rm FILENAME")
			else
				if(!cur_dir.get(c_args[1]))
					term.print("File not found.")
				else
					file = cur_dir.get(c_args[1])
					if(!istype(file))
						dir = file
						if(dir == FS.root)
							term.print("Cannot remove root directory.")
							return
						else if(dir.contents.len > 0)
							term.print("Cannot remove non-empty directory.")
							return
					cur_dir.remove(c_args[1])
					term.print("Deleted.")
		else if(cmd == "read")
			if(c_args.len != 1)
				term.print("Usage: read FILENAME")
			else
				file = FS.find_path(c_args[1])
				if(file == null)
					term.print("File not found.")
				else if(!istype(file))
					term.print("Cannot read directories.")
				else if(!istext(file.data))
					term.print("Not a text file.")
				else
					term.print(file.data)
		else if(cmd == "login")
			if(login_name)
				term.print("Logout first")
			else if(istype(user, /mob/ai))
				login_name = "AIUSR"
			else
				var/mob/human/H = user
				if(istype(user.equipped(), /obj/item/card/id))
					login = user.equipped()
				else if(istype(H) && istype(H.wear_id, /obj/item/card/id))
					login = H.wear_id
				else
					term.print("You need an ID card to log in.")
					return
				login_name = login.registered
			term.print("Now logged in as [login_name].")
		else if(cmd == "logout")
			if(!login_name)
				term.print("You are not logged in.")
			else
				login_name = ""
				login = null
				term.print("Logged out.")
		else if(cmd == "user")
			if(login_name)
				term.print("Currently logged in as [login_name].")
			else
				term.print("Not currently logged in.")
		/*else if(cmd == "time")
			term.print("TODO")
		else if(cmd == "drive")
			term.print("TODO")
		else if(cmd == "title")
			term.print("TODO")*/
		else if(cmd == "run")
			file = FS.find_path(cur_dir, c_args[1])
			if(file == null)
				term.print("File not found.")
			else if(file.filetype != FILETYPE_PROG)
				term.print("Not an executable file.")
			else
				cur_prog = new file.data()
				cur_prog.term = term
				cur_prog.os = src
				cur_prog.start()
		else
			file = FS.find_path(cur_dir, cmd)
			if(file == null || file.filetype != FILETYPE_PROG)
				term.print("Unknown command.")
			else
				cur_prog = new file.data()
				cur_prog.term = term
				cur_prog.os = src
				cur_prog.start()