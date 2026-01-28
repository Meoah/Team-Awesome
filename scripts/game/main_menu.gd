extends Control
@onready var main_buttons = $MainButtons
@onready var settings = $Settings
@onready var gameStart

@export_file  ("*.tscn") var start_scene_path: String 
# Called when the node enters the scene tree for the first time.
func _ready():
	main_buttons.visible = true
	settings.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_pressed():
	get_tree().change_scene_to_file(start_scene_path) #starts game


func _on_settings_pressed():
	print("Settings Pressed")
	main_buttons.visible = false
	settings.visible = true
	

func _on_exit_pressed():
	get_tree().quit() #exits out of game
	


func _on_backbutton_pressed():
	_ready()
