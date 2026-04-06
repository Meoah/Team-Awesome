extends Label

func _ready() -> void:
	if TimeManager:
		TimeManager.time_updated.connect(_on_time_updated)
		_update_display(TimeManager.current_hour)

func _on_time_updated(new_hour : float) -> void:
	_update_display(new_hour)

func _update_display(hour : float) -> void:
	var h := int(hour)
	var m := int((hour - h) * 60)
	text = "%02d:%02d" % [h, m]
