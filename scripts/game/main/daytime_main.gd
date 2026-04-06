extends Control
class_name DaytimeMain

@export_category("Audio")
@export var default_bgm : AudioStream

@export_category("Children Nodes")
@export var jeremy_node : MainCharacter
@export var hud : HUD
@export var camera : Camera2D

@export_category("PackedScenes")
@export var bobber_scene : PackedScene
@export var tutorial_scene : PackedScene


func _ready() -> void:
	# Binds Signals
	PlayManager.idle_day_state.signal_idle_day.connect(_idle_state)
	
	# Initial setup
	AudioEngine.play_bgm(default_bgm)
	PlayManager.request_dialogue_day_state()
	if SystemData.fresh_run:
		_equip_license_gear()
	
	
	await hud.fade_in().finished
	await jeremy_node.walk_up_sequence()
	
	# Cutscenes
	if SystemData.fresh_run:
		if SystemData.license == 1 : _intro_scene()
		else: _ready_day()
	else:
		_ready_day()
	
	SystemData.fresh_run = false


## Plays the intro sequence and sets initial bait if first day.
func _intro_scene() -> void:
	PlayManager.request_dialogue_day_state()
	_play_tutorial()

## Instantiates tutorital scene and binds its finished signal to _ready_day()
func _play_tutorial() -> void:
	var new_scene : TutorialSequence = tutorial_scene.instantiate()
	new_scene.tutorial_done.connect(_ready_day)
	add_child(new_scene)

## Default function for the day.
func _ready_day() -> void:
	TimeManager.time_enabled = true
	PlayManager.request_idle_day_state()

func is_can_fish() -> bool:
	for each in SystemData.bait_inventory:
		if SystemData.bait_inventory[each] != 0:
			return true
	return false

func _end_day() -> void:
	if PlayManager.request_idle_night_state():
		GameManager.change_scene_deferred(GameManager.nighttime_scene)

func _play_minigame(distance: float) -> void:
	$FISH.play("FISH!") #Plays FISH! Animation
	await $FISH.animation_finished
	var popup_parameters = {
		"flags" = BasePopup.POPUP_FLAG.WILL_PAUSE,
		"distance" = distance
	}
	GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.MINIGAMEUI, popup_parameters)

func _on_fish_animation_finished(_anim_name: StringName) -> void:
	$FISH.stop(true)
	$FISH.seek(0)

func _idle_state() -> void:
	AudioEngine.play_bgm(default_bgm)

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
