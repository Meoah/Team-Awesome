extends BasePopup
class_name WinnerPopup

@export_category("Audio")
@export var default_bgm: AudioStream
@export var hover_sfx: AudioStream
@export var cancel_sfx: AudioStream
@export var confirm_sfx: AudioStream

@export_category("Children Nodes")
@export var content_label: RichTextLabel

var _callback_bgm_key : String = ""

func _on_init() -> void:
	type = POPUP_TYPE.SETTINGS
	bg_opacity = 0.82

func _on_ready() -> void:
	_callback_bgm_key = AudioEngine.get_active_bgm_key()
	AudioEngine.play_bgm(default_bgm)
	
	SystemData.winner_screen_shown = true
	
	content_label.clear()
	match SystemData.license:
		1:
			content_label.append_text("You've made enough money to pay back your license![br][br]")
			content_label.append_text("This is the end of the tutorial stage for now,[br]but you may continue if you wish.[br][br]")
			content_label.append_text("Consider checking out the other licenses!")
		2:
			content_label.append_text("You've made enough money to pay back your license![br][br]")
			content_label.append_text("This is the end of a standard run, in the full game you'll be able[br]to head back to town with rewards![br][br]")
			content_label.append_text("Now that you've tried out the standard run,[br]why not experience the boss run?")
		3:
			content_label.append_text("[shake rate=20.0 level=5 connected=1]Wow![/shake] You've managed to catch that behemoth!![br][br]")
			content_label.append_text("This is the end of the boss run. In the full game,[br] this would be a major unlock in the main storyline.[br][br]")
			content_label.append_text("Thank you so much for playing!!")


func _on_back_pressed() -> void:
	if GameManager.request_main_menu():
		AudioEngine.play_sfx(cancel_sfx)
		GameManager.clear_popup_queue()
		GameManager.change_scene_deferred(GameManager.main_menu_scene)


func _on_continue_pressed() -> void:
	AudioEngine.play_sfx(confirm_sfx)
	GameManager.dismiss_popup()


func _on_button_mouse_entered() -> void:
	AudioEngine.play_sfx(hover_sfx)


func on_after_dismiss() -> void:
	AudioEngine.play_bgm_saved_key(_callback_bgm_key)
