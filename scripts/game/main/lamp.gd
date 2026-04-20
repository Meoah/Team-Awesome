extends Node2D

## Handles the daytime dock lamp.
##
## The lamp turns on from 6:00 PM to 6:00 AM, turns off during the day, and
## sways smoothly based on the current wind strength.

const LAMP_ON_HOUR: float = 18.0
const LAMP_OFF_HOUR: float = 6.0


@export_category("Textures")
## Lamp sprite shown while the lamp is lit.
@export var _on_texture: Texture2D

## Lamp sprite shown while the lamp is unlit.
@export var _off_texture: Texture2D


@export_category("Children Nodes")
## The visible lamp sprite that swaps between lit and unlit textures.
@export var _lamp_sprite: Sprite2D

## The point light used when the lamp is on.
@export var _lamp_light: PointLight2D


@export_category("Sway")
## Maximum sway angle, in degrees, at full wind strength.
@export var sway_strength_degrees: float = 80.0

## How quickly the lamp rotates toward its next sway target.
@export var sway_speed: float = 3.0

## Minimum time between sway target changes.
@export var sway_interval_min: float = 0.18

## Maximum time between sway target changes.
@export var sway_interval_max: float = 0.5


var _base_lamp_rotation: float = 0.0
var _target_lamp_rotation: float = 0.0
var _sway_timer: float = 0.0


func _ready() -> void:
	_base_lamp_rotation = _lamp_sprite.rotation
	_target_lamp_rotation = _base_lamp_rotation

	TimeManager.time_updated.connect(_on_time_updated)
	WeatherManager.weather_changed.connect(_on_weather_changed)

	_apply_lamp_state(TimeManager.current_hour)
	_pick_new_sway_target()
	_reset_sway_timer()


func _process(delta: float) -> void:
	_update_sway(delta)


## Updates the lamp's lit state when time changes.
func _on_time_updated(new_hour: float) -> void:
	_apply_lamp_state(new_hour)


## Refreshes the sway target when the weather changes.
func _on_weather_changed(_new_weather: WeatherManager.WEATHER) -> void:
	_pick_new_sway_target()
	_reset_sway_timer()


## Applies the correct lamp visuals for the given hour.
func _apply_lamp_state(hour: float) -> void:
	var should_be_on: bool = _is_lamp_on(hour)

	_lamp_sprite.texture = _on_texture if should_be_on else _off_texture
	_lamp_light.visible = should_be_on


## Returns true when the lamp should be on.
func _is_lamp_on(hour: float) -> bool:
	return hour >= LAMP_ON_HOUR or hour < LAMP_OFF_HOUR


## Smoothly sways the lamp based on current wind strength.
func _update_sway(delta: float) -> void:
	var wind_strength: float = clampf(WeatherManager.wind_strength, 0.0, 1.0)

	if wind_strength <= 0.0:
		_target_lamp_rotation = _base_lamp_rotation
		_lamp_sprite.rotation = lerp_angle(
			_lamp_sprite.rotation,
			_target_lamp_rotation,
			sway_speed * delta
		)
		return

	_sway_timer -= delta

	if _sway_timer <= 0.0:
		_pick_new_sway_target()
		_reset_sway_timer()

	_lamp_sprite.rotation = lerp_angle(
		_lamp_sprite.rotation,
		_target_lamp_rotation,
		(sway_speed + wind_strength * 2.0) * delta
	)


## Chooses the next sway rotation target from the current wind strength.
func _pick_new_sway_target() -> void:
	var wind_strength: float = clampf(WeatherManager.wind_strength, 0.0, 1.0)
	var max_offset_radians: float = deg_to_rad(sway_strength_degrees * wind_strength)

	_target_lamp_rotation = _base_lamp_rotation + randf_range(
		-max_offset_radians,
		max_offset_radians
	)


## Resets the sway timer.
##
## Stronger wind causes the lamp to pick new sway targets more frequently.
func _reset_sway_timer() -> void:
	var wind_strength: float = clampf(WeatherManager.wind_strength, 0.0, 1.0)
	var interval_scale: float = lerpf(1.5, 0.6, wind_strength)

	_sway_timer = randf_range(sway_interval_min, sway_interval_max) * interval_scale
