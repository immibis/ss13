var/const
	FILETYPE_TEXT = "TEXT" // data is text
	FILETYPE_PROG = "TPROG" // data is a path derived from /datum/comp_program

datum/fs_file
	var/data
	var/filetype

datum/fs_dir
	// maps names to objects
	var/list/contents = new

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
			if(!(this in curdir.contents))
				return null
			var/next = curdir.contents[this]
			if(!istype(next, /datum/fs_dir))
				return null
			curdir = next

		if(iters >= 50)
			return null

		if(!(path in curdir.contents))
			return null

		return curdir.contents[path]