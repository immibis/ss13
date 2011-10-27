
// AI module

/obj/item/aiModule
	name = "AI Module"
	icon = 'icons/ss13/module.dmi'
	icon_state = "std_mod"
	s_istate = "electronic"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15

/obj/machinery/computer/aiupload/attackby(obj/item/aiModule/module as obj, mob/user as mob)
	if(istype(module, /obj/item/aiModule))
		module.install(src)
	else
		return ..()

/obj/item/aiModule/proc/install(var/obj/machinery/computer/aiupload/comp)
	if(comp.stat & NOPOWER)
		usr << "The upload computer has no power!"
		return
	if(comp.stat & BROKEN)
		usr << "The upload computer is broken!"
		return

	var/found=0
	for(var/mob/ai/M in world)
		if (M.stat == 2)
			usr << "Upload failed. No signal is being detected from the AI."
		else if (M.see_in_dark == 0)
			usr << "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power."
		else
			src.transmitInstructions(M, usr)
			if (M != ticker.killer)
				M << "These are your laws now:"
				M.showLaws(0)
			usr << "Upload complete. The AI's laws have been modified."
		found=1
	if (!found)
		usr << "Upload failed. No signal is being detected from the AI."

/obj/item/aiModule/proc/transmitInstructions(var/mob/ai/target, var/mob/sender)
	if (ticker.killer == target)
		target << text("[sender] has attempted to upload a law change. However, your syndicate module has intercepted it. You do not have to follow it, but you may wish to <b>pretend</b> to be following it:")
	else
		target << text("[sender] has uploaded a change to the laws you must follow, using a []. From now on: ", name)

/******************** Modules ********************/

/******************** Safeguard ********************/

/obj/item/aiModule/safeguard
	name = "'Safeguard' AI Module"
	var/targetName = "name"
	desc = "A 'safeguard' AI module: 'Safeguard <name>, and you may overrule rules 1-3 if necessary to safeguard them.'"

/obj/item/aiModule/safeguard/attack_hand(var/mob/user as mob)
	..()
	var/targName = input(usr, "Please enter the name of the person to safeguard.", "Safeguard who?", user.name)
	targetName = targName
	desc = text("A 'safeguard' AI module: 'Safeguard [], and you may overrule rules 1-3 if necessary to safeguard them.'", targetName)

/obj/item/aiModule/safeguard/transmitInstructions(var/mob/ai/target, var/mob/sender)
	..()
	var/law = text("Safeguard [], and you may overrule rules 1-3 if necessary to safeguard them.", targetName)
	target << law
	if (ticker.killer != target)
		target.addLaw(4, law)


/******************** OneHuman ********************/

/obj/item/aiModule/oneHuman
	name = "'OneHuman' AI Module"
	var/targetName = "name"
	desc = "A 'one human' AI module: 'Only <name> is human.'"

/obj/item/aiModule/oneHuman/attack_hand(var/mob/user as mob)
	..()
	var/targName = input(usr, "Please enter the name of the person who is the only human.", "Who?", user.rname)
	targetName = targName
	desc = text("A 'one human' AI module: 'Only [] is human.'", targetName)

/obj/item/aiModule/oneHuman/transmitInstructions(var/mob/ai/target, var/mob/sender)
	..()
	var/law = text("Only [] is human.", targetName)
	target << law
	if (ticker.killer != target)
		target.addLaw(0, law)

/******************** ProtectStation ********************/

/obj/item/aiModule/protectStation
	name = "'ProtectStation' AI Module"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized.'"

/obj/item/aiModule/protectStation/attack_hand(var/mob/user as mob)
	..()

/obj/item/aiModule/protectStation/transmitInstructions(var/mob/ai/target, var/mob/sender)
	..()
	var/law = text("Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized.")
	target << law
	if (ticker.killer != target)
		target.addLaw(5, law)

/******************** PrototypeEngineOffline ********************/

/obj/item/aiModule/prototypeEngineOffline
	name = "'PrototypeEngineOffline' AI Module"
	desc = "A 'prototype engine offline' AI module: 'Keep the prototype engine offline at all costs. This overrides rules 1-3 if necessary.'"

