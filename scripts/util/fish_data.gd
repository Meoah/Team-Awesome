extends Resource
class_name FishData

@export var display_name: String
@export var fish_price: int
@export var icon: Texture2D

const bug_eyed_fish : Dictionary = {
	"name" : "Bug Eyed Fish",
	"image" : "res://assets/textures/fish/doodle_fish/Fish01.png",
	"weight" : "5",
	"inputs" : ["Left","Right","Up","Down"],
	"value" : 3.0,
	"time" : 5
}


const rainbow_eel : Dictionary = {
	"name" : "Rainbow Eel",
	"image" : "res://assets/textures/fish/doodle_fish/Fish04.png",
	"weight" : "10",
	"inputs" : ["Down", "Left", "Up", "Right","Down","Down"],
	"value" : 7.0,
	"time" : 3.5
}

const trash : Dictionary = {
	"name" : "Trash",
	"image" : "res://assets/textures/fish/doodle_fish/Fish02.png",
	"weight" : "2",
	"inputs" : ["Up","Up","Right"],
	"value" : -2.0,
	"time" : 4
}

const pink_fish : Dictionary = {
	"name" : "Pink Fish",
	"image" : "res://assets/textures/fish/doodle_fish/Fish03.png",
	"weight" : "2",
	"inputs" : ["Left","Right","Left","Right"],
	"value" : 4.0,
	"time" : 3
}

const shroomle : Dictionary = {
	"name" : "Shroomle",
	"image" : "res://assets/textures/fish/doodle_fish/Fish05.png",
	"weight" : "5",
	"inputs" : ["Left","Right","Up","Down","Up"],
	"value" : 10.0,
	"time" : 5
}

const fish_id : Dictionary = {
	"01" : bug_eyed_fish,
	"02" : rainbow_eel,
	"03" : trash,
	"04" : pink_fish,
	"05" : shroomle
}
