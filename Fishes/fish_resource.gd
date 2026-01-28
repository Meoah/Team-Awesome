extends Resource

class_name FishResource

@export var name : String 
@export var image : AtlasTexture
@export var value : int = 1
@export var input_length : int = 1
@export var weight : int = 1
@export var correct_inputs : Array[String] = ["Left","Right","Up","Down"]
@export var time : float

var current_inputs : Array[String]

func intialize():
	current_inputs = correct_inputs
