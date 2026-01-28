extends Node2D

@export var input_length : int = 3
@export var input_string : TextEdit
@export var reaction : Sprite2D
@export var potential_fish : Array[FishResource]
@export var timer : Timer
@export var progress_bar : ProgressBar
@export var success : Texture2D
@export var failure : Texture2D



var input_array : Array[String]
var player_inputs = "0"
var correct_inputs = "0"
var current_fish : FishResource
var input_index = 0
var progress : float
var caught = 0


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
	timer.start(current_fish.time)
	text_render()
	timer.set_paused(false)
	progress_bar.max_value = current_fish.time
	input_index = 0
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
func _input(_event : InputEvent):
	
	if Input.is_action_just_pressed("Up"):
		player_inputs = "Up"
	if Input.is_action_just_pressed("Down"):
		player_inputs = "Down"
	if Input.is_action_just_pressed("Left"):
		player_inputs = "Left"
	if Input.is_action_just_pressed("Right"):
		player_inputs = "Right"
	
	if input_index <= input_array.size() and cleared == false:
		if Input.is_action_just_pressed("Up") or Input.is_action_just_pressed("Down") or Input.is_action_just_pressed("Right") or Input.is_action_just_pressed("Left") :
			if player_inputs == input_array[input_index]:
				print("cool")
				input_index = input_index + 1 #Advances in the string index
				text_render()
				$Sprite2D.set_texture(success)
				print(input_array)
			else:
				print("Lame!")
				$Sprite2D.set_texture(failure)
			clear()


#Countdowns the progress bar
func _physics_process(_delta):
	progress_bar.value = timer.time_left
	if cleared:
		timer.set_paused(true)
	pass

	



func fail():
	cleared = true
	input_string.set_text("Times Up!!")
	$Sprite2D.set_texture(failure)
	await get_tree().create_timer(3).timeout
	queue_free()

#Process for when index reaches end of array. Prints text and resets the scene after 3 seconds
var cleared = false
func clear():
	if input_index == input_array.size() :
		print("Caught:" + str(caught))
		caught += 1
		cleared = true
		$Sprite2D.texture = current_fish.image
		input_index = 0
		print(current_fish.name)
		input_string.set_text(current_fish.name + "\n Weight: " + str(current_fish.weight) + "\n Value: " + str(current_fish.value)
		)
		await get_tree().create_timer(3).timeout
		start_minigame()
		
		


func _on_timer_timeout() -> void:
	fail() # Replace with function body.
