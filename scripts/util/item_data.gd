class_name ItemData

const EXOTIC : String = "Exotic"
const REEL : String = "Reel"
const ROD : String = "Rod"
const LURE : String = "Lure"
const BAIT : String = "Bait"
const TAROT : String = "Tarot" # TODO working name

# Returns the data according to given category and ID.
static func get_data(category : String, id : int) -> Dictionary:
	var source : Dictionary = get_category_dictionary(category)
	return source.get(id, {})

# Returns how many available IDs there are in an array.
static func get_available_ids(category : String) -> Array[int]:
	var list : Array[int] = []
	var source : Dictionary = get_category_dictionary(category)
	
	for key in source.keys() : if key != 0 : list.append(key)
	return list

# Returns with the proper dictionary from the given string.
static func get_category_dictionary(category : String) -> Dictionary:
	match category:
		EXOTIC: return UPGRADES_EXOTIC
		REEL:   return UPGRADES_REEL
		ROD:    return UPGRADES_RODS
		LURE:   return UPGRADES_LURES
		BAIT:   return BAIT_BUNDLES
		_:      return {}

# Table of Contents. Each item is split into a category. Refer to category and item ID to access data.
const UPGRADES_EXOTIC : Dictionary = {
	0 : DUMMY_EXOTIC,
	1 : MULTI_BOBBER,
}

const UPGRADES_REEL : Dictionary = {
	0 : DUMMY_REEL,
	1 : WOODEN_REEL,
	2 : FISHTAGRAM_REEL,
}

const UPGRADES_RODS : Dictionary = {
	0 : DUMMY_ROD,
	1 : WOODEN_ROD,
}

const UPGRADES_LURES : Dictionary = {
	0 : DUMMY_LURE,
	1 : PLASTIC_LURE,
	
}

const BAIT_BUNDLES : Dictionary = {
	0 : DUMMY_BAIT,
	1 : GENERIC_BAIT_BUNDLE,
	2 : MAGIC_BAIT,
}

## Item Data
const KEY_NAME : String = "name"
const KEY_IMAGE : String = "image"
const KEY_TYPE : String = "type"
const KEY_COST : String = "cost"
const KEY_COST_TYPE : String = "cost_type"
const KEY_COST_FACTOR : String = "cost_factor"
const KEY_DESCRIPTION : String = "description"
const KEY_QUANTITY_MIN : String = "quantity_min"
const KEY_QUANTITY_MAX : String = "quantity_max"
const KEY_SIGNAL : String = "signal"
# Must include the following:
#	KEY_NAME : String
#	KEY_IMAGE : NodePath
#	KEY_TYPE : String [Rod, Reel, Lure, Exotic]
# Optional:
#	KEY_COST : float [=> 0.0]
#	KEY_COST_TYPE : String
#	KEY_COST_FACTOR : float [0.0 ~ 1.0]
#	KEY_QUANTITY_MIN : int [=> 0]
#	KEY_QUANTITY_MAX : int [=> 0]
#	KEY_DESCRIPTION : String
#	KEY_SIGNAL : Array

## Reels
const DUMMY_REEL : Dictionary = {
	KEY_NAME : "Dummy Reel",
	KEY_IMAGE : NodePath("res://assets/textures/upgrades/reels/Wooden_Reel_temp.png"),
	KEY_TYPE : REEL,
	KEY_COST : 0.0,
	KEY_DESCRIPTION : "You shouldnt see this... tsk tsk tsk"
}

const WOODEN_REEL : Dictionary = {
	KEY_NAME : "Wooden Reel",
	KEY_IMAGE : NodePath("res://assets/textures/upgrades/reels/Wooden_Reel_temp.png"),
	KEY_TYPE : REEL,
	KEY_COST : 15.0,
	KEY_DESCRIPTION : "Gives a 25% chance to reduce input by 1"
}

