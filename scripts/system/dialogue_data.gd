class_name DialogueData

## Names
const NAME_MOB_BOSS = "Mob Boss"
const NAME_MAIN_CHARACTER = "Jeremy"

## Image Paths
const IMAGE_MOB_BOSS_DEFAULT = preload("res://assets/textures/jeremy/MCPlaceholder.png")
const IMAGE_MAIN_CHARACTER_DEFAULT = preload("res://assets/textures/ui/dialogue/character_portraits/mobboss.png")

# Table of Contents. When refrencing dialogue, use the ID accociated to locate the data.
var dialogue_id : Dictionary = {
	0000 : DEBUG_EXAMPLE,
	0001 : INTRO
}

## Dialogue data
# Format is as follows:
#	"name" : USE A CONST -> String
#	"text" : String
#	"speaker_image" : USE A CONST -> NodePath
#	"sfx" : TODO audio class????
#	"goto" : int
#	"optionA" : String
#	"optionA_goto" : int
#	"optionB" : String
#	"optionB_goto" : int
#	"parameters" : Array[String]
#	"return" : Bool
#	"signal" : Array[String]
#
# Valid parameters include:
#	TODO nothing yet lol
# 
# If return is true, it will end the dialogue there.
# Signal will attempt to emit these as signals from SignalBus

var DEBUG_EXAMPLE : Dictionary = {
	0001 : {
		"text" : "If you're seeing this and not trying to debug, something has gone wrong."
	},
	0002 : {
		"name" : NAME_MOB_BOSS,
		"text" : "Yo kid, where's my money?",
		"speaker_image" : IMAGE_MOB_BOSS_DEFAULT,
		"parameters" : ["shaking", "emote_rage"]
	},
	0003 : {
		"name" : NAME_MAIN_CHARACTER,
		"text" : "Oh shit, do I pay him??",
		"speaker_image" : IMAGE_MAIN_CHARACTER_DEFAULT,
		"optionA" : "Yes",
		"optionA_goto" : 0004,
		"optionB" : "No (This is a bad idea)",
		"optionB_goto" : 0003,
	},
	0004 : {
		"name" : NAME_MOB_BOSS,
		"text" : "A wise guy I see. Time to swim with the fishes.",
		"speaker_image" : IMAGE_MOB_BOSS_DEFAULT,
		"return" : true,
		"signal" : ["player_dies"]
	},
	0005 : {
		"name" : NAME_MOB_BOSS,
		"text" : "That's right kid, cough up the dough.",
		"speaker_image" : IMAGE_MOB_BOSS_DEFAULT,
		"return" : true,
		"signal" : ["check_rent"]
	}
}

var INTRO : Dictionary = {
	0001 : {
		"name" : NAME_MOB_BOSS,
		"text" : "Yo kid, where's my money?"
	},
}
