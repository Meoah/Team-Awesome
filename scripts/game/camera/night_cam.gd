extends Camera2D
class_name NightCam

@export var player : Node2D

func _process(_delta : float) -> void:
	_follow_player()

## Follows the player 
func _follow_player() -> void:
	if !player or !is_instance_valid(player) : return
	var target_x : float = clamp(player.global_position.x, limit_left, limit_right)
	global_position.x = target_x
