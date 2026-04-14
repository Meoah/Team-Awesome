extends CanvasLayer

@onready var rect : ColorRect = $ColorRect

# Flash brightness
var intensity   : float = 0.0
var isFlashing  : bool  = false
#Timer
var time_next_flash : float = 0.0
# Just below the weather film
const LAYER_INDEX   : int = 99

func _ready() -> void:
	layer = LAYER_INDEX
	rect.color = Color(1.0, 1.0, 1.0, 0.0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	schedule_next_flash()
	if WeatherManager:
		WeatherManager.weather_changed.connect(on_weather_changed)

func process(delta : float) -> void:
	# Only active during a storm
	if WeatherManager.current_weather != WeatherManager.WEATHER.STORMY:
		intensity = move_toward(intensity, 0.0, delta * 6.0)
		apply_intensity()
		return
		
	if isFlashing:
		intensity      = move_toward(intensity, 0.0, delta * 7.0)
		apply_intensity()
		if intensity  <= 0.0:
			isFlashing = false
			schedule_next_flash()
		else:
			time_next_flash    -= delta
			if time_next_flash <= 0.0:
				strike()

func strike() -> void:
	# Each flash is slightly different
	intensity  = randf_range(0.55, 0.95)
	isFlashing = true
	apply_intensity()
	
	# Random double flash
	if randf() > 0.65:
		await get_tree().create_timer(randf_range(0.06, 0.14)).timeout
		if WeatherManager.current_weather == WeatherManager.WEATHER.STORMY:
			intensity = randf_range(0.3, 0.6)
			apply_intensity()

func schedule_next_flash() -> void:
	# Random gaps between flashes
	time_next_flash = randf_range(3.0, 12.0)

func apply_intensity() -> void:
	rect.color = Color(1.0, 1.0, 1.0, intensity)

func on_weather_changed(weather : WeatherManager.WEATHER) -> void:
	# Fade out from storm
	if weather != WeatherManager.WEATHER.STORMY:
		isFlashing = false
