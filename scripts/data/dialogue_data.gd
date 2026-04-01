class_name DialogueData

## Names
const NAME_MAIN_CHARACTER = "Jeremy"
const NAME_MOB_BOSS = "Mob Boss"
const NAME_BAIT_VENDOR = "Barry"
const UNKNOWN = "Unknown"

## Image Paths
const IMAGE_MOB_BOSS_DEFAULT = NodePath("res://assets/textures/ui/dialogue/character_portraits/mobboss.png")
const IMAGE_MAIN_CHARACTER_DEFAULT = NodePath("res://assets/textures/actors/jeremy/MCPlaceholder.png")

const DEFAULT_SPEAKER_PROFILE : Dictionary = {
	"beep_key": "dialogue_typewriter_beep",
	"beep_volume_linear": 0.2,
	"beep_base_pitch_scale": 1.0,
	"beep_pitch_jitter": 0.06,
	"beep_min_interval": 0.03,
	"beep_chance": 0.85,
	"beep_ignore_characters": " \n\t.,!?;:()[]{}\"'"
}

const SPEAKER_PROFILES : Dictionary = {
	NAME_MAIN_CHARACTER: {"beep_base_pitch_scale": 1.08},
	NAME_MOB_BOSS: {"beep_base_pitch_scale": 0.3, "beep_chance": 0.65}
}

# Getter functions.
static func get_dialogue(id : int) -> Dictionary : return DIALOGUE_ID.get(id, {})
static func get_profile(speaker_name : String) -> Dictionary:
	var key_name : String = speaker_name
	var profile : Dictionary = DEFAULT_SPEAKER_PROFILE.duplicate(true)
	
	if SPEAKER_PROFILES.has(key_name):
		for each_key in SPEAKER_PROFILES[key_name].keys():
			profile[each_key] = SPEAKER_PROFILES[key_name][each_key]
	
	return profile

# Table of Contents. When refrencing dialogue, use the ID accociated to locate the data.
const DIALOGUE_ID : Dictionary[int,Dictionary] = {
	0000 : DEBUG_EXAMPLE,
	0001 : INTRO,
	0002 : BAIT_SHOP,
}

## Dialogue data
const KEY_NAME : String = "name"
const KEY_TEXT : String = "text"
const KEY_IMAGE_L : String = "image_left"
const KEY_IMAGE_R : String = "image_right"
const KEY_BGM : String = "bgm"
const KEY_SFX : String = "sfx"
const KEY_GOTO : String = "goto"
const KEY_OPTION_A : String = "option_a"
const KEY_OPTION_A_GOTO : String = "option_a_goto"
const KEY_OPTION_B : String = "option_b"
const KEY_OPTION_B_GOTO: String = "option_b_goto"
const KEY_PARAMETERS : String = "parameters"
const KEY_RETURN : String = "return"
const KEY_SIGNAL : String = "signal"

const PARAMETER_SIGNAL_ON_EXIT : String = "signal_on_exit"

# Format is as follows:
#	KEY_NAME : USE A CONST -> String
#	KEY_TEXT : String
#	KEY_IMAGE : USE A CONST -> NodePath
#	KEY_BGM : String
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
#	PARAMETER_SIGNAL_ON_EXIT : Emits the signal on exit instead of during dialogue.
# 
# If return is true, it will end the dialogue there.
# Signal will attempt to emit these as signals from SignalBus

