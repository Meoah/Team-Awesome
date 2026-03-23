extends BasePopup
class_name BossUIPopup

@export_category("Node Exports")
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

func apply_data():
	var chosen_fish = FishData.BOSS_ID[01]
	current_name = chosen_fish["name"]
	current_image = chosen_fish["image"]
	current_weight = chosen_fish["weight"]
	correct_inputs = chosen_fish["inputs"]
	current_value = chosen_fish["value"]
	time = chosen_fish["time"]

var display_text : Array

func _ready() -> void:
	start_minigame()




#On Ready
func start_minigame():
	apply_data()
	input_array = correct_inputs.duplicate()
	display_text = correct_inputs.duplicate(true)
	#timer_seqeunce()
	#await timer_seqeunce()
	#AudioEngine.play_bgm(default_bgm)
	#progress_bar.max_value = time
	input_index = 0
	spawn_arrows()




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
			deal_damage()


func randInput():
	var input_pool = correct_inputs.duplicate()
	return input_pool.pick_random()


var dice_check : int = 3

#On correct Input
func correct_input():
	#input_index = input_index + 1 #Advances in the string index
	input_array.pop_front()
	var dice_roll :int = randi_range(0,10)
	if dice_roll < dice_check : 
		var appending_input = randInput()
		input_array.append(appending_input)
		var node_to_copy = $PanelContainer/HBoxContainer/TextureRect
		var copy = node_to_copy.duplicate()
		copy.texture = arrow_direction[appending_input]
		$PanelContainer/HBoxContainer.add_child(copy)
		sprite_array.append(copy)
	print(input_array)
	#text_render()
	#$Reaction.set_texture(success)
	#AudioEngine.play_sfx(sfx_success_arrow)
	#AudioEngine.play_sfx(sfx_success_arrow2)
	var current_sprite : ArrowTexture = sprite_array.pop_front()
	
	if current_sprite:
		current_sprite.correct()


#On incorrect Input
func incorrect_input():
	#$Reaction.set_texture(failure)
	if not sprite_array.is_empty():
		var incorrect_sprite: ArrowTexture = sprite_array[0]
		incorrect_sprite.incorrect()

	set_process_input(false)
	await get_tree().create_timer(0.3).timeout
	set_process_input(true)




func deal_damage():
	if input_array.is_empty() :
		$BossStamina.value -= 33
		input_array = correct_inputs.duplicate()
		await get_tree().create_timer(0.3).timeout
		spawn_arrows()
		dice_check += 1





#Win Script. Prints fish data and resets the scene after 3 seconds
var cleared = false
func win():
	if input_array.is_empty() :
		cleared = true
		var fish_image = load(current_image)
		input_index = 0
		#AudioEngine.stop_sfx_key(sfx_timer_start)
		#AudioEngine.play_sfx(sfx_timer_end,"", 0.5)
		#AudioEngine.play_sfx(sfx_fish_caught,"", 1)
		$PanelContainer.hide()
		#input_string.set_text(current_name + "\n Weight: " + str(current_weight) + "\n Value: " + str(current_value))
		SystemData._add_money_delay(current_value)
		SystemData._add_fish(chosen_fish_id)
		if chosen_fish_id == 21:
			await get_tree().create_timer(2.5).timeout
			$AnimatedSprite2D.play()
			await get_tree().create_timer(0.5).timeout
			PlayManager.request_catching_state()
			# Stuff you want to happen between catching and idle, such as a catch animation. Note that we're paused
			PlayManager.request_idle_day_state()
			GameManager.popup_queue.dismiss_popup()
		await get_tree().create_timer(3).timeout
		PlayManager.request_catching_state()
		AudioEngine.stop_all_sfx()
		# Stuff you want to happen between catching and idle, such as a catch animation. Note that we're paused
		PlayManager.request_idle_day_state()
		GameManager.popup_queue.dismiss_popup()




#Displays Arrow graphics
func spawn_arrows():
	sprite_array = []
	var spawn_string : Array
	spawn_string = display_text
	# For loop that spawns arrows
	for i in spawn_string:
		var node_to_copy = $PanelContainer/HBoxContainer/TextureRect
		var copy = node_to_copy.duplicate()
		copy.texture = arrow_direction[i]
		$PanelContainer/HBoxContainer.add_child(copy)
		sprite_array.append(copy)
		#copy.position = Vector2($Control/HBoxContainer.position.x +(count * 130), $Control/HBoxContainer.position.y)
	print(input_array)
