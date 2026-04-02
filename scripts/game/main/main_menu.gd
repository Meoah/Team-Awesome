extends Control

@export_category("Audio")
@export var default_bgm : AudioStream
@export var hover_sfx : AudioStream
@export var confirm_sfx : AudioStream
@export var cancel_sfx : AudioStream

@export_category("Children Nodes")
@export var blocker : ColorRect
@export var fade_node: ColorRect
@export var animation_player : AnimationPlayer
@export var button_play : TextureButton
@export var button_settings : TextureButton
@export var button_quit : TextureButton

func _ready():
	# Disables the quit button entirely if it's on web since that just crashes the game if clicked.
	if OS.has_feature("web") : button_quit.visible = false
	AudioEngine.play_bgm(default_bgm)


func _on_start_pressed():
	AudioEngine.play_sfx(confirm_sfx)
	blocker.visible = true
	animation_player.play("level_select")


var is_starting: bool = false
func _start_game():
	if is_starting : return
	
	is_starting = true
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	var license_level = SystemData.license
	
	match license_level:
		1:
			if GameManager.request_play():
				GameManager.change_scene_deferred(GameManager.intro_scene)
		2, 3:
			if GameManager.request_play():
				GameManager.change_scene_deferred(GameManager.daytime_scene)


func _on_exit_pressed():
	AudioEngine.play_sfx(cancel_sfx)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func _on_animation_player_animation_finished(_anim_name: String) -> void:
	blocker.visible = false


func _on_blocker_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_click") || event.is_action_pressed("action"):
		if !animation_player.is_playing() : return
		
		blocker.visible = false
		
		var is_backwards: bool = animation_player.get_playing_speed() < 0.0
		
		if is_backwards : animation_player.seek(0.0, true)
		else : animation_player.seek(animation_player.current_animation_length, true)


func _on_options_button_pressed() -> void:
	AudioEngine.play_sfx(confirm_sfx)
	GameManager.show_popup(BasePopup.POPUP_TYPE.SETTINGS)


func _on_credits_button_pressed() -> void:
	AudioEngine.play_sfx(confirm_sfx)
	GameManager.show_popup(BasePopup.POPUP_TYPE.CREDITS)


func _on_play_button_mouse_entered() -> void:
	AudioEngine.play_sfx(hover_sfx)
	var shader_material : ShaderMaterial = button_play.material
	shader_material.set_shader_parameter("thickness", 4.0)


func _on_play_button_mouse_exited() -> void:
	var shader_material : ShaderMaterial = button_play.material
	shader_material.set_shader_parameter("thickness", 0.0)


func _on_options_button_mouse_entered() -> void:
	AudioEngine.play_sfx(hover_sfx)
	var shader_material : ShaderMaterial = button_settings.material
	shader_material.set_shader_parameter("thickness", 4.0)


func _on_options_button_mouse_exited() -> void:
	var shader_material : ShaderMaterial = button_settings.material
	shader_material.set_shader_parameter("thickness", 0.0)


func _on_exit_button_mouse_entered() -> void:
	AudioEngine.play_sfx(hover_sfx)
	var shader_material : ShaderMaterial = button_quit.material
	shader_material.set_shader_parameter("thickness", 4.0)


func _on_exit_button_mouse_exited() -> void:
	var shader_material : ShaderMaterial = button_quit.material
	shader_material.set_shader_parameter("thickness", 0.0)


func _on_credits_button_mouse_entered() -> void:
	AudioEngine.play_sfx(hover_sfx)


func _on_generic_button_mouse_entered() -> void:
	AudioEngine.play_sfx(hover_sfx)


func _on_license_one_pressed() -> void:
	SystemData.license = 1
	_start_game()


func _on_license_two_pressed() -> void:
	SystemData.license = 2
	_start_game()


func _on_license_three_pressed() -> void:
	SystemData.license = 3
	_start_game()


func _on_back_pressed() -> void:
	AudioEngine.play_sfx(cancel_sfx)
	blocker.visible = true
	animation_player.play_backwards("level_select")
