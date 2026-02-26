extends RefCounted
class_name FishData

var display_name: String
var fish_price: int
var icon: Texture2D

# Table of Contents. When refrencing fish, use the ID accociated to locate the data.
const FISH_ID : Dictionary = {
	1 : ACORN_FISH,
	2 : RAINBOW_EEL,
	3 : TRASH,
	4 : SWEDISH_TETRA,
	5 : SHROOMLE,
	6 : LINXOOO,
	7 : HONEY_GLAZED_SKELETON,
	8 : DOODLE_BIRD,
	9 : DOODLE_BIRD_RARE,
	10 : LONG_FEESH,
	11 : FIH,
	12 : CATFISH,
	13 : BLENDER_CARP,
	14 : BUBBLE_GOLDFISH,
	15 : JELLOFISH,
	16 : PUFFER_CRAB,
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

const ACORN_FISH : Dictionary = {
	"name" : "Acorn Fish",
	"image" : NodePath("res://assets/textures/fish/final_fish/01_AcornGoldfish.png"),
	"weight" : 5.0,
	"inputs" : ["Left","Right","Up","Down"],
	"value" : 3.0,
	"time" : 5.0
}

const RAINBOW_EEL : Dictionary = {
	"name" : "Sour Striped Eel",
	"image" : NodePath("res://assets/textures/fish/final_fish/02_SourStripedEel.png"),
	"weight" : 10.0,
	"inputs" : ["Down", "Left", "Up", "Right","Down","Down"],
	"value" : 7.0,
	"time" : 3.5
}

const TRASH : Dictionary = {
	"name" : "Trash",
	"image" : NodePath("res://assets/textures/fish/final_fish/03_Trash.png"),
	"weight" : 2.0,
	"inputs" : ["Up","Up","Right"],
	"value" : -2.0,
	"time" : 4
}

const SWEDISH_TETRA : Dictionary = {
	"name" : "Swedish Tetra",
	"image" : NodePath("res://assets/textures/fish/final_fish/04_SwedishTetra.png"),
	"weight" : 2.0,
	"inputs" : ["Left","Right","Left","Right"],
	"value" : 4.0,
	"time" : 3.0
}

const SHROOMLE : Dictionary = {
	"name" : "Shroomle",
	"image" : NodePath("res://assets/textures/fish/final_fish/05_Shroomle.png"),
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

const LONG_FEESH : Dictionary = {
	"name" : "Long Feesh",
	"image" : NodePath("res://assets/textures/fish/final_fish/10_LongFeesh.png"),
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

const BLENDER_CARP : Dictionary = {
	"name" : "Blender Carp",
	"image" : NodePath("res://assets/textures/fish/final_fish/13_BlenderCarp.png"),
	"weight" : 10.0,
	"inputs" : ["Left","Right","Up","Down","Left","Right","Up","Down"],
	"value" : 15.0,
	"time" : 5.0
}

const BUBBLE_GOLDFISH : Dictionary = {
	"name" : "Bubble Eyed Goldfish",
	"image" : NodePath("res://assets/textures/fish/final_fish/14_BubbleGoldfish.png"),
	"weight" : 3.0,
	"inputs" : ["Up","Up","Up","Left","Right","Left"],
	"value" : 3.0,
	"time" : 5.0
}

const JELLOFISH: Dictionary = {
	"name" : "Jellofish",
	"image" : NodePath("res://assets/textures/fish/final_fish/15_Jellofish.png"),
	"weight" : 10.0,
	"inputs" : ["Left","Right","Up","Left","Right","Up"],
	"value" : 10.0,
	"time" : 5.0
}


const PUFFER_CRAB : Dictionary = {
	"name" : "Puffer Crab",
	"image" : NodePath("res://assets/textures/fish/final_fish/16_PufferCrab.png"),
	"weight" : 5.0,
	"inputs" : ["Up","Up","Up","Left","Left","Right","Right"],
	"value" : 30.0,
	"time" : 5.0
}
