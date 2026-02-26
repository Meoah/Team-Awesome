extends Control
class_name GameOver

func _ready() -> void:
	visible = false
	SignalBus.player_dies.connect(_dead)

func _dead() -> void:
	PlayManager.request_dead_state()
	visible = true

func _on_ded_pressed():
	SystemData._reset_all()
	GameManager.request_main_menu()
