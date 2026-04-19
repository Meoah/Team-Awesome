extends BasePopup
class_name BossMinigamePopup

@export_category("Audio")
@export var _default_bgm: AudioStream
@export var _sfx_round_start: AudioStream
@export var _sfx_struggle: AudioStream
@export var _sfx_success_arrow: AudioStream
@export var _sfx_wrong_arrow: AudioStream
@export var _sfx_fail: AudioStream
@export var _sfx_fish_caught: AudioStream

@export_category("Children Nodes")
@export var _reaction_node: Sprite2D
@export var _arrow_container: ArrowContainer
@export var _results_window: ResultsWindow
@export var _player_stamina_bar: TextureProgressBar
@export var _boss_stamina_bar: TextureProgressBar
@export var _player_stamina_label: Label
@export var _boss_stamina_label: Label
@export var _animation_player: AnimationPlayer
@export var _continue_indicator: Control

@export_category("Data")
@export var _arrow_scene: PackedScene

const BOSS_FISH_ID: int = 1

const PLAYER_STAMINA_MAX: float = 100.0
const BOSS_STAMINA_MAX: float = 1000.0

const PLAYER_PASSIVE_DRAIN_PER_SEC: float = 5.0
const BOSS_PASSIVE_REGEN_PER_SEC: float = 5.0

const BASE_BOSS_DAMAGE: float = 7.5
const EVIL_ARROW_DAMAGE_MULTIPLIER: float = 1.75
const HEALING_ARROW_HEAL: float = 7.5
const WRONG_INPUT_PLAYER_DAMAGE: float = 5.0

const ROW_CLEAR_PLAYER_HEAL: float = 15.0
const ROW_CLEAR_BOSS_DAMAGE: float = 50.0

const ROW_LENGTH_MIN: int = 4
const ROW_LENGTH_MAX: int = 8
const INPUT_LOCKOUT_SECONDS: float = 0.18
const NEXT_ROW_DELAY_SECONDS: float = 0.25

const BAR_SHAKE_DISTANCE: float = 5.0
const BAR_SHAKE_STEP_TIME: float = 0.04

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _distance: float = -1.0
var _cleared: bool = false
var _delay: bool = false
var _between_rows: bool = false

var _player_stamina: float = PLAYER_STAMINA_MAX
var _boss_stamina: float = BOSS_STAMINA_MAX

var _row_data: Array[Dictionary] = []
var _input_index: int = 0

var _current_name: String = ""
var _current_image: NodePath
var _current_weight: float = 0.0
var _current_value: float = 0.0
var _current_description: String = ""


func _on_set_params() -> void:
	_distance = params.get("_distance", -1.0)


func _ready() -> void:
	_rng.randomize()
	AudioEngine.play_bgm(_default_bgm)
	
	_setup_reward_data()
	_setup_stamina_ui()
	await _play_startup_sequence()
	
	if !is_inside_tree() or is_queued_for_deletion(): return
	
	_start_boss_minigame()


func _setup_reward_data() -> void:
	var chosen_fish: Dictionary = FishData.BOSS_ID[BOSS_FISH_ID]
	_current_name = chosen_fish.get("name", "")
	_current_image = chosen_fish.get("image", null)
	_current_weight = chosen_fish.get("weight", 0.0)
	_current_value = chosen_fish.get("value", 0.0)
	_current_description = chosen_fish.get("description", "")


func _setup_stamina_ui() -> void:
	_player_stamina_bar.max_value = PLAYER_STAMINA_MAX
	_boss_stamina_bar.max_value = BOSS_STAMINA_MAX
	
	_player_stamina = PLAYER_STAMINA_MAX
	_boss_stamina = BOSS_STAMINA_MAX
	
	_refresh_stamina_ui()


func _refresh_stamina_ui() -> void:
	_player_stamina_bar.value = _player_stamina
	_boss_stamina_bar.value = _boss_stamina
	
	_player_stamina_label.text = "Player Stamina: %d / %d" % [int(round(_player_stamina)), int(PLAYER_STAMINA_MAX)]
	_boss_stamina_label.text = "Boss Stamina: %d / %d" % [int(round(_boss_stamina)), int(BOSS_STAMINA_MAX)]


func _play_startup_sequence() -> void:
	set_process(false)
	set_process_input(false)
	_between_rows = true
	_arrow_container.clear_arrows()
	
	if _animation_player and _animation_player.has_animation("start_up"):
		if _animation_player.has_animation("RESET"):
			_animation_player.play("RESET")
			_animation_player.advance(0.0)
		
		_animation_player.play("start_up")
		await _animation_player.animation_finished
	
	_refresh_stamina_ui()