const DEBUG_EXAMPLE : Dictionary = {
	0000 : {
		KEY_RETURN : true,
		KEY_TEXT : "If you're seeing THIS at all, something really broke."
	},
	0001 : {
		KEY_TEXT : "If you're seeing this and not trying to debug, something has gone wrong."
	},
	0002 : {
		KEY_NAME : NAME_MOB_BOSS,
		KEY_BGM : "res://assets/audio/bgm/the_frog_is_talking.ogg",
		KEY_TEXT : "Yo kid, where's my money?",
		KEY_IMAGE_R : IMAGE_MOB_BOSS_DEFAULT,
		KEY_PARAMETERS : ["shaking", "emote_rage"]
	},
	0003 : {
		KEY_NAME : NAME_MAIN_CHARACTER,
		KEY_TEXT : "Oh shit, do I pay him??",
		KEY_IMAGE_L : IMAGE_MAIN_CHARACTER_DEFAULT,
		KEY_IMAGE_R : IMAGE_MOB_BOSS_DEFAULT,
		KEY_OPTION_A : "Yes",
		KEY_OPTION_A_GOTO : 0005,
		KEY_OPTION_B : "No (This is a bad idea)",
		KEY_OPTION_B_GOTO : 0004,
	},
	0004 : {
		KEY_NAME : NAME_MOB_BOSS,
		KEY_TEXT : "A wise guy I see. Time to swim with the fishes.",
		KEY_IMAGE_R : IMAGE_MOB_BOSS_DEFAULT,
		KEY_RETURN : true,
		KEY_PARAMETERS : [PARAMETER_SIGNAL_ON_EXIT],
		KEY_SIGNAL : ["player_dies"]
	},
	0005 : {
		KEY_NAME : NAME_MOB_BOSS,
		KEY_TEXT : "That's right kid, cough up the dough.",
		KEY_IMAGE_R : IMAGE_MOB_BOSS_DEFAULT,
		KEY_RETURN : true,
		KEY_PARAMETERS : [PARAMETER_SIGNAL_ON_EXIT],
		KEY_SIGNAL : ["run_intro"]
	}
}


const INTRO : Dictionary = {
	0001 : {
		KEY_NAME : UNKNOWN,
		KEY_TEXT : "*Knock Knock Knock*",
	},
	0002 : {
		KEY_NAME : NAME_MAIN_CHARACTER,
		KEY_TEXT : "Oh dear! Who's at the door?",
		KEY_IMAGE_L : IMAGE_MAIN_CHARACTER_DEFAULT
	},
	0003 : {
		KEY_NAME : NAME_MOB_BOSS,
		KEY_BGM : "res://assets/audio/bgm/the_frog_is_talking.ogg",
		KEY_TEXT : "Yo kid, rent is PAST DUE!",
		KEY_IMAGE_R : IMAGE_MOB_BOSS_DEFAULT,
		KEY_PARAMETERS : ["shaking", "emote_rage"]
	},
	0004 : {
		KEY_NAME : NAME_MAIN_CHARACTER,
		KEY_TEXT : "Oh uhhhh, do I pay him??",
		KEY_IMAGE_L : IMAGE_MAIN_CHARACTER_DEFAULT,
		KEY_IMAGE_R : IMAGE_MOB_BOSS_DEFAULT,
		KEY_OPTION_A : "Yes",
		KEY_OPTION_A_GOTO : 0006,
		KEY_OPTION_B : "No (This is a bad idea)",
		KEY_OPTION_B_GOTO : 0005,
	},
	0005 : {
		KEY_NAME : NAME_MOB_BOSS,
		KEY_TEXT : "A wise guy I see. Time to swim with the fishes.",
		KEY_IMAGE_R : IMAGE_MOB_BOSS_DEFAULT,
		KEY_RETURN : true,
		KEY_PARAMETERS : [PARAMETER_SIGNAL_ON_EXIT],
		KEY_SIGNAL : ["player_dies"]
	},
	0006 : {
		KEY_NAME : NAME_MOB_BOSS,
		KEY_TEXT : "That's right kid, cough up the dough.",
		KEY_IMAGE_R : IMAGE_MOB_BOSS_DEFAULT,
		KEY_RETURN : true,
		KEY_PARAMETERS : [PARAMETER_SIGNAL_ON_EXIT],
		KEY_SIGNAL : ["run_intro"]
	}
}

const BAIT_SHOP : Dictionary = {
	0000 : {
		KEY_RETURN : true,
		KEY_TEXT : "If you're seeing THIS at all, something really broke."
	},
	0001 : {
		KEY_NAME : NAME_BAIT_VENDOR,
		KEY_TEXT : "Hello there, do you want some shoppins?",
		KEY_RETURN : true,
		KEY_PARAMETERS : [PARAMETER_SIGNAL_ON_EXIT],
		KEY_SIGNAL : ["start_bait_shop"]
	},
}
