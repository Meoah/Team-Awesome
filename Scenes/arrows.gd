extends Node2D

@export var input_length : int = 3

var input_array : Array[String]
var potential_inputs : Array[String] = ["Left","Right","Up","Down"]
var current_input = "0"
var correct_input = "0"


func _ready() -> void:
	print(generate_inputs())
	print(correct_input)
	


func generate_inputs()-> Array[String]:
	var return_array : Array[String]
	for i in input_length:
		var input = potential_inputs.pick_random()
		return_array.append(input) 
	input_array = return_array
	print(input_array)
	return return_array
	

func _input(event : InputEvent):
	if not input_array.is_empty():
		if Input.is_action_just_pressed("Up") or Input.is_action_just_pressed("Down") or Input.is_action_just_pressed("Right") or Input.is_action_just_pressed("Left") :
			current_input = event.as_text()
			if current_input == input_array[0]:
				print("cool")
				input_array.remove_at(0)
				print(input_array)
			else:
				print("Lame!")
			clear()

func clear():
	if input_array.size() == 0:
		print("You Win!!")
		
		