func _start_boss_minigame() -> void:
	_spawn_new_row()
	set_process(true)
	set_process_input(true)


func _spawn_new_row() -> void:
	_between_rows = false
	_input_index = 0
	_row_data.clear()
	_arrow_container.clear_arrows()
	
	var row_length: int = _rng.randi_range(ROW_LENGTH_MIN, ROW_LENGTH_MAX)
	
	for i in row_length:
		var row_entry: Dictionary = _build_random_row_entry()
		_row_data.append(row_entry)
		
		var arrow_child: Arrow = _arrow_scene.instantiate()
		arrow_child.direction = row_entry["direction_enum"]
		arrow_child.arrow_type = row_entry["arrow_type"]
		_arrow_container.add_arrow(arrow_child)
	
	_arrow_container.current_arrow_index = 0
	AudioEngine.play_sfx(_sfx_round_start)


func _build_random_row_entry() -> Dictionary:
	var direction_enum: Arrow.Directions = _pick_random_direction()
	var expected_input: String = _direction_to_string(direction_enum)
	var arrow_type: Arrow.ArrowType = _pick_random_arrow_type()
	
	return {
		"direction_enum": direction_enum,
		"expected_input": expected_input,
		"arrow_type": arrow_type
	}


func _pick_random_direction() -> Arrow.Directions:
	var directions: Array[Arrow.Directions] = [
		Arrow.Directions.LEFT,
		Arrow.Directions.UP,
		Arrow.Directions.DOWN,
		Arrow.Directions.RIGHT
	]
	return directions[_rng.randi_range(0, directions.size() - 1)]


func _direction_to_string(direction: Arrow.Directions) -> String:
	match direction:
		Arrow.Directions.LEFT: return "Left"
		Arrow.Directions.UP: return "Up"
		Arrow.Directions.DOWN: return "Down"
		Arrow.Directions.RIGHT: return "Right"
	
	return ""


func _pick_random_arrow_type() -> Arrow.ArrowType:
	var roll: float = _rng.randf()
	
	if roll < 0.20: return Arrow.ArrowType.EVIL
	elif roll < 0.25: return Arrow.ArrowType.HEALING
	
	return Arrow.ArrowType.NORMAL


func _input(event: InputEvent) -> void:
	if _cleared:
		if event is InputEventMouseMotion: return
		if _delay:
			get_viewport().set_input_as_handled()
			_return_to_fishing()
		return
	
	if Input.is_action_just_pressed("mouse_click") :
		_win()
	
	if _between_rows: return
	
	var player_input: String = _read_direction_input()
	if player_input == "": return
	
	if _input_index < 0 or _input_index >= _row_data.size(): return
	
	var expected_input: String = _row_data[_input_index]["expected_input"]
	
	if player_input == expected_input: _on_correct_input()
	else: _on_incorrect_input()


func _read_direction_input() -> String:
	if Input.is_action_just_pressed("up"): return "Up"
	if Input.is_action_just_pressed("down"): return "Down"
	if Input.is_action_just_pressed("left"): return "Left"
	if Input.is_action_just_pressed("right"): return "Right"
	
	return ""


func _on_correct_input() -> void:
	var arrow_type: Arrow.ArrowType = _row_data[_input_index]["arrow_type"]
	
	_arrow_container.correct_arrow(_input_index)
	_input_index += 1
	_arrow_container.current_arrow_index = _input_index
	
	var boss_damage: float = BASE_BOSS_DAMAGE
	
	match arrow_type:
		Arrow.ArrowType.EVIL:
			boss_damage *= EVIL_ARROW_DAMAGE_MULTIPLIER
		Arrow.ArrowType.HEALING:
			_adjust_player_stamina(HEALING_ARROW_HEAL)
	
	_adjust_boss_stamina(-boss_damage, true)
	AudioEngine.play_sfx(_sfx_success_arrow)
	
	if _boss_stamina <= 0.0:
		_win()
		return
	
	if _input_index >= _row_data.size():
		_on_row_cleared()


func _on_incorrect_input() -> void:
	_arrow_container.incorrect_arrow(_input_index)
	_adjust_player_stamina(-WRONG_INPUT_PLAYER_DAMAGE, true)
	
	if _player_stamina <= 0.0:
		_fail()
		return
	
	AudioEngine.play_sfx(_sfx_wrong_arrow)
	set_process_input(false)
	await get_tree().create_timer(INPUT_LOCKOUT_SECONDS).timeout
	
	if !_cleared: set_process_input(true)


func _on_row_cleared() -> void:
	_between_rows = true
	
	_adjust_player_stamina(ROW_CLEAR_PLAYER_HEAL)
	_adjust_boss_stamina(-ROW_CLEAR_BOSS_DAMAGE, true)
	
	if _boss_stamina <= 0.0:
		_win()
		return
	
	await get_tree().create_timer(NEXT_ROW_DELAY_SECONDS).timeout
	
	if !_cleared: _spawn_new_row()


