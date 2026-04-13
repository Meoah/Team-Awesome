extends Camera2D
class_name DayCam

@export var player: Node2D
var is_auto: bool = true

@export_category("Camera Follow")
@export var min_follow_speed_x: float = 250.0
@export var max_follow_speed_x: float = 5000.0
@export var max_distance_for_speed_x: float = 1000.0

@export var min_follow_speed_y: float = 500.0
@export var max_follow_speed_y: float = 20000.0
@export var max_distance_for_speed_y: float = 2000.0


func _physics_process(delta: float) -> void:
	if !is_auto:
		return
	
	var target_position: Vector2 = _find_target_position()
	
	if _should_hold_x_position():
		global_position.y = _move_axis_toward(
			global_position.y,
			target_position.y,
			min_follow_speed_y,
			max_follow_speed_y,
			max_distance_for_speed_y,
			delta
				)
		return
	
	global_position.x = _move_axis_toward(
		global_position.x,
		target_position.x,
		min_follow_speed_x,
		max_follow_speed_x,
		max_distance_for_speed_x,
		delta
			)
	
	global_position.y = _move_axis_toward(
		global_position.y,
		target_position.y,
		min_follow_speed_y,
		max_follow_speed_y,
		max_distance_for_speed_y,
		delta
			)


func _should_hold_x_position() -> bool:
	var state := PlayManager.get_current_state()
	return state is ReelingState or state is CatchingState


func _move_axis_toward(current_value: float, target_value: float, min_speed: float, max_speed: float, max_distance_for_speed: float, delta: float) -> float:
	var distance_to_target: float = abs(current_value - target_value)
	var speed_ratio: float = clamp(distance_to_target / max_distance_for_speed, 0.0, 1.0)
	var follow_speed: float = lerp(min_speed, max_speed, speed_ratio)
	return move_toward(current_value, target_value, follow_speed * delta)


func _find_target_position() -> Vector2:
	var rightmost_bobber: Bobber = _find_valid_rightmost_bobber()
	
	if rightmost_bobber: return _clamp_camera_position(rightmost_bobber.global_position)
	
	if player and is_instance_valid(player): return _clamp_camera_position(player.global_position)
	
	return _clamp_camera_position(global_position)


func _find_valid_rightmost_bobber() -> Bobber:
	var bobber_array: Array[Node] = get_tree().get_nodes_in_group("bobber_group")
	var rightmost_bobber: Bobber = null
	var rightmost_x: float = -INF
	
	for each_node in bobber_array:
		var each_bobber: Bobber = each_node as Bobber
		if !each_bobber: continue
		if !is_instance_valid(each_bobber): continue
		if each_bobber.is_queued_for_deletion(): continue
		if !each_bobber.is_inside_tree(): continue
		
		if each_bobber.global_position.x > rightmost_x:
			rightmost_x = each_bobber.global_position.x
			rightmost_bobber = each_bobber
	
	return rightmost_bobber


func _clamp_camera_position(target_position: Vector2) -> Vector2:
	var clamped: Vector2 = target_position
	
	if limit_left != -10000000: clamped.x = max(clamped.x, float(limit_left))
	if limit_right != 10000000: clamped.x = min(clamped.x, float(limit_right))
	
	if limit_top != -10000000: clamped.y = max(clamped.y, float(limit_top))
	if limit_bottom != 10000000: clamped.y = min(clamped.y, float(limit_bottom))
	
	return clamped
