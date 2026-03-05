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
	await hud.fade_in().finished
	await _walk_up_sequence().finished
	
	if SystemData.get_day() == 1 && SystemData.get_week() == 1 : _intro_scene()
	else : _ready_day()

## Plays the intro sequence and sets initial bait if first day.
func _intro_scene() -> void:
	PlayManager.request_dialogue_day_state()
	_play_tutorial()
	SystemData._add_bait(1, 5)
	SystemData.set_active_bait(1)

## Instantiates tutorital scene and binds its finished signal to _ready_day()
func _play_tutorial() -> void:
	var new_scene : TutorialSequence = tutorial_scene.instantiate()
	new_scene.tutorial_done.connect(_ready_day)
	add_child(new_scene)

## Default function for the day.
func _ready_day() -> void:
	PlayManager.request_idle_day_state()

## Returns a tween for awaiting .finished.
## TODO maybe put this into Jeremy instead
func _walk_up_sequence() -> Tween:
	var tween := create_tween()
	tween.tween_property(jeremy_node, "global_position:x", 350.0, 1.0)
	return tween

func is_can_fish() -> bool:
	for each in SystemData.bait_inventory:
		if SystemData.bait_inventory[each] != 0:
			return true
	return false

func _end_day() -> void:
	if PlayManager.request_idle_night_state():
		GameManager.change_scene_deferred(GameManager.nighttime_scene)

func _play_minigame() -> void:
	$FISH.play("FISH!") #Plays FISH! Animation
	await $FISH.animation_finished
	var popup_parameters = {
		"flags" = BasePopup.POPUP_FLAG.WILL_PAUSE
	}
	GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.MINIGAMEUI, popup_parameters)

func _on_fish_animation_finished(_anim_name: StringName) -> void:
	$FISH.stop(true)
	$FISH.seek(0)

func _idle_state() -> void:
	AudioEngine.play_bgm(default_bgm)

func _on_button_pressed():
	_end_day()