func _adjust_player_stamina(amount: float, shake_on_loss: bool = false) -> void:
	var old_value: float = _player_stamina
	_player_stamina = clamp(_player_stamina + amount, 0.0, PLAYER_STAMINA_MAX)
	_refresh_stamina_ui()
	
	if shake_on_loss and _player_stamina < old_value:
		_shake_bar(_player_stamina_bar)


func _adjust_boss_stamina(amount: float, shake_on_loss: bool = false) -> void:
	var old_value: float = _boss_stamina
	_boss_stamina = clamp(_boss_stamina + amount, 0.0, BOSS_STAMINA_MAX)
	_refresh_stamina_ui()
	
	if shake_on_loss and _boss_stamina < old_value:
		_shake_bar(_boss_stamina_bar)


func _shake_bar(bar: Control) -> void:
	if !is_instance_valid(bar): return
	
	var base_position: Vector2 = bar.position
	
	if bar.has_meta("shake_tween"):
		var old_tween = bar.get_meta("shake_tween") as Tween
		if old_tween: old_tween.kill()
	
	bar.position = base_position
	
	var tween: Tween = create_tween()
	bar.set_meta("shake_tween", tween)
	tween.tween_property(bar, "position:x", base_position.x - BAR_SHAKE_DISTANCE, BAR_SHAKE_STEP_TIME)
	tween.tween_property(bar, "position:x", base_position.x + BAR_SHAKE_DISTANCE, BAR_SHAKE_STEP_TIME * 2.0)
	tween.tween_property(bar, "position:x", base_position.x, BAR_SHAKE_STEP_TIME)


func _process(delta: float) -> void:
	if _cleared: return
	
	_adjust_player_stamina(-PLAYER_PASSIVE_DRAIN_PER_SEC * delta)
	_adjust_boss_stamina(BOSS_PASSIVE_REGEN_PER_SEC * delta)
	
	if _player_stamina <= 0.0:
		_fail()
		return
	
	if _boss_stamina <= 0.0:
		_win()
		return
	
	if !AudioEngine.is_sfx_key_stream_playing(_sfx_struggle): AudioEngine.play_sfx(_sfx_struggle)


func _win() -> void:
	set_process(false)
	set_process_input(false)
	_cleared = true
	
	_arrow_container.hide()
	AudioEngine.stop_all_sfx()
	AudioEngine.play_sfx(_sfx_fish_caught)
	
	SystemData.boss_defeated = true
	
	$ReactionAnimation.visible = true
	$ReactionAnimation.play("joel")
	
	var payout: float = _current_value
	
	if _distance > 0.0:
		var distance_multiplier: float = pow(2.0, log(_distance / 100.0) / log(10.0))
		payout *= distance_multiplier
	
	payout *= SystemData.value_multiplier
	
	_results_window.set_text("Boss Fish Caught !!\n%s\nWeight: %.2f\nValue: %.2f\n%s" % [
		_current_name,
		_current_weight,
		payout,
		_current_description
	])
	_results_window.show()
	
	SystemData._add_money_delay(payout)
	SystemData._add_fish(BOSS_FISH_ID)
	
	_prep_return_to_fishing()


func _fail() -> void:
	set_process(false)
	set_process_input(false)
	_cleared = true
	
	_arrow_container.hide()
	AudioEngine.stop_all_sfx()
	AudioEngine.play_sfx(_sfx_fail)
	
	_results_window.set_text("The boss fish got away !!")
	_results_window.show()
	
	_prep_return_to_fishing()


func _prep_return_to_fishing() -> void:
	await get_tree().create_timer(1.0).timeout
	_set_continue_visible(true)
	set_process_input(true)
	_delay = true


func _return_to_fishing() -> void:
	if !is_inside_tree() or is_queued_for_deletion(): return
	
	_suppress_player_input()
	
	PlayManager.request_catching_state()
	AudioEngine.stop_all_sfx()
	PlayManager.request_idle_day_state()
	GameManager.popup_queue.dismiss_popup()


func _suppress_player_input() -> void:
	var scene_container: Control = GameManager.get_scene_container()
	if scene_container.get_child_count() <= 0:
		return
	
	var active_scene = scene_container.get_child(0)
	if active_scene is DaytimeMain and active_scene.jeremy_node:
		active_scene.jeremy_node.suppress_input_until_release()


## Sets the continue UI element visibility.
func _set_continue_visible(visible_value: bool) -> void:
	if _continue_indicator: _continue_indicator.visible = visible_value
