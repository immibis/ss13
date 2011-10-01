var/const
	FILETYPE_TEXT = "TEXT" // data is text
	FILETYPE_PROG = "TPROG" // data is a path derived from /datum/comp_program

datum/fs_file
	var/data
	var/filetype

	New(filetype, data)
		. = ..()
		src.filetype = filetype
		src.data = data

datum/fs_dir
	// maps names to objects
	var/list/contents = new

	var/datum/fs_dir/parent = null

	// case insensitive version of contents[name]
	proc/get(name)
		if(name == ".")
			return src
		if(name == "..")
			return parent
		for(var/k in contents)
			if(cmptext(k, name))
				return contents[k]
		return null

	proc/remove(name)
		for(var/k in contents)
			if(cmptext(k, name))
				contents.Remove(k)

	proc/put(name, val)
		for(var/k in contents)
			if(cmptext(k, name))
				contents[k] = val
				return
		contents[name] = val

datum/filesystem

	var/datum/fs_dir/root

	New()
		. = ..()
		root = new

	// returns file/directory or null
	proc/find_path(datum/fs_dir/curdir, path as text)
		var/iters = 0
		while(iters < 50)
			var/index = findtextEx(path, "/")
			if(index == 0)
				break
			var/this = copytext(path, 1, index)
			path = copytext(path, index + 1)
			var/next = curdir.get(this)
			if(!istype(next, /datum/fs_dir))
				return null
			curdir = next

		if(iters >= 50)
			return null

		return curdir.get(path)

	// returns error message, or null on success
	proc/set_path(datum/fs_dir/curdir, path as text, file)
		var/iters = 0
		while(iters < 50)
			var/index = findtextEx(path, "/")
			if(index == 0)
				break
			var/this = copytext(path, 1, index)
			path = copytext(path, index + 1)
			var/next = curdir.get(this)
			if(next == null)
				return "Directory not found."
			if(!istype(next, /datum/fs_dir))
				return "Not a directory."
			curdir = next

		if(iters > 50)
			return "Path too long."

		if(istype(file, /datum/fs_dir))
			var/datum/fs_dir/dir = file
			dir.parent = curdir

		curdir.put(path, file)
		return null
