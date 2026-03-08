extends Control
class_name GameOver

@export_category("Audio")
@export var default_bgm : AudioStream

func _ready() -> void:
	AudioEngine.play_bgm(default_bgm)

func _on_ded_pressed():
	SystemData._reset_all()
	GameManager.request_main_menu()
