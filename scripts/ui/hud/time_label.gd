extends Label

func _ready() -> void:
	if TimeManager:
		TimeManager.time_updated.connect(_on_time_updated)
		_update_display(TimeManager.current_hour)

func _on_time_updated(new_hour: float) -> void:
	_update_display(new_hour)

func _update_display(hour: float) -> void:
	var h24: int = int(floor(hour)) % 24
	var m: int = int(round((hour - floor(hour)) * 60.0))
	
	if m >= 60:
		m = 0
		h24 = (h24 + 1) % 24
	
	var suffix: String = "AM"
	if h24 >= 12: suffix = "PM"
	
	var h12: int = h24 % 12
	if h12 == 0: h12 = 12
	
	text = "%d:%02d %s" % [h12, m, suffix]
