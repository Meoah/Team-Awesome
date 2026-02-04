extends Node

@export var input_string : TextEdit #Accessing TextEdit box
@export var reaction : Sprite2D #Accessing Sprite2D for reaction image
@export var potential_fish : Array[FishResource] #Creating possible fish
@export var timer : Timer #Accessing Timer for the countdown
@export var progress_bar : ProgressBar #Accessing ProgressBar for the countdown bar
@export var success : Texture2D #Success Image
@export var failure : Texture2D #Fail Image
@export var variants : Array[String] #Creating Variants for Fishes

@export var arrow_direction : Dictionary[String, Texture2D] #Loads Arrow Direction Sprites

var input_array : Array[String] #Holds the correct sequence of inputs per fish
var player_inputs = "0" #Holds the current player input
var correct_inputs = "0" #Holds the current correct input
var current_fish : FishResource #Holds the current fish in play
var input_index = 0 #Holds the index for the current input in the input array
var progress : float 
var caught = 0 #Holds ammount of fish caught
var sprite_array : Array[ArrowSprite] #Accessing the ArrowSprite Class
var current_value = 0

var variant #Sets up current fish variant
var chosen_variant : String #Holds the current variant
var varied_gold : bool = false #Gold Variant
var varied_evil : bool = false #Evil Variant
var varied_obscured : bool = false #Obscured Variant
#Protoype for making variants. If fish is variant, makes arrows gold and fails on incorrect input
func choose_variant():
	chosen_variant = variants.pick_random()
	apply_variant()
var random_index : int


#Applies Variant
func apply_variant():
	if chosen_variant =="Gold":
		varied_gold = true
	elif chosen_variant == "Evil":
		varied_evil = true
		random_index = randi_range(0, input_array.size()-1)
		print(random_index)
	elif  chosen_variant == "Obscured":
		varied_obscured = true
	
		
		

#On Ready
func start_minigame():
	choose_variant()
	$Reaction.texture = null #Clears out the Image loaded
	current_fish = potential_fish.pick_random() # Picks a random fish 
	current_fish.intialize() # Prepares the array of correct inputs
	current_value = current_fish.value
	correct_inputs = current_fish.current_inputs # Loads the array of correct Inputs
	input_array = current_fish.current_inputs
	display_text = correct_inputs.duplicate(true)
	print(current_fish.name) #Debug
	cleared = false
	timer.start(current_fish.time)
	timer.set_paused(false)
	progress_bar.max_value = current_fish.time
	input_index = 0
	spawn_arrows()

func end_minigame():
	varied_evil = false
	varied_gold = false
	varied_obscured = false
	current_fish = null
	

#Initialize Script
func _ready() -> void:
	start_minigame()

#Evil Variant script. Work in Progress
var evil_array : Array[String]
func evilize():
	evil_array = display_text.duplicate()
	if display_text[random_index] == "Left":
		evil_array[random_index]= "Right"
	elif display_text[random_index] == "Up":
		evil_array[random_index]= "Down"
	elif display_text[random_index] == "Right":
		evil_array[random_index]= "Left"
	elif display_text[random_index] == "Down":
		evil_array[random_index]= "Up"

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
#On correct Input
func correct_input():
		input_index = input_index + 1 #Advances in the string index
		#text_render()
		$Reaction.set_texture(success)
		var current_sprite : ArrowSprite = sprite_array.pop_front()
		if current_sprite:
			current_sprite.correct()
#On incorrect Input
func incorrect_input():
	$Reaction.set_texture(failure)
	var incorrect_sprite: ArrowSprite = sprite_array[0]
	incorrect_sprite.incorrect()
	if varied_gold:
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
	if varied_gold:
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
		if varied_gold: #If fish is gold double its value, Current bug where double value persist
			current_value = current_fish.value * 2
		elif varied_evil:
			current_value = current_fish.value * 1.5
		elif varied_obscured:
			current_value = current_fish.value * 1.75
		input_string.set_text(current_fish.name + "\n Weight: " + str(current_fish.weight) + "\n Value: " + str(current_value))
		player_data.add_score(current_fish.value)
		await get_tree().create_timer(3).timeout
		get_tree().reload_current_scene()

func smoke_anim():
	var tween = get_tree().create_tween()



#Displays Arrow graphics
func spawn_arrows():
	sprite_array = []
	var count : int =0
	var measurement : int = 0
	var spawn_string : Array[String]
	spawn_string = display_text
	if varied_evil:
		evilize()
		spawn_string = evil_array.duplicate()
	# For loop that spawns arrows
	for i in spawn_string:
		if varied_gold:
			$ArrowSprite.modulate = Color.GOLD
		count += 1
		var node_to_copy = $ArrowSprite
		var copy = node_to_copy.duplicate()
		copy.texture = arrow_direction[i]
		add_child(copy)
		sprite_array.append(copy)
		copy.position = Vector2($ArrowOrigin.position.x +(count * 130), $ArrowOrigin.position.y)
		measurement += 200
	print(input_array)
	if varied_evil:
		var evil : ArrowSprite = sprite_array[random_index]
		evil.evilize()
	elif varied_obscured:
		random_index = randi_range(0, input_array.size()-1)
		$Smoke.position = sprite_array[random_index].position
	$ArrowLoader.position = Vector2($ArrowOrigin.position.x - measurement, $ArrowOrigin.position.y)
