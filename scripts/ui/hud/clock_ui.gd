extends Node2D

@onready var clock_face : Sprite2D = $ClockFace
@onready var clock_hand : Sprite2D = $ClockHand

const DEGREES_PER_HOUR : float = 15.0
const ROTATION_OFFSET : float = 85.0
#--Rotation--
var target_rotation : float = 0.0
var smooth_speed : float = 0.3

func _ready() -> void:
	TimeManager.time_updated.connect(_on_time_updated)
	
	#var start_rotation := _hour_to_rotation(TimeManager.current_hour * DEGREES_PER_HOUR)
	#clock_face.rotation = start_rotation
	#target_rotation = start_rotation

func _on_time_updated(new_hour : float) -> void:
	target_rotation = _hour_to_rotation(new_hour * DEGREES_PER_HOUR)

func _process(delta: float) -> void:
	clock_face.rotation = lerp_angle(
		clock_face.rotation,
		target_rotation,
		smooth_speed * delta
	)

func _hour_to_rotation(hour : float) -> float:
	return deg_to_rad((hour * DEGREES_PER_HOUR) - ROTATION_OFFSET)
