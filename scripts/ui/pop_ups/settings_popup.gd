extends BasePopup
class_name SettingsPopup

@export_category("Audio")
@export var cancel_sfx : AudioStream

@export var back_button: BaseButton
@export var first_focus_control: Control

func _on_init() -> void:
	type = POPUP_TYPE.SETTINGS
	flags = POPUP_FLAG.DISMISS_ON_ESCAPE
	bg_opacity = 0.82

func _on_ready() -> void:
	if first_focus_control:
		first_focus_control.grab_focus()

func _on_back_pressed() -> void:
	AudioEngine.play_sfx(cancel_sfx)
	GameManager.dismiss_popup()

func on_after_show() -> void:
	if first_focus_control:
		first_focus_control.grab_focus()
