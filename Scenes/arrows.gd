extends Node2D

@export var input_length : int = 3
@export var input_string : TextEdit
@export var reaction : Sprite2D
@export var potential_fish : Array[FishResource]

var input_array : Array[String]
var player_inputs = "0"
var correct_inputs = "0"
var current_fish : FishResource
var input_index = 0


func start_minigame():
	$Sprite2D.texture = null #Clears out the Image loaded
	current_fish = potential_fish.pick_random() # Picks a random fish 
	current_fish.intialize() # Prepares the array of correct inputs
	correct_inputs = current_fish.current_inputs # Loads the array of correct Inputs
	input_array = current_fish.current_inputs
	display_text = correct_inputs.duplicate(true)
	print(current_fish.name) #Debug
	print(current_fish.correct_inputs) #Debug
	print(current_fish.current_inputs) #Debug
	cleared = false
	text_render()
	
func end_minigame():
	current_fish = null
	

#Initialize Script
func _ready() -> void:
	start_minigame()
	

#Displays the list of inputs

var output = ""
var display_text : Array[String]
func text_render():
	if not input_index == input_array.size() :
		output = ""
		for i in display_text:
			output += i + " "
			input_string.set_text(output)
		display_text.remove_at(0)
			
	else:
		pass


#On Key Press: Checks if Key Press is the same as the current correct input 
func _input(event : InputEvent):
	if input_index <= input_array.size() and cleared == false:
		if Input.is_action_just_pressed("Up") or Input.is_action_just_pressed("Down") or Input.is_action_just_pressed("Right") or Input.is_action_just_pressed("Left") :
			player_inputs = event.as_text() #This converts key press to string, should be changed later
			if player_inputs == input_array[input_index]:
				print("cool")
				input_index = input_index + 1 #Advances in the string index
				text_render()
				$Sprite2D.texture = preload("res://assets/Debug assets/Cool.png")
				print(input_array)
			else:
				print("Lame!")
				$Sprite2D.texture = preload("res://assets/Debug assets/Lame.png")
			clear()



#Process for when index reaches end of array. Prints text and resets the scene after 3 seconds
var cleared = false
func clear():
	if input_index == input_array.size() :
		cleared = true
		$Sprite2D.texture = current_fish.image
		input_index = 0
		print(current_fish.name)
		input_string.set_text(current_fish.name)
		await get_tree().create_timer(3).timeout
		start_minigame()
		
