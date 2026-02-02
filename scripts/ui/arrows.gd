extends Node

@export var input_length : int = 3
@export var input_string : TextEdit
@export var reaction : Sprite2D
@export var potential_fish : Array[FishResource]
@export var timer : Timer
@export var progress_bar : ProgressBar
@export var success : Texture2D
@export var failure : Texture2D

@export var arrow_direction : Dictionary[String, Texture2D]

var input_array : Array[String]
var player_inputs = "0"
var correct_inputs = "0"
var current_fish : FishResource
var input_index = 0
var progress : float
var caught = 0
var sprite_array : Array[ArrowSprite]

var variant : bool 


#Protoype for making variants. If fish is variant, makes arrows gold and fails on incorrect input
func make_variant():
	if randi_range(0,5) > 2:
		variant = true




func start_minigame():
	make_variant()
	$Reaction.texture = null #Clears out the Image loaded
	current_fish = potential_fish.pick_random() # Picks a random fish 
	current_fish.intialize() # Prepares the array of correct inputs
	correct_inputs = current_fish.current_inputs # Loads the array of correct Inputs
	input_array = current_fish.current_inputs
	display_text = correct_inputs.duplicate(true)
	print(current_fish.name) #Debug
	cleared = false
	timer.start(current_fish.time)
	#text_render()
	timer.set_paused(false)
	progress_bar.max_value = current_fish.time
	input_index = 0
	spawn_arrows()

func end_minigame():
	current_fish = null
	

#Initialize Script
func _ready() -> void:
	start_minigame()


#Displays the list of inputs for debug
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
				correct_input()
			else:
				incorrect_input()
			win()

func correct_input():
		print("cool")
		input_index = input_index + 1 #Advances in the string index
		#text_render()
		$Reaction.set_texture(success)
		var current_sprite : ArrowSprite = sprite_array.pop_front()
		if current_sprite:
			current_sprite.correct()

func incorrect_input():
	print("Lame!")
	$Reaction.set_texture(failure)
	var incorrect_sprite: ArrowSprite = sprite_array[0]
	incorrect_sprite.incorrect()
	if variant:
		fail()
	set_process_input(false)
	await get_tree().create_timer(0.3).timeout
	set_process_input(true)


#Countdowns the progress bar
func _physics_process(_delta):
	progress_bar.value = timer.time_left
	if cleared:
		timer.set_paused(true)
	pass
#Time runout
func _on_timer_timeout() -> void:
	fail() # Replace with function body.

#Fail Script
func fail():
	for i in sprite_array:
		i.erase()
	timer.set_paused(true)
	input_string.set_text("Times Up!!")
	$Reaction.set_texture(failure)
	for item in sprite_array:
		$ArrowSprite.erase()
	cleared = true
	await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()

#Win Script. Prints fish data and resets the scene after 3 seconds
var cleared = false
func win():
	if input_index == input_array.size() :
		print("Caught:" + str(caught))
		caught += 1
		cleared = true
		$Reaction.texture = current_fish.image
		input_index = 0
		print(current_fish.name)
		input_string.set_text(current_fish.name + "\n Weight: " + str(current_fish.weight) + "\n Value: " + str(current_fish.value))
		player_data.add_score(current_fish.value)
		await get_tree().create_timer(3).timeout
		get_tree().reload_current_scene()



#Displays Arrow graphics
func spawn_arrows():
	sprite_array = []
	var count : int =0
	var measurement : int = 0
	for i in input_array:
		if variant:
			$ArrowSprite.modulate = Color.GOLD
		count += 1
		var node_to_copy = $ArrowSprite
		var copy = node_to_copy.duplicate()
		copy.texture = arrow_direction[i]
		add_child(copy)
		sprite_array.append(copy)
		copy.position = Vector2($ArrowOrigin.position.x +(count * 130), $ArrowOrigin.position.y)
		measurement += 200
	$ArrowLoader.position = Vector2($ArrowOrigin.position.x - measurement, $ArrowOrigin.position.y)
