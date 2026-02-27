extends TextureRect


class_name ArrowTexture  #Object to spawn the input pattern


func correct():  #Animation for correct input. Turns green and shrinks
	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate", Color.GREEN, .6)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, .6)
	tween.parallel().tween_property(self, "visible", false, 0.6)
	tween.tween_callback(queue_free).set_delay(1)

func shake(): #Animation for shaking
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x -10,position.y), 0.05)
	tween.tween_property(self, "position", Vector2(position.x +20,position.y), 0.05)
	tween.tween_property(self, "position", Vector2(position.x -10,position.y), 0.05)


func incorrect():  #Animation for incorrect input. Shakes and flashes Red
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	shake()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
func erase(): #Animation for erasing 
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2(100,0),0.1)
	tween.parallel().tween_property(self, "visible", false,0.1)
	
	
	
	
func evilize(): #Turns arrow red for Evil Variant. Work in Progress
	modulate = Color(1.0, 0.0, 0.0, 1.0)
