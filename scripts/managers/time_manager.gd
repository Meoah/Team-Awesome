extends Node

var current_hour : float = 6.0
var time_enabled : bool = false
var initialized: bool = false

signal time_updated(new_hour : float)
signal period_changed(new_period : int)
signal midnight_crossed(new_day: int)

func _reset_clock(hour: float = 6.0) -> void:
	initialized = true
	_set_time(hour)

#Set Time
func _set_time(hour: float) -> void:
	initialized = true
	current_hour = wrapf(hour, 0.0, 24.0)
	time_updated.emit(current_hour)
	period_changed.emit(_get_quadrant(current_hour))

#Advance Time 1.5 hours per cast
func _advance_time(amount: float, ignore_time_enabled: bool = false) -> int:
	if amount <= 0.0:
		return 0
	#Ensures time does not advance during tutorial 
	if not time_enabled and not ignore_time_enabled:
		return 0
	var old_quadrant: int = _get_quadrant(current_hour)
	var total_hours: float = current_hour + amount
	var midnights_crossed: int = int(floor(total_hours / 24.0))
	#Wraps, prevents time from becoming 24.5
	current_hour = fposmod(total_hours, 24.0)
	
	if midnights_crossed > 0:
		for i in midnights_crossed:
			SystemData._next_day()
			midnight_crossed.emit(SystemData.get_day())
	
	time_updated.emit(current_hour)
	
	var new_quadrant: int = _get_quadrant(current_hour)
	if new_quadrant != old_quadrant:
		period_changed.emit(new_quadrant)
	
	return midnights_crossed

func get_absolute_hour() -> float:
	return float(SystemData.get_day() - 1) * 24.0 + current_hour

#Quadrant check------
func _get_quadrant(hour : float) -> int:
	if hour >= 6.0 and hour < 13.0:
		return 1
	elif hour >= 13.0 and hour < 18.0:
		return 2
	elif hour >= 18.0 and hour < 24.0:
		return 3
	else:
		return 0
