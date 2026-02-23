class_name DialoguePopup
extends BasePopup

func _on_init() -> void:
	type = POPUP_TYPE.DIALOGUE

func _on_exit_pressed():
	GameManager.popup_queue.dismiss_popup()
