extends RefCounted
class_name FishData

var display_name: String
var fish_price: int
var icon: Texture2D

# Table of Contents. When refrencing fish, use the ID accociated to locate the data.
const FISH_ID : Dictionary = {
	1 : BUG_EYED_FISH,
	2 : RAINBOW_EEL,
	3 : TRASH,
	4 : PINK_FISH,
	5 : SHROOMLE,
	6 : LINXOOO,
	7 : HONEY_GLAZED_SKELETON
}

## Fish data
# Must include the following:
#	"name" : String
#	"image" : NodePath
#	"weight" : float
#	"inputs" : Array
#	"value" : float
#	"time" : float
# Anything other parameter is optional and can be used for speciality fish.

const BUG_EYED_FISH : Dictionary = {
	"name" : "Bug Eyed Fish",
	"image" : NodePath("res://assets/textures/fish/doodle_fish/Fish01.png"),
	"weight" : 5.0,
	"inputs" : ["Left","Right","Up","Down"],
	"value" : 3.0,
	"time" : 5.0
}

const RAINBOW_EEL : Dictionary = {
	"name" : "Rainbow Eel",
	"image" : NodePath("res://assets/textures/fish/doodle_fish/Fish04.png"),
	"weight" : 10.0,
	"inputs" : ["Down", "Left", "Up", "Right","Down","Down"],
	"value" : 7.0,
	"time" : 3.5
}

const TRASH : Dictionary = {
	"name" : "Trash",
	"image" : NodePath("res://assets/textures/fish/doodle_fish/Fish02.png"),
	"weight" : 2.0,
	"inputs" : ["Up","Up","Right"],
	"value" : -2.0,
	"time" : 4
}

const PINK_FISH : Dictionary = {
	"name" : "Pink Fish",
	"image" : NodePath("res://assets/textures/fish/doodle_fish/Fish03.png"),
	"weight" : 2.0,
	"inputs" : ["Left","Right","Left","Right"],
	"value" : 4.0,
	"time" : 3.0
}

const SHROOMLE : Dictionary = {
	"name" : "Shroomle",
	"image" : NodePath("res://assets/textures/fish/doodle_fish/Fish05.png"),
	"weight" : 5.0,
	"inputs" : ["Left","Right","Up","Down","Up"],
	"value" : 10.0,
	"time" : 5.0
}

const LINXOOO : Dictionary = {
	"name" : "Linxooo",
	"image" : NodePath("res://assets/textures/fish/wip_fish/Linxooo.png"),
	"weight" : 5.0,
	"inputs" : ["Right","Up","Down","Right","Right"],
	"value" : 10.0,
	"time" : 5.0
}

const HONEY_GLAZED_SKELETON : Dictionary = {
	"name" : "Honey Glazed Skeleton",
	"image" : NodePath("res://assets/textures/fish/wip_fish/Honey Glazed Skeleton.png"),
	"weight" : 2.0,
	"inputs" : ["Up", "Up", "Down", "Down", "Left","Right","Left","Right"],
	"value" : 15.0,
	"time" : 6.0
}
