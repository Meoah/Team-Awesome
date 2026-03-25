extends Sprite2D

var ripple_data: Array = []

func _process(delta: float) -> void:
	var pos_array: Array = []
	var time_array: Array = []
	
	#Update all active ripples
	for i in range(ripple_data.size() - 1, -1, -1):
		ripple_data[i]["time"] += delta
			
		if ripple_data[i]["time"] > 2.0:
			ripple_data.remove_at(i)
			
	#Pack data to send to shader
	for i in range(6):
		if i < ripple_data.size():
			pos_array.append(ripple_data[i]["pos"])
			time_array.append(ripple_data[i]["time"])
		else:
			pos_array.append(Vector2(-1.0, -1.0))
			time_array.append(0.0)
			
	if material:
		material.set_shader_parameter("position", pos_array)
		material.set_shader_parameter("time", time_array)
		
#Function called when lure hits the water
func spawn_ripple(hit_position: Vector2) -> void:
	if texture == null:
		return
	
	var local_pixel: Vector2 = to_local(hit_position)
	var local_pos: Vector2 = local_pixel / texture.get_size()
	
	
	local_pos = local_pos.clamp(Vector2.ZERO, Vector2.ONE)
	if ripple_data.size() < 6:
		ripple_data.append({
			"pos": local_pos,
			"time": 0.0
		})
	
		
			
