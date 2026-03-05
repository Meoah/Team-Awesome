extends Control



@export var next_scene : PackedScene


func _ready() -> void:
	PlayManager.request_idle_day_state()
	SignalBus.run_intro.connect(play_animation)
	var popup_parameters = {
<<<<<<< HEAD
	"dialogue_id" = 0001,
=======
	"dialogue_id" = 0000,
>>>>>>> 69fa1fb8799a8313aef9dcb175195a758598b0b8
	"flags" = BasePopup.POPUP_FLAG.DISMISS_ON_ESCAPE
	}
	if PlayManager.request_dialogue_day_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.DIALOGUE, popup_parameters)

func play_animation():
		$AnimationPlayer.play("intro_sequence")


<<<<<<< HEAD
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_click"):
		$AnimationPlayer.seek(19.5)


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
=======
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
>>>>>>> 69fa1fb8799a8313aef9dcb175195a758598b0b8
	GameManager.change_scene_deferred(next_scene)
