client/verb/report_bug()
	var/str = input("Enter a description of the problem:", "Report a bug/problem", "") as text|null
	if(str)
		text2file("[key]: [str]\n", "bugs.txt")
	messageadmins("\blue [key] reported a bug: [str]")

client/verb/suggest_feature()
	var/str = input("Enter a brief description of the desired feature:", "Suggest a feature", "") as text|null
	if(str)
		text2file("[key]: [str]\n", "ideas.txt")
	messageadmins("\blue [key] suggested: [str]")