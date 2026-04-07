extends BasePopup
class_name MinigamePopup

## Audio exports
@export_category("Audio")
@export var _default_bgm: AudioStream
@export var _sfx_round_start: AudioStream
@export var _sfx_timer_start: AudioStream
@export var _sfx_timer_end: AudioStream
@export var _sfx_struggle: AudioStream
@export var _sfx_success_arrow: AudioStream
@export var _sfx_fail: AudioStream
@export var _sfx_gold_fail: AudioStream
@export var _sfx_fish_caught: AudioStream

@export_category("Children Nodes")
@export var _reaction_node: Sprite2D
@export var _countdown_bar: CountdownBar
@export var _arrow_container: ArrowContainer
@export var _results_window: ResultsWindow

@export_category("Data")
@export var _arrow_scene: PackedScene

# Public Fish Data
var current_name: String = ""
var current_image: NodePath
var current_weight: float = 0.0
var correct_inputs: Array
var current_value: float = 0.0
var time: float = 0.0
var chosen_fish_id: int

# Variants
enum FishVariantType {
	NORMAL,
	GOLD,
	EVIL,
	OBSCURED,
}
var _fish_variant_weights: Dictionary[FishVariantType, float] = {
	FishVariantType.NORMAL: 50.0,
	FishVariantType.GOLD: 10.0,
	FishVariantType.EVIL: 40.0,
	FishVariantType.OBSCURED: 0.0,
}
var chosen_fish_variant: FishVariantType # Holds the current variant

# Rarity
enum FishRarityType {
	COMMON,
	RARE,
	LEGENDARY
}
var _fish_rarity_weights: Dictionary[FishRarityType, float] = {
	FishRarityType.COMMON: 70.0,
	FishRarityType.RARE: 25.0,
	FishRarityType.LEGENDARY: 5.0
}
var chosen_fish_rarity: FishRarityType

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _input_array: Array = [] # Holds the correct sequence of inputs per fish
var _input_index: int = 0 # Holds the index for the current input in the input array
var _delay : bool = false
var _distance: float = -1
var _cleared = false

func _on_set_params() -> void:
	_distance = params.get("_distance", -1)


# Initialize Script
func _ready() -> void:
	_rng.randomize()
	AudioEngine.play_bgm(_default_bgm)
	
	_start_minigame()


# On Ready
func _start_minigame() -> void:
	chosen_fish_id = _pick_fish()
	chosen_fish_variant = _choose_variant()
	chosen_fish_rarity = _choose_rarity() #TODO Make this do things.
	
	print(FishData.FISH_ID[chosen_fish_id]["name"])
	
	_apply_data()
	_setup_timer()
	
	if _check_instant_win(): return
	
	spawn_arrows()
	_input_index = 0


func _pick_fish() -> int:
	var fish_id_array: Array = FishData.FISH_ID.keys()
	var random_fish: int = fish_id_array[_rng.randi_range(0, fish_id_array.size() - 1)]
	
	return random_fish


func _choose_variant() -> FishVariantType:
	var chosen_variant = _pick_weighted(_fish_variant_weights)
	return chosen_variant


func _choose_rarity() -> FishRarityType:
	var chosen_rarity = _pick_weighted(_fish_rarity_weights)
	return chosen_rarity


func _pick_weighted(weights: Dictionary) -> Variant:
	var total: float = 0.0
	for weight in weights.values():
		total += weight
	
	var roll: float = _rng.randf_range(0.0, total)
	var cumulative: float = 0.0
	
	for key in weights.keys():
		cumulative += weights[key]
		if roll <= cumulative: return key
	
	return weights.keys()[0]


func _apply_data() -> void:
	var chosen_fish = FishData.FISH_ID[chosen_fish_id]
	current_name = chosen_fish["name"]
	current_image = chosen_fish["image"]
	current_weight = chosen_fish["weight"]
	correct_inputs = chosen_fish["inputs"]
	current_value = chosen_fish["value"]
	time = chosen_fish["time"]
	
	_input_array = correct_inputs


func _setup_timer() -> void:
	_countdown_bar.setup(time)
	_countdown_bar.timer.timeout.connect(_fail)
	
	AudioEngine.play_sfx(_sfx_round_start)
	AudioEngine.play_sfx(_sfx_timer_start)


func _check_instant_win() -> bool:
	#TODO The check for this should be more generic, with variable success rate.
	if SystemData.get_upgrade(ItemData.REEL).get(ItemData.KEY_NAME, "") == "Fishtagram Reel":
		var diceroll: float = _rng.randf_range(0, 1)
		
		if diceroll >= 0.9:
			_cleared = true
			_win()
			$ReelSkipAnim.play("Reel_Skipped")
			return true
	
	return false


