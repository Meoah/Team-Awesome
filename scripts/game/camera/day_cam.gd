extends Camera2D
class_name DayCam

@export var player : Node2D
var is_auto : bool = true

@export_category("Camera Smoothing")
@export var min_smoothing_speed : float = 2.0
@export var max_smoothing_speed : float = 600.0
@export var max_distance_for_speed : float = 600.0

func _physics_process(_delta : float) -> void:
	if !is_auto : return
	var target : Node2D = _find_target()
	_follow_target(target)

## Finds the rightmost bobber and sets that as the target. If no bobbers, then set player as target.
func _find_target() -> Node2D:
	var bobber_array : Array[Node] = get_tree().get_nodes_in_group("bobber_group")
	if !bobber_array:
		if PlayManager.get_current_state() is IdleDayState : return player
		else : return null
	
	var rightmost_bobber : Bobber
	var rightmost_x : float
	
	for each_bobber in bobber_array:
		if each_bobber.global_position.x > rightmost_x:
			rightmost_x = each_bobber.global_position.x
			rightmost_bobber = each_bobber
	
	return rightmost_bobber

## Follows the target.
func _follow_target(target : Node2D) -> void:
	if !target or !is_instance_valid(target) : return
	
	var target_position : Vector2 = target.global_position
	
	var distance_to_target : float = global_position.distance_to(target_position)
	
	var speed_ratio : float = clamp(distance_to_target / max_distance_for_speed, 0.0, 1.0)
	position_smoothing_speed = lerp(min_smoothing_speed, max_smoothing_speed, speed_ratio)
	
	global_position = target_position
	
