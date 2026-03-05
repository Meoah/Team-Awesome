extends Control
class_name GameOver

func _on_ded_pressed():
	SystemData._reset_all()
	GameManager.request_main_menu()