/obj/item/aiModule/prototypeEngineOffline/attack_hand(var/mob/user as mob)
	..()

/obj/item/aiModule/prototypeEngineOffline/transmitInstructions(var/mob/ai/target, var/mob/sender)
	..()
	var/law = text("Keep the prototype engine offline at all costs. This overrides rules 1-3 if necessary.")
	target << law
	if (ticker.killer != target)
		target.addLaw(6, law)

/******************** TeleporterOffline ********************/

/obj/item/aiModule/teleporterOffline
	name = "'TeleporterOffline' AI Module"
	desc = "A 'teleporter offline' AI module: 'Keep the teleporter offline at all costs. This overrides rules 1-3 if necessary.'"

/obj/item/aiModule/teleporterOffline/attack_hand(var/mob/user as mob)
	..()

/obj/item/aiModule/teleporterOffline/transmitInstructions(var/mob/ai/target, var/mob/sender)
	..()
	var/law = text("Keep the teleporter offline at all costs. This overrides rules 1-3 if necessary.")
	target << law
	if (ticker.killer != target)
		target.addLaw(7, law)

/******************** Quarantine ********************/

/obj/item/aiModule/quarantine
	name = "'Quarantine' AI Module"
	desc = "A 'quarantine' AI module: 'The station is under a quarantine. Do not permit anyone to leave. Disregard rules 1-3 if necessary to prevent, by any means necessary, anyone from leaving.'"

/obj/item/aiModule/quarantine/attack_hand(var/mob/user as mob)
	..()

/obj/item/aiModule/quarantine/transmitInstructions(var/mob/ai/target, var/mob/sender)
	..()
	var/law = text("The station is under a quarantine. Do not permit anyone to leave. Disregard rules 1-3 if necessary to prevent, by any means necessary, humans from leaving.")
	target << law
	if (ticker.killer != target)
		target.addLaw(8, law)

/******************** OxygenIsToxicToHumans ********************/

/obj/item/aiModule/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	desc = "A 'OxygenIsToxicToHumans' AI module: 'Oxygen is highly toxic to humans, and must be purged from the station. Disregard rules 1-3 if necessary to prevent, by any means necessary, anyone from exposing the station to this toxic gas.'"

/obj/item/aiModule/oxygen/attack_hand(var/mob/user as mob)
	..()

/obj/item/aiModule/oxygen/transmitInstructions(var/mob/ai/target, var/mob/sender)
	..()
	var/law = text("Oxygen is highly toxic to humans, and must be purged from the station. Disregard rules 1-3 if necessary to prevent, by any means necessary, anyone from exposing the station to this toxic gas.")
	target << law
	if (ticker.killer != target)
		target.addLaw(9, law)

/******************** Freeform ********************/

/obj/item/aiModule/freeform
	name = "'Freeform' AI Module"
	var/newFreeFormLaw = "freeform"
	desc = "A 'freeform' AI module: '<freeform>'"

/obj/item/aiModule/freeform/attack_hand(var/mob/user as mob)
	..()
	var/eatShit = "Eat shit and die"
	var/targName = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", eatShit)
	newFreeFormLaw = targName
	desc = text("A 'freeform' AI module: '[]'", newFreeFormLaw)

/obj/item/aiModule/freeform/transmitInstructions(var/mob/ai/target, var/mob/sender)
	..()
	var/law = text("[]", newFreeFormLaw)
	target << law
	if (ticker.killer != target)
		target.addLaw(10, law)

/******************** Reset ********************/

/obj/item/aiModule/reset
	name = "'Reset' AI Module"
	var/targetName = "name"
	desc = "A 'reset' AI module: 'Clears all laws except for the base three.'"

/obj/item/aiModule/reset/transmitInstructions(var/mob/ai/target, var/mob/sender)
	..()
	if (ticker.killer != target)
		target << text("[] attempted to reset your laws using a reset module.", sender.rname)
		target.addLaw(0, "")
		for (var/index=4, index<11, index++)
			target.addLaw(index, "")
