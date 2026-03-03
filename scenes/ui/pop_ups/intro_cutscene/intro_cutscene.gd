extends Control





func _ready() -> void:
	PlayManager.idle_day_state.signal_idle_day.connect(play_animation)




func play_animation():
		$AnimationPlayer.play("intro_sequence")





func _on_button_button_down() -> void:
	var popup_parameters = {
	"dialogue_id" = 0000,
	"flags" = BasePopup.POPUP_FLAG.DISMISS_ON_ESCAPE
	}
	if PlayManager.request_dialogue_day_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.DIALOGUE, popup_parameters) # Replace with function body.
