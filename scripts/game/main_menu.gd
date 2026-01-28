extends Control

@onready var main_buttons = $MainButtons
@onready var settings = $Settings
@onready var gameStart


# Called when the node enters the scene tree for the first time.
func _ready():
	main_buttons.visible = true
	settings.visible = false
	$AudioStreamPlayer.play(65)


func _on_start_pressed():
	get_tree().change_scene_to_file("res://vro.tscn") #starts game


func _on_settings_pressed():
	print("Settings Pressed")
	main_buttons.visible = false
	settings.visible = true
	

func _on_exit_pressed():
	get_tree().quit() #exits out of game
	


func _on_backbutton_pressed():
	_ready()
