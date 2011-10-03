// power usage
#define TELEPORTER_ENGAGE_POWER 500000		// when engaged, for one second
#define TELEPORTER_TELEPORT_POWER 5000000	// when teleporting
#define TELEPORTER_ON_POWER 150000			// constant when on
#define WEAPSAT_LASER_POWER 100000			// constant when operating
#define WEAPSAT_HEATER_POWER 50000			// constant when operating
#define WEAPSAT_AMPLIFIER_POWER 50000		// constant when operating
#define WEAPSAT_COMBINER_POWER 50000		// constant when operating
#define WEAPSAT_FLOOR_POWER 8				// constant per floor tile
#define CIR_ACCESSED_POWER 100				// per connection
#define CIR_ON_POWER 1000					// constant when enabled
#define REMOTE_MONITOR_POWER 1000			// constant
#define TESLA_EFFICIENCY 0.25				// tesla coil efficiency
#define TESLA_OVERHEAD 10000				// constant when transmitting
#define CAMERA_COMPUTER_POWER 500			// when changing cameras
#define DOOR_CONTROL_POWER 50				// when used
#define FIREALARM_ACTIVE_POWER 100			// constant
#define IGNITER_POWER 500					// constant when on
#define RECHARGER_POWER 2500				// per charge on weapon
#define TURRET_POWER 2500					// constant
#define TURRET_STUN_POWER 50000				// per stun shot
#define TURRET_LETHAL_POWER 100000			// per lethal shot
#define AIRLOCK_POWER 1000					// when opening or closing
#define FIREDOOR_POWER 1000					// when opening or closing
#define PODDOOR_POWER 1000					// when opening or closing
#define FILTER_CONTROL_POWER 50				// constant
#define CIRCULATOR_POWER 1000				// constant when on, scaled if not running at full speed
#define DVALVE_CONTROL_POWER 50				// when switched
#define PIPE_PUMP_POWER 250					// constant
#define FILTER_INLET_POWER 50				// constant
#define PIPEFILTER_POWER_MULT 1				// per unit of gas transfer rate
#define PIPEFILTER_POWER_MAX 10000			// maximum power used
#define POWER_MONITOR_POWER 2500			// constant
#define SOLAR_CONTROL_POWER 2500			// constant
#define INJECTOR_POWER 250					// when injecting
#define AIR_ALARM_POWER 50					// constant
#define PIPE_METER_POWER 50					// constant
#define SCRUBBER_POWER 5000					// constant when on
#define SIPHON_POWER 5000					// constant when on
#define HEATER_POWER 500					// constant
#define HEATER_HEATING_POWER 0.01			// per degree per unit of gas
#define COMPUTER_POWER 2500					// default computer power, constant
#define MASS_DRIVER_POWER 0.1				// per unit of weight driven
#define CRYO_FREEZER_POWER 500				// constant
#define CRYO_FREEZER_COOLING_POWER 3000		// when cooling
#define CRYO_CELL_POWER 3000				// constant
#define ELECTRIC_CHAIR_POWER 50000			// when shocking
#define SCAN_CONSOLE_POWER 2500				// constant
#define ENGINE_CONTROL_POWER 2500			// constant, for engine control computers
#define COMPSTARTERLOAD 28000				// gas turbine compressor starter load
#define LIGHTING_POWER 10					// per lit turf
#define CONVEYOR_POWER 0.0001				// per unit of weight moved
#define TRASHCOMPACTOR_POWER 1000			// constant
#define RECYCLER_POWER 1000					// constant when recycling


// generator constants
#define COMPFRICTION 5e5					// gas turbine compressor friction
#define GENRATE 1							// kJ per kJ. Please don't set to anything other than 1.

// gas
#define ONE_ATMOSPHERE 101325				// pascals
#define O2_STANDARD (ONE_ATMOSPHERE*0.21)	// pascals partial pressure
#define N2_STANDARD (ONE_ATMOSPHERE*0.79)	// pascals partial pressure

// temperature
#define T0C 273.15							// 0degC
#define T20C 293.15							// 20degC

// fire
#define FIREOFFSET 0						//bias for starting firelevel
#define FIREQUOT 5000						//divisor to get target temp from firelevel
#define FIRERATE 100						// potential fire rate is divided by this to get the actual rate
#define FIRE_PL_USE 1						// mols^-1. only the ratio FIRE_PL_USE:FIRE_O2_USE matters.
#define FIRE_O2_USE 1						// mols^-1
#define FIRE_PL_MAX 0.10					// mols^-1
#define FIRE_O2_MAX 0.10					// mols^-1
#define PLASMA_COMBUSTION_HEAT 5074			// kJmol^-1, used octane

// pipe insulation
#define NORMPIPERATE 100					//pipe-insulation rate divisor
#define HEATPIPERATE 8						//heat-exch pipe insulation
#define INSULATEDPIPERATE 40000				//insulated pipe insulation

// misc gas-related
#define FLOWFRAC 0.99						// fraction of gas transfered per process
#define GAS_SLEEP_FLOW 1					// pressure change must be less than this for tiles to sleep (not calculate gas flow)
#define GAS_WAKE_FLOW 2						// if pressure change greater than this, nearby tiles will be woken

// flags bitmask
#define ONBACK 1							// can be put in back slot
#define TABLEPASS 2							// can pass by a table or rack
#define HALFMASK 4							// mask only gets 1/2 of air supply from internals
#define HEADSPACE 4							// head wear protects against space
#define MASKINTERNALS 8						// mask allows internals
#define SUITSPACE 8							// suit protects against space
#define USEDELAY 16							// 1 second extra delay on use
#define NOSHIELD 32							// weapon not affected by shield
// 64 is an unused flag, because everything's drivable by a mass driver now
// Don't reuse it until the flags are all cleaned up (using the #defined things rather than magic numbers)
// because some things probably still have flag 64 set
#define ONBELT 128							// can be put in belt slot
#define FPRINT 256							// takes a fingerprint
#define WINDOW 512							// window or window/door

#define GLASSESCOVERSEYES 1024
#define MASKCOVERSEYES 1024					// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES 1024					// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH 2048				// on other items, these are just for mask/head
#define HEADCOVERSMOUTH 2048

// channel numbers for power
#define EQUIP 1								// equipment power
#define LIGHT 2								// lighting power
#define ENVIRON 3							// environmental power
#define TOTAL 4								// for total power used only

// bitflags for machine stat variable
#define BROKEN 1
#define NOPOWER 2

// misc
#define ENGINE_EJECT_Z 3
#define MIN_RECYCLE_WEIGHT 200000

var/const
	GAS_O2 = 1 << 0
	GAS_N2 = 1 << 1
	GAS_PL = 1 << 2
	GAS_CO2 = 1 << 3
	GAS_N2O = 1 << 4
