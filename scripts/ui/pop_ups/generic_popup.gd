class_name GenericPopup
extends BasePopup

func _on_init() -> void:
	type = POPUP_TYPE.GENERIC

func _on_exit_pressed():
	GameManager.popup_queue.dismiss_popup()
