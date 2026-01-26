extends Node2D

@export var input_length : int = 3
@export var input_string : TextEdit
@export var reaction : Sprite2D
@export var potential_fish : Array[FishResource]

var input_array : Array[String]
var potential_inputs : Array[String] = ["Left","Right","Up","Down"]
var current_input = "0"
var correct_input = "0"
var output = ""
var current_fish : FishResource




func start_minigame():
	current_fish = potential_fish.pick_random()
	current_fish.intialize()
	print(current_fish)
	input_array = current_fish.current_inputs
	input_string.set_text(output)
	print(input_array)
	text_render()
	
func end_minigame():
	current_fish = null
	





#Initialize Script
func _ready() -> void:
	start_minigame()
	

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
		print(current_fish.name)
		input_string.set_text(current_fish.name)
		await get_tree().create_timer(3).timeout
		start_minigame()
		
