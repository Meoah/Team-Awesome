extends Sprite2D

class_name smoke_sprite

# Called when the node enters the scene tree for the first time.

func smoke_anim():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(3,3), 1)
	tween.parallel().tween_property(self, "modulate",Color(0.0, 0.0, 0.0, 0.0), 0.3)
