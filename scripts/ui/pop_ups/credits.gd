extends BasePopup
class_name CreditsPopup


@export var hover_sfx: AudioStream
@export var cancel_sfx : AudioStream


func _on_init() -> void:
	type = POPUP_TYPE.CREDITS
	flags = POPUP_FLAG.DISMISS_ON_ESCAPE
	bg_opacity = 0.82


func _on_texture_button_pressed() -> void:
	AudioEngine.play_sfx(cancel_sfx)
	GameManager.dismiss_popup()


func _on_texture_button_mouse_entered() -> void:
	AudioEngine.play_sfx(hover_sfx)
