extends BasePopup
class_name CreditsPopup

@export var back_button: BaseButton
@export var first_focus_control: Control


func _on_init() -> void:
	type = POPUP_TYPE.CREDITS
	flags = POPUP_FLAG.DISMISS_ON_ESCAPE
	bg_opacity = 0.82


func _on_ready() -> void:
	if first_focus_control:
		first_focus_control.grab_focus()


func _on_texture_button_pressed() -> void:
	GameManager.dismiss_popup()
