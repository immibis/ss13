/proc/hex2num(hex)

	if (!( istext(hex) ))
		CRASH("hex2num not given a hexadecimal string argument (user error)")
		return
	var/num = 0
	var/power = 0
	for(var/i = length(hex); i > 0; i--)
		var/char = copytext(hex, i, i + 1)
		switch(char)
			if("0")
				power++
				continue
			if("9", "8", "7", "6", "5", "4", "3", "2", "1")
				num += text2num(char) * 16 ** power
			if("a", "A")
				num += 16 ** power * 10
			if("b", "B")
				num += 16 ** power * 11
			if("c", "C")
				num += 16 ** power * 12
			if("d", "D")
				num += 16 ** power * 13
			if("e", "E")
				num += 16 ** power * 14
			if("f", "F")
				num += 16 ** power * 15
			else
				CRASH("hex2num given non-hexadecimal string (user error)")
				return
		power++
	return num

/proc/num2hex(num, placeholder)

	if (placeholder == null)
		placeholder = 2
	if (!( isnum(num) ))
		CRASH("num2hex not given a numeric argument (user error)")
		return
	if (!( num ))
		return "0"
	var/hex = ""
	var/i = 0
	while(16 ** i < num)
		i++
	var/power = null
	power = i - 1
	while(power >= 0)
		var/val = round(num / 16 ** power)
		num -= val * 16 ** power
		switch(val)
			if(9, 8, 7, 6, 5, 4, 3, 2, 1, 0)
				hex += "[val]"
			if(10)
				hex += "A"
			if(11)
				hex += "B"
			if(12)
				hex += "C"
			if(13)
				hex += "D"
			if(14)
				hex += "E"
			if(15)
				hex += "F"
			else
		power--
	while(length(hex) < placeholder)
		hex = "0[hex]"
	return hex