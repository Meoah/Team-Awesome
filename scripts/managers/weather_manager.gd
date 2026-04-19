extends Node

enum WEATHER {CLEAR, CLOUDY, RAINY, STORMY, FOGGY, WINDY} 

var current_weather : WEATHER = WEATHER.CLEAR
var wind_strength   : float   = 0.0

signal weather_changed(new_weather : WEATHER)

 
func set_weather(new_weather : WEATHER) -> void:
	if current_weather == new_weather:
		return
	current_weather = new_weather
	weather_changed.emit(current_weather)

func _roll_daily_weather() -> void:
	var weights := {
		WEATHER.CLEAR:  40,
		WEATHER.CLOUDY: 25,
		WEATHER.RAINY:  18,
		WEATHER.STORMY:  70,
		WEATHER.FOGGY:   5,
		WEATHER.WINDY:   5,
	}
	current_weather = weight_random(weights)
	wind_strength = randf_range(0.3, 1.0 ) if current_weather == WEATHER.WINDY\
					else(randf_range(0.0, 0.3) if current_weather == WEATHER.STORMY\
					else 0.0)
	weather_changed.emit(current_weather)
					
	# Ensure morning does not start with rain
	if TimeManager.current_hour < 9.0:
		set_weather(WEATHER.CLEAR)
		return
		
func weight_random(weights : Dictionary) -> WEATHER:
	var total := 0
	for w in weights.values() : total += w
	var roll := randi() % total
	var cumulative :=0
	for type in weights:
		cumulative += weights[type]
		if roll < cumulative : return type
	return WEATHER.CLEAR

func _roll_weather() -> void:
	_roll_daily_weather()                
