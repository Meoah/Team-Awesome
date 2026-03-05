extends Control
class_name DaytimeMain

## Audio exports
@export_category("Audio")
@export var default_bgm : AudioStream

## Node exports
@export_category("Children Nodes")
@export var jeremy_node : MainCharacter
@export var bobber_scene : PackedScene
@export var camera : Camera2D

func _ready() -> void:
	PlayManager.request_idle_day_state()
	
	if SystemData.get_day() == 1 && SystemData.get_week() == 1 : _intro_scene()
	
	# Binds Signals
	PlayManager.idle_day_state.signal_idle_day.connect(_idle_state)
	
	AudioEngine.play_bgm(default_bgm)

func _intro_scene() -> void:
	$TutorialSequence.visible = true
	SystemData._add_bait(1, 5)
	SystemData.set_active_bait(1)

func is_can_fish() -> bool:
	for each in SystemData.bait_inventory:
		if SystemData.bait_inventory[each] != 0:
			return true
	return false


var current_position : int = 1

const positions : Dictionary = {
	1 : Vector2(640.0,360),
	2 : Vector2(349,512.0),
	3 : Vector2(349,512.0),
	4 : Vector2(676,202.0),
	5 : Vector2(1040,598.0),
	6 : Vector2(640.0,360),

}

func advance_position():
	$TutorialSequence.global_position = positions[current_position]
	if current_position <= 5:
		current_position += 1


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_click"):
		advance_position()










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

func _on_debug_pressed() -> void:
	var popup_parameters = {
		"dialogue_id" = 0,
		"flags" = BasePopup.POPUP_FLAG.DISMISS_ON_ESCAPE
	}
	if PlayManager.request_dialogue_day_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.DIALOGUE, popup_parameters)
