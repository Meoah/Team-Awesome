extends Control
class_name DaytimeMain

## Audio exports
@export_file_path("*.wav") var default_bgm_path

## Node exports
@export var jeremy_node : MainCharacter
@export var bobber_scene : PackedScene

func _ready() -> void:
	PlayManager.request_idle_day_state()
	
	if SystemData.get_day() == 1 && SystemData.get_week() == 1:
		SystemData._add_bait("Generic Bait", 5)
	
	# Binds Signals
	PlayManager.idle_day_state.signal_idle_day.connect(_idle_state)
	
	AudioEngine.play_bgm(default_bgm_path)

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
	AudioEngine.play_bgm(default_bgm_path)

func _on_button_pressed():
	_end_day()

func _on_debug_pressed() -> void:
	var popup_parameters = {
		"dialogue_id" = 0,
		"flags" = BasePopup.POPUP_FLAG.DISMISS_ON_ESCAPE
	}
	if PlayManager.request_dialogue_day_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.DIALOGUE, popup_parameters)
