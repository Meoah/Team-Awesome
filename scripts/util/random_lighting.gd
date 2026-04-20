extends PointLight2D

@export var min_scale: float = 0.95
@export var max_scale: float = 1.08
@export var flicker_speed: float = 4.0
@export var flicker_interval_min: float = 0.04
@export var flicker_interval_max: float = 0.12

var _target_scale: float
var _flicker_timer: float = 0.0


func _ready() -> void:
	_target_scale = texture_scale
	_reset_flicker_timer()


func _process(delta: float) -> void:
	_flicker_timer -= delta

	if _flicker_timer <= 0.0:
		_target_scale = randf_range(min_scale, max_scale)
		_reset_flicker_timer()

	texture_scale = move_toward(texture_scale, _target_scale, flicker_speed * delta)


func _reset_flicker_timer() -> void:
	_flicker_timer = randf_range(flicker_interval_min, flicker_interval_max)
