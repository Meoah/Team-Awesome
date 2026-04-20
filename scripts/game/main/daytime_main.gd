extends Control
class_name DaytimeMain

@export_category("Audio")
@export var day_bgm: AudioStream
@export var night_bgm: AudioStream

@export_category("Children Nodes")
@export var jeremy_node: MainCharacter
@export var hud: HUD
@export var camera: Camera2D
@export var boss_shadow: BossShadow

const MAGIC_BAIT_ID: int = 2

const DAY_BGM_START_HOUR: float = 6.0
const NIGHT_BGM_START_HOUR: float = 18.0

@export_category("PackedScenes")
@export var bobber_scene : PackedScene
@export var tutorial_scene : PackedScene


func _ready() -> void: 
	# Binds Signals
	PlayManager.idle_day_state.signal_idle_day.connect(_idle_state)
	TimeManager.time_updated.connect(_on_time_updated)
	
	# Initial setup
	_update_bgm_for_time(TimeManager.current_hour)
	PlayManager.request_dialogue_day_state()
	if SystemData.fresh_run:
		_equip_license_gear()
	
	await hud.fade_in().finished
	
	if _check_loss_condition(): return
	
	await jeremy_node.walk_up_sequence()
	
	# Cutscenes
	if SystemData.fresh_run:
		if SystemData.license == 1 : _intro_scene()
		else: _ready_day()
	else:
		_ready_day()
	
	SystemData.fresh_run = false


func _check_loss_condition() -> bool:
	if SystemData.license == 3:
		return false
	
	var final_day: int = 1 + (SystemData.license * 2)
	if SystemData.get_day() > final_day and SystemData.get_money() < SystemData.calculate_goal():
		SignalBus.player_dies.emit()
		return true
	
	return false


## Plays the intro sequence and sets initial bait if first day.
func _intro_scene() -> void:
	PlayManager.request_dialogue_day_state()
	_play_tutorial()

## Instantiates tutorital scene and binds its finished signal to _ready_day()
func _play_tutorial() -> void:
	var new_scene : TutorialSequence = tutorial_scene.instantiate()
	new_scene.tutorial_done.connect(_ready_day)
	add_child(new_scene)

## Enables normal daytime gameplay.
func _ready_day() -> void:
	TimeManager.time_enabled = true
	PlayManager.request_idle_day_state()
	jeremy_node.suppress_action_until_release()
	jeremy_node.apply_held_movement_input()

func is_can_fish() -> bool:
	for each in SystemData.bait_inventory:
		if SystemData.bait_inventory[each] != 0:
			return true
	return false

func _end_day() -> void:
	TimeManager._advance_time(1.0, true)
	
	if PlayManager.request_idle_night_state():
		GameManager.change_scene_deferred(GameManager.nighttime_scene)


func _on_bobber_landed_in_water(bobber: Bobber) -> void:
	if !is_instance_valid(bobber): return
	
	bobber.encounter_type = Bobber.EncounterType.NORMAL
	
	if SystemData.license != 3: return
	if SystemData.boss_defeated: return
	if bobber.cast_bait_id != MAGIC_BAIT_ID: return
	if !boss_shadow.visible: return
	
	if boss_shadow.contains_bobber(bobber): bobber.encounter_type = Bobber.EncounterType.BOSS

func start_fishing_encounter(encounter_type: Bobber.EncounterType, distance: float) -> void:
	$FISH.play("FISH!")
	await $FISH.animation_finished
	
	var popup_type: BasePopup.POPUP_TYPE = BasePopup.POPUP_TYPE.MINIGAME
	if encounter_type == Bobber.EncounterType.BOSS: popup_type = BasePopup.POPUP_TYPE.BOSS_MINIGAME
	
	var popup_parameters = {
		"flags" = BasePopup.POPUP_FLAG.WILL_PAUSE,
		"_distance" = distance
	}
	
	GameManager.popup_queue.show_popup(popup_type, popup_parameters)


func _on_fish_animation_finished(_anim_name: StringName) -> void:
	$FISH.stop(true)
	$FISH.seek(0)

func _idle_state() -> void:
	_update_bgm_for_time(TimeManager.current_hour)

## Updates the daytime scene BGM based on the current hour.
func _on_time_updated(new_hour: float) -> void:
	_update_bgm_for_time(new_hour)


## Plays the correct daytime-scene BGM for the given hour.
func _update_bgm_for_time(hour: float) -> void:
	var target_bgm: AudioStream = _get_bgm_for_hour(hour)
	if target_bgm:
		AudioEngine.play_bgm(target_bgm, "", false, 2.0)


## Returns the correct daytime-scene BGM for the given hour.
func _get_bgm_for_hour(hour: float) -> AudioStream:
	if hour >= DAY_BGM_START_HOUR and hour < NIGHT_BGM_START_HOUR:
		return day_bgm

	return night_bgm

func _on_exit_sign_body_entered(body: Node2D) -> void:
	if body is MainCharacter : _end_day()

# TODO REMOVE THIS LATER, HARDCODED RUN EQUIPMENT
func _equip_license_gear() -> void:
	match SystemData.license:
		1:
			pass
		2:
			SystemData.set_upgrade(ItemData.ROD, ItemData.get_data(ItemData.ROD, 1))
			SystemData.set_upgrade(ItemData.REEL, ItemData.get_data(ItemData.REEL, 2))
			SystemData.set_upgrade(ItemData.EXOTIC, ItemData.get_data(ItemData.EXOTIC, 2))
		3:
			SystemData.set_upgrade(ItemData.ROD, ItemData.get_data(ItemData.ROD, 2))
			SystemData.set_upgrade(ItemData.LURE, ItemData.get_data(ItemData.LURE, 1))
			SystemData.set_upgrade(ItemData.EXOTIC, ItemData.get_data(ItemData.EXOTIC, 3))
