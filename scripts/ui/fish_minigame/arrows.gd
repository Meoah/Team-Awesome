extends BasePopup
class_name MinigameUIPopup

@export var input_string : TextEdit #Accessing TextEdit box
@export var reaction : Sprite2D #Accessing Sprite2D for reaction image
@export var timer : Timer #Accessing Timer for the countdown
@export var progress_bar : ProgressBar #Accessing ProgressBar for the countdown bar
@export var success : Texture2D #Success Image
@export var failure : Texture2D #Fail Image
@export var variants : Array[String] #Creating Variants for Fishes

@export var arrow_direction : Dictionary[String, Texture2D] #Loads Arrow Direction Sprites

const fishdata = "res://scripts/util/fish_data.gd"

var input_array : Array #Holds the correct sequence of inputs per fish
var player_inputs = "0" #Holds the current player input
var input_index = 0 #Holds the index for the current input in the input array#Holds ammount of fish caught
var sprite_array : Array[ArrowTexture] #Accessing the ArrowSprite Class



#Fish Data
var current_name : String = ""
var current_image : NodePath
var current_weight : float = 0
var correct_inputs : Array
var current_value : float = 0
var time : float = 0

var chosen_fish_id : int
func pick_fish():
	var keys_array :Array = FishData.FISH_ID.keys()
	var random_fish = keys_array.pick_random()
	chosen_fish_id = random_fish
	print(FishData.FISH_ID[chosen_fish_id]["name"])

func apply_data():
	var chosen_fish = FishData.FISH_ID[chosen_fish_id]
	current_name = chosen_fish["name"]
	current_image = chosen_fish["image"]
	current_weight = chosen_fish["weight"]
	correct_inputs = chosen_fish["inputs"]
	current_value = chosen_fish["value"]
	time = chosen_fish["time"]




#Variants 
var variant #Sets up current fish variant
var chosen_variant : String #Holds the current variant
var varied_gold : bool = false #Gold Variant
var varied_evil : bool = false #Evil Variant
var varied_obscured : bool = false #Obscured Variant

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
		dissipation = 1


#Evil Variant script. Work in Progress
var evil_array : Array
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



#On Ready
func start_minigame():
	pick_fish()
	apply_data()
	choose_variant()
	input_array = correct_inputs
	display_text = correct_inputs.duplicate(true)
	timer_seqeunce()
	await timer_seqeunce()
	$BGM.play()
	progress_bar.max_value = time
	input_index = 0
	spawn_arrows()

	
	

func end_minigame():
	varied_evil = false
	varied_gold = false
	varied_obscured = false
	

#Initialize Script
func _ready() -> void:
	start_minigame()



#Displays the list of inputs for debug
var output = ""
var display_text : Array
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
	
	if Input.is_action_just_pressed("up"):
		player_inputs = "Up"
	if Input.is_action_just_pressed("down"):
		player_inputs = "Down"
	if Input.is_action_just_pressed("left"):
		player_inputs = "Left"
	if Input.is_action_just_pressed("right"):
		player_inputs = "Right"
	
	if input_index <= input_array.size() and cleared == false:
		if Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down") or Input.is_action_just_pressed("right") or Input.is_action_just_pressed("left") :
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
		$InputSfx.play()
		$InputSfx/InputSfx2.play()
		var current_sprite : ArrowTexture = sprite_array.pop_front()
		var smoke : smoke_sprite = $Smoke
		if varied_obscured:
			if input_index == random_index +1:
				smoke.smoke_anim()
		if current_sprite:
			current_sprite.correct()
			


func sparks():
	var tween = create_tween()
	if not cleared:
		tween.tween_property($ProgressBar/Sparks, "position", $ProgressBar/End.position, time )
	if cleared:
		tween.pause()


func timer_seqeunce():
	timer.start(time)
	timer.set_paused(false)
	$StarterShot.play()
	$TimerSfx.play()
	$ProgressBar/Sparks.position = $ProgressBar/Start.position
	sparks()
	


#On incorrect Input
func incorrect_input():
	$Reaction.set_texture(failure)
	var incorrect_sprite: ArrowTexture = sprite_array[0]
	incorrect_sprite.incorrect()
	if varied_gold:
		fail()
	set_process_input(false)
	await get_tree().create_timer(0.3).timeout
	set_process_input(true)
	if varied_obscured:
		$Smoke.material.set_shader_parameter("alpha", dissipation)
		dissipation -= 0.25
var dissipation : float = 1

#Countdowns the progress bar
func _process(_delta):
	progress_bar.value = timer.time_left
	$ProgressBar/Label.set_text("%.2f s" % timer.time_left)
	if cleared:
		timer.set_paused(true)

#Time runout
func _on_timer_timeout() -> void:
	fail() # Replace with function body.

#Fail Script
func fail():
	if varied_gold:
		$GoldFail.play()
		$ProgressBar/Sparks.hide()
		for i in sprite_array:
			i.erase()
	timer.set_paused(true)
	input_string.set_text("Times Up!!")
	$Reaction.set_texture(failure)
	for item in sprite_array:
		$ArrowSprite.erase()
	cleared = true
	await get_tree().create_timer(3).timeout
	PlayManager.request_catching_state()
	# Stuff you want to happen between catching and idle, such as a fail animation. Note that we're paused
	PlayManager.request_idle_day_state()
	GameManager.popup_queue.dismiss_popup()

#Win Script. Prints fish data and resets the scene after 3 seconds
var cleared = false
func win():
	if input_index == input_array.size() :
		cleared = true
		var fish_image = load(current_image)
		$Reaction.texture = fish_image
		input_index = 0
		$TimerSfx.stop()
		$TimerSfx/TimerEndSfx.play()
		$FishCaughtSfx.play()
		$ProgressBar/Sparks.hide()
		if varied_gold: #If fish is gold double its value, Current bug where double value persist
			current_value = current_value * 2
		elif varied_evil:
			current_value = current_value * 1.5
		elif varied_obscured:
			current_value = current_value * 1.75
		input_string.set_text(current_name + "\n Weight: " + str(current_weight) + "\n Value: " + str(current_value))
		SystemData._add_money_delay(current_value)
		SystemData._add_fish(chosen_fish_id)
		await get_tree().create_timer(3).timeout
		PlayManager.request_catching_state()
		# Stuff you want to happen between catching and idle, such as a catch animation. Note that we're paused
		PlayManager.request_idle_day_state()
		GameManager.popup_queue.dismiss_popup()



#Displays Arrow graphics
func spawn_arrows():
	sprite_array = []
	var spawn_string : Array
	spawn_string = display_text
	if varied_evil:
		evilize()
		spawn_string = evil_array.duplicate()
	# For loop that spawns arrows
	for i in spawn_string:
		if varied_gold:
			$Control/HBoxContainer/TextureRect.modulate = Color.GOLD
		var node_to_copy = $Control/HBoxContainer/TextureRect
		var copy = node_to_copy.duplicate()
		copy.texture = arrow_direction[i]
		$Control/HBoxContainer.add_child(copy)
		sprite_array.append(copy)
		#copy.position = Vector2($Control/HBoxContainer.position.x +(count * 130), $Control/HBoxContainer.position.y)
	print(input_array)
	if varied_evil:
		var evil : ArrowTexture = sprite_array[random_index]
		evil.evilize()
	elif varied_obscured:
		random_index = randi_range(0, input_array.size()-1)
		print(random_index)
		$Smoke.position = sprite_array[random_index].global_position
