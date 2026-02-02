extends Sprite2D

class_name ArrowSprite


func correct():
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "modulate", Color.GREEN, 1.0)
	tween.parallel().tween_property(self, "scale", Vector2(), .6)
	tween.tween_callback(self.queue_free)


func incorrect():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "position", Vector2(position.x -10,position.y), 0.1)
	tween.tween_property(self, "position", Vector2(position.x +20,position.y), 0.1)
	tween.tween_property(self, "position", Vector2(position.x -10,position.y), 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
