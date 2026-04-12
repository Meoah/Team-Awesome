extends Area2D
class_name BossShadow

@export var collision_shape: CollisionShape2D

func _ready() -> void:
	visible = SystemData.license == 3 and !SystemData.boss_defeated

func contains_bobber(bobber: Bobber) -> bool:
	if !is_instance_valid(bobber): return false
	
	var rect_shape: RectangleShape2D = collision_shape.shape as RectangleShape2D
	if !rect_shape: return false
	
	var rect_size: Vector2 = rect_shape.size
	var rect: Rect2 = Rect2(global_position - rect_size * 0.5, rect_size)
	return rect.has_point(bobber.global_position)
