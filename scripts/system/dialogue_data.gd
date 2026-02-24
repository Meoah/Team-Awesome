class_name DialogueData

## Names
const NAME_MOB_BOSS = "Mob Boss"
const NAME_MAIN_CHARACTER = "Jeremy"

## Image Paths
const IMAGE_MOB_BOSS_DEFAULT = NodePath("res://assets/textures/ui/dialogue/character_portraits/mobboss.png")
const IMAGE_MAIN_CHARACTER_DEFAULT = NodePath("res://assets/textures/jeremy/MCPlaceholder.png")

# Getter function.
static func get_dialogue(id : int) -> Dictionary : return DIALOGUE_ID.get(id, {})

# Table of Contents. When refrencing dialogue, use the ID accociated to locate the data.
const DIALOGUE_ID : Dictionary[int,Dictionary] = {
	0000 : DEBUG_EXAMPLE,
	0001 : INTRO
}

## Dialogue data
const KEY_NAME : String = "name"
const KEY_TEXT : String = "text"
const KEY_IMAGE : String = "image"
const KEY_SFX : String = "sfx"
const KEY_GOTO : String = "goto"
const KEY_OPTION_A : String = "option_a"
const KEY_OPTION_A_GOTO : String = "option_a_goto"
const KEY_OPTION_B : String = "option_b"
const KEY_OPTION_B_GOTO: String = "option_b_goto"
const KEY_PARAMETERS : String = "parameters"
const KEY_RETURN : String = "return"
const KEY_SIGNAL : String = "signal"

const PARAMETER_ON_EXIT : String = "on_exit"

# Format is as follows:
#	KEY_NAME : USE A CONST -> String
#	KEY_TEXT : String
#	KEY_IMAGE : USE A CONST -> NodePath
#	KEY_SFX : TODO audio class????
#	KEY_GOTO : int
#	KEY_OPTION_A : String
#	KEY_OPTION_A_GOTO : int
#	KEY_OPTION_B : String
#	KEY_OPTION_B_GOTO : int
#	KEY_PARAMETERS : Array[String]
#	KEY_RETURN : Bool
#	KEY_SIGNAL : Array[String]
#
# Valid parameters include:
#	PARAMETER_ON_EXIT : Emits the signal on exit instead of during dialogue.
# 
# If return is true, it will end the dialogue there.
# Signal will attempt to emit these as signals from SignalBus

const DEBUG_EXAMPLE : Dictionary = {
	0001 : {
		KEY_TEXT : "If you're seeing this and not trying to debug, something has gone wrong."
	},
	0002 : {
		KEY_NAME : NAME_MOB_BOSS,
		KEY_TEXT : "Yo kid, where's my money?",
		KEY_IMAGE : IMAGE_MOB_BOSS_DEFAULT,
		KEY_PARAMETERS : ["shaking", "emote_rage"]
	},
	0003 : {
		KEY_NAME : NAME_MAIN_CHARACTER,
		KEY_TEXT : "Oh shit, do I pay him??",
		KEY_IMAGE : IMAGE_MAIN_CHARACTER_DEFAULT,
		KEY_OPTION_A : "Yes",
		KEY_OPTION_A_GOTO : 0005,
		KEY_OPTION_B : "No (This is a bad idea)",
		KEY_OPTION_B_GOTO : 0004,
	},
	0004 : {
		KEY_NAME : NAME_MOB_BOSS,
		KEY_TEXT : "A wise guy I see. Time to swim with the fishes.",
		KEY_IMAGE : IMAGE_MOB_BOSS_DEFAULT,
		KEY_RETURN : true,
		KEY_PARAMETERS : [PARAMETER_ON_EXIT],
		KEY_SIGNAL : ["player_dies"]
	},
	0005 : {
		KEY_NAME : NAME_MOB_BOSS,
		KEY_TEXT : "That's right kid, cough up the dough.",
		KEY_IMAGE : IMAGE_MOB_BOSS_DEFAULT,
		KEY_RETURN : true,
		KEY_SIGNAL : ["check_rent"]
	}
}

const INTRO : Dictionary = {
	0001 : {
		KEY_NAME : NAME_MOB_BOSS,
		KEY_TEXT : "Yo kid, where's my money?"
	},
}
