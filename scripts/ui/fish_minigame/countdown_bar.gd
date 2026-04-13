extends TextureProgressBar
class_name CountdownBar


@export_category("Children Nodes")
@export var _time_left_label: Label
@export var _start_marker: Marker2D
@export var _end_marker: Marker2D
@export var _sparks: Sprite2D
@export var timer: Timer


func _ready() -> void:
	set_process(false)


func setup(time: float) -> void:
	timer.start(time)
	timer.set_paused(false)
	
	max_value = time
	value = time
	
	_sparks.position = _start_marker.position
	
	set_process(true)


func stop() -> void:
	set_process(false)
	timer.set_paused(true)
	_sparks.hide()


func _process(_delta: float) -> void:
	value = timer.time_left
	_time_left_label.set_text("%.2f s" % timer.time_left)
	_move_sparks()


func _move_sparks() -> void:
	var progress_percent: float = clamp(value / max_value, 0.0, 1.0)
	var distance_x: float = _end_marker.position.x - _start_marker.position.x
	var target_x: float = -(distance_x * progress_percent)
	
	_sparks.position.x = target_x
