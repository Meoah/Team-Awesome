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
	var roll = randf_range(0.0, 100.0)
	
	# Ensure morning does not start with rain
	if TimeManager.current_hour < 9.0:
		set_weather(WEATHER.CLEAR)
		return
		
	#Only rolls rain 20% of the time, leaving 80% chance of clear weather
	if roll < 20.0:
		set_weather(WEATHER.RAINY)
	else:
		set_weather(WEATHER.CLEAR)
