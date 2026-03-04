extends Control



@export var next_scene : PackedScene


func _ready() -> void:
	PlayManager.request_idle_day_state()
	SignalBus.run_intro.connect(play_animation)
	var popup_parameters = {
	"dialogue_id" = 0000,
	"flags" = BasePopup.POPUP_FLAG.DISMISS_ON_ESCAPE
	}
	if PlayManager.request_dialogue_day_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.DIALOGUE, popup_parameters)

func play_animation():
		$AnimationPlayer.play("intro_sequence")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	GameManager.change_scene_deferred(next_scene)