# Displays Arrow graphics
func spawn_arrows():
	for direction in _input_array:
		var arrow_child: Arrow = _arrow_scene.instantiate()
		match direction:
			"Left":		arrow_child.direction = Arrow.Directions.LEFT
			"Up":		arrow_child.direction = Arrow.Directions.UP
			"Right":	arrow_child.direction = Arrow.Directions.RIGHT
			"Down":		arrow_child.direction = Arrow.Directions.DOWN
		
		var arrow_type = _choose_arrow_type()
		arrow_child.arrow_type = arrow_type
		
		_arrow_container.add_arrow(arrow_child)


func _choose_arrow_type() -> Arrow.ArrowType:
	var roll = _rng.randf_range(0.0, 1.0)
	
	match chosen_fish_variant:
		FishVariantType.GOLD:
			return Arrow.ArrowType.GOLD
		FishVariantType.EVIL:
			if roll >= 0.75: return Arrow.ArrowType.EVIL
		FishVariantType.OBSCURED:
			if roll >= 0.85: return Arrow.ArrowType.OBSCURED
	
	return Arrow.ArrowType.NORMAL


# On Key Press: Checks if Key Press is the same as the current correct input 
func _input(event : InputEvent):
	var player_inputs: String = ""
	
	if Input.is_action_just_pressed("up"):		player_inputs = "Up"
	if Input.is_action_just_pressed("down"):	player_inputs = "Down"
	if Input.is_action_just_pressed("left"):	player_inputs = "Left"
	if Input.is_action_just_pressed("right"):	player_inputs = "Right"
	
	if _input_index <= _input_array.size() and !_cleared:
		if player_inputs:
			if player_inputs == _input_array[_input_index]: correct_input()
			else: incorrect_input()
			
			if _input_index == _input_array.size(): _win()
	
	if event is InputEventMouseMotion: return
	if _delay: _return_to_fishing()

# On correct Input
func correct_input():
	_arrow_container.correct_arrow(_input_index)
	
	_input_index += 1 # Advances in the string index
	_arrow_container.current_arrow_index = _input_index
	AudioEngine.play_sfx(_sfx_success_arrow)


#On incorrect Input
func incorrect_input():
	_arrow_container.incorrect_arrow(_input_index)
	
	if chosen_fish_variant == FishVariantType.GOLD:
		_fail()
		return
	
	set_process_input(false)
	await get_tree().create_timer(0.3).timeout
	set_process_input(true)
	


func _process(_delta: float) -> void:
	if !_cleared:
		if !AudioEngine.is_sfx_key_stream_playing(_sfx_struggle):
			AudioEngine.play_sfx(_sfx_struggle)
	if _cleared:
		_countdown_bar.stop()
		set_process(false)


#Fail Script
func _fail():
	set_process_input(false)
	_arrow_container.hide()
	
	AudioEngine.stop_all_sfx()
	AudioEngine.play_sfx(_sfx_fail)
	
	_cleared = true
	
	if chosen_fish_variant == FishVariantType.GOLD:
		AudioEngine.play_sfx(_sfx_gold_fail)
		_arrow_container.erase_all_arrows()
	
	_results_window.set_text("Times Up!!")
	_results_window.show()
	
	_prep_return_to_fishing()


func _win():
	set_process_input(false)
	_arrow_container.hide()
	
	AudioEngine.stop_all_sfx()
	AudioEngine.stop_sfx_key(_sfx_timer_start)
	AudioEngine.play_sfx(_sfx_timer_end)
	AudioEngine.play_sfx(_sfx_fish_caught)
	
	_cleared = true
	
	var fish_image: Texture = load(current_image)
	_reaction_node.texture = fish_image
	
	match chosen_fish_variant:
		FishVariantType.GOLD:		current_value = current_value * 2
		FishVariantType.EVIL:		current_value = current_value * 1.5
		FishVariantType.OBSCURED:	current_value = current_value * 1.75
	
	if _distance > 0:
		var distance_multiplier: float = pow(2.0, log(_distance / 100) / log(10))
		current_value *= distance_multiplier
	
	current_value *= SystemData.value_multiplier
	
	_results_window.set_text(current_name + "\n Weight: %.2f\n Value: %.2f" % [current_weight, current_value])
	_results_window.show()
	
	SystemData._add_money_delay(current_value)
	SystemData._add_fish(chosen_fish_id)
	
	if chosen_fish_id == 21:
		await get_tree().create_timer(2.5).timeout
		$ReactionAnimation.play()
		await get_tree().create_timer(0.5).timeout
		_return_to_fishing()
	
	else: _prep_return_to_fishing()


func _prep_return_to_fishing() -> void:
	await get_tree().create_timer(1.0).timeout
	set_process_input(true)
	_delay = true
	
	await get_tree().create_timer(5.0).timeout
	_return_to_fishing()


func _return_to_fishing() -> void:
	if !is_inside_tree() or is_queued_for_deletion(): return
	
	PlayManager.request_catching_state()
	AudioEngine.stop_all_sfx()
	
	# TODO Stuff you want to happen between catching and idle, such as a fail animation. Note that we're paused
	
	PlayManager.request_idle_day_state()
	GameManager.popup_queue.dismiss_popup()
