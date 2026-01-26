extends Node2D

@export var input_length : int = 3
@export var input_string : TextEdit
@export var reaction : Sprite2D

var input_array : Array[String]
var potential_inputs : Array[String] = ["Left","Right","Up","Down"]
var current_input = "0"
var correct_input = "0"
var output = ""

#Initialize Script
func _ready() -> void:
	input_length = randi_range(3,10)
	print(generate_inputs())
	print(correct_input)
	text_render()
	input_string.set_text(output)
	

#Generates the list of Inputs
func generate_inputs()-> Array[String]:
	var return_array : Array[String]
	for i in input_length:
		var input = potential_inputs.pick_random()
		return_array.append(input) 
	input_array = return_array
	print(input_array)
	return return_array
	

#Displays the list of inputs
func text_render():
	output = ""
	for i in input_array:
		output += i + " "
		input_string.set_text(output)


#On Key Press: Checks if Key Press is the same as Index 0 of list of inputs
func _input(event : InputEvent):
	if input_array :
		if Input.is_action_just_pressed("Up") or Input.is_action_just_pressed("Down") or Input.is_action_just_pressed("Right") or Input.is_action_just_pressed("Left") :
			current_input = event.as_text() #This converts key press to string, should be changed later
			if current_input == input_array[0]:
				print("cool")
				input_array.remove_at(0)
				output = ""
				for i in input_array:
					output += i + " "
				input_string.set_text(output)
				$Sprite2D.texture = preload("res://assets/Debug assets/Cool.png")
				print(input_array)
			else:
				print("Lame!")
				$Sprite2D.texture = preload("res://assets/Debug assets/Lame.png")
			clear()

#Process for when List is empty. Prints text and resets the scene after 3 seconds
func clear():
	if input_array.size() == 0:
		print("You Win!!")
		input_string.set_text("You Win!!")
		await get_tree().create_timer(3).timeout
		get_tree().reload_current_scene()
		
