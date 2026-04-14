extends RigidBody2D
class_name Bobber

# Signals to be used by MainCharacter
signal landed_in_water(bobber: Bobber)
signal hooked(bobber: Bobber)
signal hook_timeout(bobber: Bobber)

enum EncounterType {
	NORMAL,
	BOSS
}

var cast_bait_id: int = -1
var encounter_type: EncounterType = EncounterType.NORMAL

# Fish timers
@export var timer : Timer
var waiting : bool = false
var fish_hooked : bool = false
var time_until_hook : float = 0.0
var time_until_break : float = 0.0
# Bobbing
@export var bobber_sprite : Sprite2D
var bob_amplitude : float = 10.0
var bob_speed : float = 10.0
var bob_timer : float = 0.0
# Waterline detection
@export var waterline_y : float = 650
var is_in_water : bool = false

# VFX nodes
@export var indicator : Sprite2D
@export var progress_bar : ProgressBar
@export var progress_label : Label
@export_category("Audio")
@export var water_splash_sfx : AudioStream
@export var hook_indicator_sfx : AudioStream


func _ready() -> void:
	time_until_hook = randf_range(1.0, 5.0)
	time_until_break = randf_range(3.0, 5.0)
	progress_bar.max_value = time_until_break
	
func _process(delta: float) -> void:
	# Detects if bobber has fallen past the waterline. Freeze body and start timer.
	# TODO this sucks, use physics
	if global_position.y > waterline_y && !is_in_water:
		_start_bob()
		timer.start(time_until_hook)

# If in water, bob and start timer.
	if is_in_water: 
		_water_bob(delta)
	
	# Progress bar handler
	if waiting : _progress_bar()

# Decrements progress bar according to timer.
func _progress_bar() -> void:
	progress_bar.value = timer.time_left
	progress_label.set_text("%.2f s" % timer.time_left)

# Makes the indicator pop out for 1 second.
func _indicator() -> void:
	AudioEngine.play_sfx(hook_indicator_sfx)
	indicator.visible = true
	await get_tree().create_timer(1).timeout
	indicator.visible = false

# Initializes variables for bobbing.
func _start_bob() -> void:
	AudioEngine.play_sfx(water_splash_sfx)
	is_in_water = true
	freeze = true
	waiting = true
	landed_in_water.emit(self)

# Controls the bobbing motion
func _water_bob(delta : float) -> void:
	bob_timer += delta
	var bob : float = (sin(bob_timer) * bob_amplitude) + waterline_y
	global_position.y = bob
	
	#Drift based on wind strength
	if WeatherManager:
		var drift_speed : float = WeatherManager.wind_strength * 28.0
		global_position.x += drift_speed * delta

# Makes the exclaimation and starts the progress timer.
func _play_vfx() -> void:
	_progress_bar()
	progress_bar.visible = true
	_indicator()

# Hook handler
func _on_timer_timeout() -> void:
	# Second timeout. Emit hook_timeout, then queue_free().
	if fish_hooked:
		hook_timeout.emit(self)
		queue_free()
		return
		
	# First timeout. Emit hooked then restart timer for break.
	if waiting:
		freeze = false
		fish_hooked = true
		hooked.emit(self)
		timer.start(time_until_break)
		_play_vfx()
