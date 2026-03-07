extends BasePopup
class_name PausePopup

@export var resume_button: BaseButton

func _on_init() -> void:
	type = POPUP_TYPE.PAUSE
	flags = POPUP_FLAG.WILL_PAUSE | POPUP_FLAG.DISMISS_ON_ESCAPE
	bg_opacity = 0.82

func _on_ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	if resume_button:
		resume_button.grab_focus()

func _on_resume_pressed() -> void:
	GameManager.dismiss_popup()

func _on_settings_pressed() -> void:
	GameManager.show_popup(BasePopup.POPUP_TYPE.SETTINGS)

func _on_main_menu_pressed() -> void:
	if GameManager.request_main_menu():
		GameManager.clear_popup_queue()
		GameManager.change_scene_deferred(GameManager.main_menu_scene)
