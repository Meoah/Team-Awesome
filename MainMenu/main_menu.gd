extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_pressed():
	get_tree().change_scene_to_file("res://vro.tscn") #starts game


func _on_settings_pressed():
	print("Settings Pressed")


func _on_exit_pressed():
	get_tree().quit() #exits out of game
	
