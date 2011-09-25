/datum/chemical
	//var/name = "chemical"
	var/moles = 0.0
	var/molarmass = 18.0
	var/density = 1.0
	var/chem_formula = "H2O"
	var/name = "water-l"

/datum/chemical/ch_cou
	//name = "ch cou"
	molarmass = 270.0
	name = "CCSremedy-l"

/datum/chemical/epil
	//name = "epil"
	molarmass = 230.0
	name = "EPILremedy-l"

/datum/chemical/l_plas
	//name = "l plas"
	name = "plasma-l"
	molarmass = 154.0

/datum/chemical/pathogen
	name = "pathogen"
	var/amount = 0.0
	var/structure_id = null

/datum/chemical/pathogen/antibody
	name = "antibody"
	var/tar_struct = null
	var/a_style = null

/datum/chemical/pathogen/blood
	name = "blood"
	var/antibodies = null
	var/antigens = null
	var/has_oxygen = null
	var/has_co = null

/datum/chemical/pathogen/virus
	name = "virus"

/datum/chemical/pl_coag
	name = "pl coag"
	name = "antipla-l"
	molarmass = 176.0

/datum/chemical/rejuv
	name = "rejuv"
	molarmass = 97.0
	name = "rejuv-l"

/datum/chemical/s_tox
	name = "s tox"
	name = "sleeptox-l"
	molarmass = 45.0

/datum/chemical/waste
	name = "waste"
	name = "waste-l"
	molarmass = 200.0

/datum/chemical/water
	name = "water"