const FISHTAGRAM_REEL : Dictionary = {
	KEY_NAME : "Fishtagram Reel",
	KEY_IMAGE : NodePath("res://assets/textures/upgrades/reels/Fishtagram_reel_temp.png"),
	KEY_TYPE : REEL,
	KEY_COST : 150.0,
	KEY_DESCRIPTION : "5% to autocomplete minigame. Reel was skipped, too boring :/ "
}

## Rods
const DUMMY_ROD : Dictionary = {
	KEY_NAME : "Dummy Rod",
	KEY_IMAGE : NodePath("res://assets/textures/upgrades/rods/wooden_rod_temp.png"),
	KEY_TYPE : ROD,
	KEY_COST : 0.0,
	KEY_DESCRIPTION : "Yo rod is so STUPID... they didnt even know this was an ERROR message!"
}

const WOODEN_ROD : Dictionary = {
	KEY_NAME : "Wooden Rod",
	KEY_IMAGE : NodePath("res://assets/textures/upgrades/rods/wooden_rod_temp.png"),
	KEY_TYPE : ROD,
	KEY_COST : 15.0,
	KEY_DESCRIPTION : "Adds +2% value to every other fish caught!"
}

## Lures
const DUMMY_LURE : Dictionary = {
	KEY_NAME : "Dummy Lure",
	KEY_IMAGE : NodePath("res://assets/textures/upgrades/lures/plastic_lure_temp.png"),
	KEY_TYPE : LURE,
	KEY_COST : 0.0,
	KEY_DESCRIPTION : "You just got lured DUMMY!"
}

const PLASTIC_LURE : Dictionary = {
	KEY_NAME : "Plastic Lure",
	KEY_IMAGE : NodePath("res://assets/textures/upgrades/lures/plastic_lure_temp.png"),
	KEY_TYPE : LURE,
	KEY_COST : 15.0,
	KEY_DESCRIPTION : "+3% chance to upgrade fish rarity!"
}

## Exotics
const DUMMY_EXOTIC : Dictionary = {
	KEY_NAME : "Dummy Exotic",
	KEY_IMAGE : NodePath("res://assets/textures/upgrades/exotic/multi_bobber.png"),
	KEY_TYPE : EXOTIC,
	KEY_COST : 0.0,
	KEY_DESCRIPTION : "Does nothing... exotically~"
}

const MULTI_BOBBER : Dictionary = {
	KEY_NAME : "Multi Bobber",
	KEY_IMAGE : NodePath("res://assets/textures/upgrades/exotic/multi_bobber.png"),
	KEY_TYPE : EXOTIC,
	KEY_COST : 200.0,
	KEY_DESCRIPTION : "Fire three bobbers to catch multiple fish with one use of your bait!"
}

## Bait Bundles
const DUMMY_BAIT : Dictionary = {
	KEY_NAME : "Dummy Bait",
	KEY_IMAGE : NodePath("res://assets/textures/bait/worms_PNG32.png"),
	KEY_TYPE : BAIT,
	KEY_COST : 0.0,
	KEY_DESCRIPTION : "Get baited."
}

const GENERIC_BAIT_BUNDLE : Dictionary = {
	KEY_NAME : "Generic Bait",
	KEY_IMAGE : NodePath("res://assets/textures/bait/generic_bait_placeholder.png"),
	KEY_TYPE : BAIT,
	KEY_COST : 1.0,
	KEY_COST_FACTOR : 0.7,
	KEY_QUANTITY_MIN : 1,
	KEY_QUANTITY_MAX : 10,
	KEY_DESCRIPTION : "As generic as it comes."
}

const MAGIC_BAIT : Dictionary = {
	KEY_NAME : "Magic Bait",
	KEY_IMAGE : NodePath("res://assets/textures/bait/placeholder_bait.png"),
	KEY_TYPE : BAIT,
	KEY_COST : 50.0,
	KEY_COST_FACTOR : 0.7,
	KEY_QUANTITY_MIN : 1,
	KEY_QUANTITY_MAX : 2,
	KEY_DESCRIPTION : "[font_size=8]This may or may not be a scam.[/font_size]\nThis is [color=red]DEFINITELY[/color] worth it."
}
