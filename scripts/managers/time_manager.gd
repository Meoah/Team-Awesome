extends Node

var current_hour : float = 6.0
var time_enabled : bool = false

signal time_updated(new_hour : float)
signal period_changed(new_period : int)

#Set Time
func _set_time(hour : float) -> void:
	current_hour = clamp(hour, 0.0, 23.99)
	time_updated.emit(current_hour)
	period_changed.emit(_get_quadrant(current_hour))

#Advance Time 1.5 hours per cast
func _advance_time(amount : float) -> void:
	#Ensures time does not advance during tutorial 
	if not time_enabled:
		return
	var old_quadrant := _get_quadrant(current_hour)
	#Wraps, prevents time from becoming 24.5
	current_hour = fposmod(current_hour + amount, 24.0) 
	time_updated.emit(current_hour)
	
	var new_quadrant := _get_quadrant(current_hour)
	if new_quadrant != old_quadrant:
		period_changed.emit(new_quadrant)

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
