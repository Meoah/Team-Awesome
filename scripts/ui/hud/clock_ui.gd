extends Control

@onready var clock_face: Sprite2D = $ClockFace
@onready var clock_hand: Sprite2D = $ClockHand
@onready var weather: ColorRect = $WeatherModulate
@onready var rain: GPUParticles2D = $RainLayer/RainParticles
@onready var time_label: Label = $Label

var time_color: Color = Color.WHITE
var weather_color: Color = Color.WHITE
var last_weather_roll: int = -1
var _weather_tween: Tween

const DEGREES_PER_HOUR: float = 15.0
const ROTATION_OFFSET: float = 45.0

var target_rotation: float = 0.0
var smooth_speed: float = 1.0


func _ready() -> void:
	#--Time--
	TimeManager.time_updated.connect(_on_time_updated)
	WeatherManager.weather_changed.connect(_on_weather_changed)
	
	if not TimeManager.initialized: TimeManager._reset_clock(6.0)
	
	TimeManager.time_enabled = false
	last_weather_roll = int(TimeManager.current_hour)
	
	#--Weather--
	_apply_weather(WeatherManager.current_weather)
	_update_lighting(TimeManager.current_hour)	
	
	var start_rotation: float = _hour_to_rotation(TimeManager.current_hour)# * DEGREES_PER_HOUR)
	clock_face.rotation = start_rotation
	target_rotation = start_rotation


func _process(delta: float) -> void:
	clock_face.rotation = lerp_angle(
		clock_face.rotation,
		target_rotation,
		smooth_speed * delta
	)


func _hour_to_rotation(hour : float) -> float:
	return deg_to_rad(-((hour * DEGREES_PER_HOUR) - ROTATION_OFFSET))


func _on_time_updated(hour : float) -> void:
	target_rotation = _hour_to_rotation(hour)# * DEGREES_PER_HOUR)
	_update_lighting(hour)
	
	#--Roll weather every 3 hours
	var int_hour: int = int(hour)
	if int_hour % 3 == 0 and int_hour != last_weather_roll:
		last_weather_roll = int_hour
		WeatherManager._roll_weather()


func _update_lighting(hour: float, immediate: bool = false) -> void:
	if hour >= 6.0 and hour < 9.0:
		var t: float = (hour - 6.0) / 3.0
		time_color = Color(1.0, lerp(0.6, 1.0, t), lerp(0.9, 1.0, t), 0.25)
	
	elif hour >= 9.0 and hour < 13.0:
		var t: float = (hour - 9.0) / 4.0
		time_color = Color(1.0, lerp(0.85, 0.95, t), lerp(0.6, 0.7, t), 0.25)
	
	elif hour >= 13.0 and hour < 18.0:
		time_color = Color(1.0, 1.0, 1.0, 0.25)
	
	elif hour >= 18.0 and hour < 21.0:
		var t: float = (hour - 18.0) / 3.0
		time_color = Color(lerp(0.6, 0.2, t), lerp(0.4, 0.2, t), lerp(0.5, 0.4, t), 0.25)
	
	else:
		time_color = Color(0.15, 0.15, 0.25, 0.25)
		print("_update_lighting called | hour: ", hour,
			"time_color before: ", time_color)
	
	_apply_combined_color(immediate)


# Weather-------	
func _on_weather_changed(new_weather : WeatherManager.WEATHER) -> void:
	_apply_weather(new_weather)


func _apply_weather(w: WeatherManager.WEATHER, immediate: bool = false) -> void:
	
	match w:
		WeatherManager.WEATHER.CLEAR:
			weather_color = Color(1.0, 1.0, 1.0)
			rain.emitting = false
		WeatherManager.WEATHER.RAINY:
			weather_color = Color(0.6, 0.7, 0.9)
			rain.emitting = true
		#WeatherManager.WEATHER.STORM:
			#weather_color = Color(0.4, 0.4, 0.55)
			#rain.emitting = true
			
	_apply_combined_color(immediate)
	print("_apply_weather called | weather: ",w,
	" | weather_color before: ", weather_color)	              


#Combines weather and lighting
func _apply_combined_color(immediate: bool = false) -> void:
	var target: Color = time_color * weather_color
	
	if _weather_tween:
		_weather_tween.kill()
	
	if immediate:
		weather.color = target
	else:
		_weather_tween = create_tween()
		_weather_tween.tween_property(weather, "color", target, 2.0)
	
	time_label.modulate = Color(target.r, target.g, target.b, 1.0)
