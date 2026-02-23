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
	7 : HONEY_GLAZED_SKELETON,
	8 : DOODLE_BIRD,
	9 : DOODLE_BIRD_RARE,
	10 : LONG_FISH,
	11 : FIH,
	12 : CATFISH,
	13 : DEFAULT_CUBE,
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


#TODO Below is fish with temp art. Filepath should be updated when art it finalized

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

const DOODLE_BIRD : Dictionary = {
	"name" : "Doodle Bird",
	"image" : NodePath("res://assets/textures/fish/wip_fish/FuckassBird.png"),
	"weight" : 2.0,
	"inputs" : ["Left","Left","Right","Right","Down","Down"],
	"value" : 4.0,
	"time" : 3.0
}

const DOODLE_BIRD_RARE : Dictionary = {
	"name" : "Doodle Bird (Rare)",
	"image" : NodePath("res://assets/textures/fish/wip_fish/FuckassBird(Rare).png"),
	"weight" : 3.0,
	"inputs" : ["Left","Right","Left","Right","Right","Down","Up","Down"],
	"value" : 15.0,
	"time" : 4.0
}

const LONG_FISH : Dictionary = {
	"name" : "Long Fish",
	"image" : NodePath("res://assets/textures/fish/wip_fish/LongFish.png"),
	"weight" : 5.0,
	"inputs" : ["Right","Right","Right","Right","Right","Right","Right","Right"],
	"value" : 10.0,
	"time" : 4.0
}

const CATFISH : Dictionary = {
	"name" : "Catfish",
	"image" : NodePath("res://assets/textures/fish/wip_fish/Catfish.png"),
	"weight" : 4.0,
	"inputs" : ["Left", "Right", "Left", "Up", "Up","Up"],
	"value" : 7.0,
	"time" : 3.5
}

const FIH : Dictionary = {
	"name" : "Fih",
	"image" : NodePath("res://assets/textures/fish/wip_fish/Fih.png"),
	"weight" : 2.0,
	"inputs" : ["Right","Up","Left","Down","Right","Up","Left","Down",],
	"value" : 6.0,
	"time" : 3.4
}

const DEFAULT_CUBE : Dictionary = {
	"name" : "Default Blender Cube",
	"image" : NodePath("res://assets/textures/fish/wip_fish/BlenderCube.png"),
	"weight" : 10.0,
	"inputs" : ["Left","Right","Up","Down","Left","Right","Up","Down"],
	"value" : 15.0,
	"time" : 5.0
}
