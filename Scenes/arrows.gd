extends Node2D

@export var input_length : int = 3

var input_array : Array[String]
var potential_inputs : Array[String] = ["left","right","up","down"]
func _ready() -> void:
	print(generate_inputs())


func generate_inputs()-> Array[String]:
	var return_array : Array[String]
	for i in input_length:
		var input = potential_inputs.pick_random()
		return_array.append(input) 
	return return_array
