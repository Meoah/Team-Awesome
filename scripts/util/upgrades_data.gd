class_name UpgradesData






# Table of Contents. Each upgrade is split into a category. Refer to category and item ID to access data.

const UPGRADES_EXOTIC : Dictionary = {
	1 : MULTI_BOBBER,
}

const UPGRADES_REEL : Dictionary = {
	1 : WOODEN_REEL,
	2 : FISHTAGRAM_REEL,
}

const UPGRADES_RODS : Dictionary = {
	1 : WOODEN_ROD,
}

const UPGRADES_LURES : Dictionary = {
	1 : PLASTIC_LURE,
	
}


## Upgrades data
# Must include the following:
#	"name" : String
#	"image" : NodePath
#	"type" : String [Rod, Reel, Lure, Exotic]
#	"cost" : float
#	"description" : String
# Anything other parameter is optional and can be used for speciality fish.



#Reels

const WOODEN_REEL : Dictionary = {
	"name" : "Wooden Reel",
	"image" : NodePath("res://assets/textures/upgrades/reels/Wooden_Reel_temp.png"),
	"type" : "Reel",
	"cost" : 15.0,
	"description" : "Gives a 25% chance to reduce input by 1"
}

const FISHTAGRAM_REEL : Dictionary = {
	"name" : "Fishtagram Reel",
	"image" : NodePath("res://assets/textures/upgrades/reels/Fishtagram_reel_temp.png"),
	"type" : "Reel",
	"cost" : 150.0,
	"description" : "5% to autocomplete minigame. Reel was skipped, too boring :/ "
}



#Rods

const WOODEN_ROD : Dictionary = {
	"name" : "Wooden Reel",
	"image" : NodePath("res://assets/textures/upgrades/rods/wooden_rod_temp.png"),
	"type" : "Reel",
	"cost" : 15.0,
	"description" : "Adds +2% value to every other fish caught!"
}

#Lures

const PLASTIC_LURE : Dictionary = {
	"name" : "Plastic Lure",
	"image" : NodePath("res://assets/textures/upgrades/lures/plastic_lure_temp.png"),
	"type" : "Lure",
	"cost" : 15.0,
	"description" : "+3% chance to upgrade fish rarity!"
}

#Exotics
const MULTI_BOBBER : Dictionary = {
	"name" : "Multi Bobber",
	"image" : NodePath("res://assets/textures/upgrades/exotic/multi_bobber.png"),
	"type" : "Exotic",
	"cost" : 200.0,
	"description" : "Fire three bobbers to catch multiple fish with one use of your bait!"
}
