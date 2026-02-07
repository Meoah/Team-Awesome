extends TextureRect


class_name ArrowTexture  #Object to spawn the input pattern


func correct():  #Animation for correct input. Turns green and shrinks
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "modulate", Color.GREEN, 1.0)
	tween.parallel().tween_property(self, "scale", Vector2(), .6)
	tween.tween_callback(self.queue_free)

func shake(): #Animation for shaking
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x -10,position.y), 0.05)
	tween.tween_property(self, "position", Vector2(position.x +20,position.y), 0.05)
	tween.tween_property(self, "position", Vector2(position.x -10,position.y), 0.05)


func incorrect():  #Animation for incorrect input. Shakes and flashes Red
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	shake()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
func erase(): #Animation for erasing 
	var tween = get_tree().create_tween()  
	tween.parallel().tween_property(self, "scale", Vector2(100,0),0.1)
	await  get_tree().create_timer(0.5).timeout
	tween.parallel().tween_property(self, "visible", 0,0.1)
	
	
func evilize(): #Turns arrow red for Evil Variant. Work in Progress
	modulate = Color(1.0, 0.0, 0.0, 1.0)
