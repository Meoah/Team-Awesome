extends Control

@export_category("Audio")
@export var default_bgm : AudioStream

@export_category("Children Nodes")
@export var blocker : ColorRect
@export var animation_player : AnimationPlayer
@export var button_quit : TextureButton


func _ready():
	# Disables the quit button entirely if it's on web since that just crashes the game if clicked.
	if OS.has_feature("web") : button_quit.visible = false
	AudioEngine.play_bgm(default_bgm)


func _on_start_pressed():
	if GameManager.request_play():
		GameManager.change_scene_deferred(GameManager.intro_scene)


func _on_exit_pressed():
	get_tree().quit() #exits out of game


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "startup" : blocker.visible = false


func _on_blocker_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_click") || event.is_action_pressed("action") : animation_player.seek(5.99)


func _on_options_button_pressed() -> void:
	GameManager.show_popup(BasePopup.POPUP_TYPE.SETTINGS)
