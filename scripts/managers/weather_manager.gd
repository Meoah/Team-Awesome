extends Node

enum WEATHER {CLEAR, STORM, RAINY}

var current_weather : WEATHER = WEATHER.CLEAR

signal weather_changed(new_weather : WEATHER)

func set_weather(new_weather : WEATHER) -> void:
	if current_weather == new_weather:
		return
	current_weather = new_weather
	weather_changed.emit(current_weather)

func _roll_daily_weather() -> void:
	set_weather(
		[WEATHER.CLEAR,
		 WEATHER.RAINY,
		 WEATHER.STORM].pick_random()
	)
