extends BasePopup
class_name PausePopup

@export_category("Audio")
@export var default_bgm : AudioStream
@export var hover_sfx: AudioStream
@export var confirm_sfx: AudioStream
@export var cancel_sfx: AudioStream

@export_category("Children Nodes")
@export var resume_button: BaseButton

var _callback_bgm_key : String = ""

func _on_init() -> void:
	type = POPUP_TYPE.PAUSE
	flags = POPUP_FLAG.WILL_PAUSE | POPUP_FLAG.DISMISS_ON_ESCAPE
	bg_opacity = 0.82

func _on_ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_callback_bgm_key = AudioEngine.get_active_bgm_key()
	AudioEngine.play_bgm(default_bgm)
	if resume_button : resume_button.grab_focus()

func on_after_dismiss() -> void:
	AudioEngine.play_bgm_saved_key(_callback_bgm_key)

func _on_resume_pressed() -> void:
	AudioEngine.play_sfx(cancel_sfx)
	GameManager.dismiss_popup()

func _on_settings_pressed() -> void:
	AudioEngine.play_sfx(confirm_sfx)
	GameManager.show_popup(BasePopup.POPUP_TYPE.SETTINGS)

func _on_main_menu_pressed() -> void:
	if GameManager.request_main_menu():
		AudioEngine.play_sfx(cancel_sfx)
		GameManager.clear_popup_queue()
		GameManager.change_scene_deferred(GameManager.main_menu_scene)

func _on_button_mouse_entered() -> void:
	AudioEngine.play_sfx(hover_sfx)
