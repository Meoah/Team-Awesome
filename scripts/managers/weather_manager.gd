extends Node

enum WEATHER {CLEAR, RAINY} #May add STORM later.

var current_weather : WEATHER = WEATHER.CLEAR

signal weather_changed(new_weather : WEATHER)

func _ready() -> void:
	_roll_weather()
	
func set_weather(new_weather : WEATHER) -> void:
	if current_weather == new_weather:
		return
	current_weather = new_weather
	weather_changed.emit(current_weather)

func _roll_weather() -> void:
	set_weather(
		[WEATHER.CLEAR,
		WEATHER.RAINY].pick_random()
	)
