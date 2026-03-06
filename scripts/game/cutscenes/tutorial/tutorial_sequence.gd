extends CanvasLayer
class_name TutorialSequence

@export var animation_name : String = "tutorial"
@export var animation_player : AnimationPlayer
@export var continue_indicator : Control

const INPUT_COOLDOWN : float = 0.15

var suppress_step_marker : bool = false
var step_times : PackedFloat32Array = PackedFloat32Array()
var step_index : int = -1
var is_advancing : bool = false
var input_locked : bool = false

signal tutorial_done

func _ready() -> void:
	# Build the list of step marker times from the method track keys.
	_cache_step_times()
	
	# Start the animation, but immediately pause it at time 0.
	# Manually control playback using speed_scale.
	animation_player.play(animation_name)
	animation_player.seek(0.0, true)
	animation_player.speed_scale = 0.0
	
	# Hide the continue UI element until it pauses on the first marker.
	_set_continue_visible(false)
	
	# Auto-plays the first segment.
	_play_to_next_step()

func _input(event: InputEvent) -> void:
	if input_locked : return
	
	# Listens for space bar or click to trigger the next step.
	if event.is_action_pressed("mouse_click") or event.is_action_pressed("action"):
		input_locked = true
		advance_or_skip()
		_input_cooldown()

## Cooldown to prevent spam clicking breaking things.
func _input_cooldown() -> void:
	await get_tree().create_timer(INPUT_COOLDOWN).timeout
	input_locked = false

## Attempts to advance or skip to the next beat.
func advance_or_skip() -> void:
	# If we're already at (or past) the last step, end the tutorial.
	if step_index >= step_times.size() - 1:
		_finish_tutorial()
		return
	
	# If the animation is currently playing, skip straight to the next marker.
	if is_advancing:
		_skip_to_next_step()
		return
	
	# If we are paused on a marker, play until the next marker.
	_play_to_next_step()

## Resumes playing until the next marker.
func _play_to_next_step() -> void:
	# The next marker index.
	var next_index : int = step_index + 1
	# If there is no next marker, the tutorial is complete.
	if next_index >= step_times.size():
		_finish_tutorial()
		return
	
	# Resume playback until the animation hits the next marker.
	is_advancing = true
	animation_player.speed_scale = 1.0
	
	# Hide the continue UI element while advancing.
	_set_continue_visible(false)

## Skips straight to the next marker.
func _skip_to_next_step() -> void:
	# The next marker index.
	var next_index: int = step_index + 1
	# If there is no next marker, the tutorial is complete.
	if next_index >= step_times.size():
		_finish_tutorial()
		return
		
	# Jump directly to the next marker time and pause there, 
	#	prevents _step_marker() from firing.
	suppress_step_marker = true
	animation_player.speed_scale = 0.0
	animation_player.seek(step_times[next_index], true)
	is_advancing = false
	call_deferred("_clear_step_suppress")
	# Update our step index to match the active marker.
	step_index = next_index
	
	# Show the continue UI element since the animation is paused.
	_set_continue_visible(true)
	
	# If that was the last marker, finish immediately.
	if step_index >= step_times.size() - 1 : _finish_tutorial()


## Clears the suppress_step_marker. Call deferred to prevent it from clearing too early.
func _clear_step_suppress() -> void:
	suppress_step_marker = false

## This function is called by the AnimationPlayer at each marker.
## When it hits a marker naturally, pause playback and show the continue UI.
func _step_marker() -> void:
	if suppress_step_marker : return
	
	# Pauses the animation.
	animation_player.speed_scale = 0.0
	is_advancing = false
	
	# Advance the step index because it reached the next marker in sequence.
	step_index += 1
	
	# Show the continue UI element since the animation is paused.
	_set_continue_visible(true)

	# If that was the last marker, finish immediately.
	if step_index >= step_times.size() - 1 : _finish_tutorial()

## Emits the finished signal, then frees itself.
func _finish_tutorial() -> void:
	tutorial_done.emit()
	queue_free()

## Sets the continue UI element visibility.
func _set_continue_visible(visible_value: bool) -> void:
	if continue_indicator : continue_indicator.visible = visible_value

## Build the list of step marker times from the method track keys.
func _cache_step_times() -> void:
	# Rebuild step marker times from the animation's method track.
	step_times.clear()
	step_index = -1
	
	var animation: Animation = animation_player.get_animation(animation_name)
	
	# Find all method tracks, and collect the key times for each _step_marker().
	for track_index in animation.get_track_count():
		if animation.track_get_type(track_index) != Animation.TYPE_METHOD : continue
		
		var key_count: int = animation.track_get_key_count(track_index)
		for key_index in key_count:
			var method_name: StringName = animation.method_track_get_name(track_index, key_index)
			if method_name == "_step_marker":
				step_times.append(animation.track_get_key_time(track_index, key_index))
	
	# Ensure times are in ascending order so step_index + 1 always points to the next marker.
	step_times.sort()
