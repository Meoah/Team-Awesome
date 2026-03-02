extends Control

@export_category("Audio")
@export var default_bgm : AudioStream

@onready var main_buttons = $MainButtons
@onready var settings = $Settings
@onready var gameStart

# Called when the node enters the scene tree for the first time.
func _ready():
	main_buttons.visible = true
	settings.visible = false
	AudioEngine.play_bgm(default_bgm)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_start_pressed():
	if GameManager.request_play():
		GameManager.change_scene_deferred(GameManager.daytime_scene)


func _on_settings_pressed():
	print("Settings Pressed")
	main_buttons.visible = false
	settings.visible = true
	

func _on_exit_pressed():
	get_tree().quit() #exits out of game
	


func _on_backbutton_pressed():
	_ready()
