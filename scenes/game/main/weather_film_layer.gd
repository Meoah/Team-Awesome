extends CanvasLayer

@onready var color_rect : ColorRect = $ColorRect
var shader_material : ShaderMaterial

# Current blend
var current := { "clear": 1.0, "cloudy": 0.0, "rain": 0.0,
				 "storm": 0.0, "fog": 0.0, "windy": 0.0 }

# Target blend
var target := { "clear": 1.0, "cloudy": 0.0, "rain": 0.0,
				"storm": 0.0, "fog": 0.0, "windy": 0.0 }

const BLEND_SPEED : float = 0.8 

func _ready() -> void:
	layer = 100  # Always on top
	shader_material = color_rect.material as ShaderMaterial
	# Connect to WeatherManager when it's ready
	if WeatherManager:
		WeatherManager.weather_changed.connect(_on_weather_changed)

func _process(delta: float) -> void:
	var changed := false
	for key in current:
		var prev : float = current[key]
		current[key] = move_toward(current[key], target[key], BLEND_SPEED * delta)
		if current[key] != prev:
			changed = true
	if changed:
		_push_to_shader()

func _on_weather_changed(weather : WeatherManager.WEATHER) -> void:
	# Zero everything out, then set the target
	for key in target:
		target[key] = 0.0
	match weather:
		WeatherManager.WEATHER.CLEAR:   target["clear"]  = 1.0
		WeatherManager.WEATHER.CLOUDY:  target["cloudy"] = 1.0
		WeatherManager.WEATHER.RAINY:   target["rain"]   = 1.0
		WeatherManager.WEATHER.STORMY:  target["storm"]  = 1.0
		WeatherManager.WEATHER.FOGGY:   target["fog"]    = 1.0
		WeatherManager.WEATHER.WINDY:   target["windy"]  = 1.0

func _push_to_shader() -> void:
	shader_material.set_shader_parameter("blend_clear",  current["clear"])
	shader_material.set_shader_parameter("blend_cloudy", current["cloudy"])
	shader_material.set_shader_parameter("blend_rain",   current["rain"])
	shader_material.set_shader_parameter("blend_storm",  current["storm"])
	shader_material.set_shader_parameter("blend_fog",    current["fog"])
	shader_material.set_shader_parameter("blend_windy",  current["windy"])
