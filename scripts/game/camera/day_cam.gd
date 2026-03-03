extends Camera2D
class_name DayCam

@export var player : Node2D
var is_auto : bool = true

func _process(_delta : float) -> void:
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
			rightmost_bobber = each_bobber
	
	return rightmost_bobber

## Follows the target.
func _follow_target(target : Node2D) -> void:
	if !target or !is_instance_valid(target) : return
	var target_x : float = clamp(target.global_position.x, limit_left, limit_right)
	global_position.x = target_x
