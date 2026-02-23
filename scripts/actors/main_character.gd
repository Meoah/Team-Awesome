extends CharacterBody2D
class_name MainCharacter

## Node exports
@export var bobber_scene : PackedScene
@export var arrow_sprite : Sprite2D
@export var boat_sprite : Sprite2D
# Arrow
var arrow_distance : float = 0.0
var cast_angle : float = 20.0
var angle_speed : float = 120.0
# Bobber
var active_bobber_count : int = 0
var bobber_limit : int = 1
var bobber_hook : int = 0
# Movement
enum InputFlags{
	MOVE_LEFT	= 1 << 0,
	MOVE_RIGHT	= 1 << 1,
	AIM_UP		= 1 << 2,
	AIM_DOWN	= 1 << 3,
	ACTION		= 1 << 4
}
var input_flags : int = 0
var move_speed : float = 200.0
# Bobbing
var bob_amplitude : float = 40.0
var bob_speed : float = 8.0
var bob_timer : float = 0.0
# Power bar
var cast_power : float = 0.0
@export var power_bar : ProgressBar
var time_held : float = 0.0
var bar_direction : float = 1.0
# Parent Nodes
var daytime_node : DaytimeMain
var nighttime_node : NighttimeMain

func _ready() -> void:
	# Initializes arrow sprite.
	arrow_distance = arrow_sprite.position.length()
	_update_arrow()
	
	# Initializes parent nodes.
	if get_parent() is DaytimeMain : daytime_node = get_parent()
	if get_parent() is NighttimeMain : nighttime_node = get_parent()
	
	# Pass the play state machine and bind state signals to callables.
	if PlayManager.get_state_machine() : _bind_signals()

func _bind_signals() -> void:
	PlayManager.idle_day_state.signal_idle_day.connect(_reset_flags)
	PlayManager.idle_night_state.signal_idle_night.connect(_reset_flags)
	PlayManager.casting_state.signal_casting.connect(_on_casting_state)
	PlayManager.waiting_state.signal_waiting.connect(_on_waiting_state)

func _input(event: InputEvent) -> void:
	# Arrow Keys
	if event.is_action_pressed("left"):		_set_flag(InputFlags.MOVE_LEFT, true)
	if event.is_action_released("left"):	_set_flag(InputFlags.MOVE_LEFT, false)
	if event.is_action_pressed("right"):	_set_flag(InputFlags.MOVE_RIGHT, true)
	if event.is_action_released("right"):	_set_flag(InputFlags.MOVE_RIGHT, false)
	if event.is_action_pressed("up"):		_set_flag(InputFlags.AIM_UP, true)
	if event.is_action_released("up"):		_set_flag(InputFlags.AIM_UP, false)
	if event.is_action_pressed("down"):		_set_flag(InputFlags.AIM_DOWN, true)
	if event.is_action_released("down"):	_set_flag(InputFlags.AIM_DOWN, false)
	
	# Action
	if event.is_action_pressed("action"):
		_set_flag(InputFlags.ACTION, true)
		if bobber_hook:
			if PlayManager.request_reeling_state():
				_clear_bobbers()
				if daytime_node : daytime_node._play_minigame()
	if event.is_action_released("action"):	_set_flag(InputFlags.ACTION, false)
	
	#TODO cancel button?

func _process(delta: float) -> void:
	if PlayManager.is_aiming() : _cast_handler(delta)

func _physics_process(delta: float) -> void:
	if PlayManager.is_movement_allowed() : _movement()
	else : velocity = Vector2.ZERO
	if PlayManager.is_aiming() : _aiming(delta)
	else : arrow_sprite.visible = false
	if PlayManager.is_daytime() : _water_bob(delta)
	
	move_and_slide()

func _notification(what: int) -> void:
	# Resets movement flags to 0 if window loses focus.
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT : input_flags = 0

# Resets the flags back to 0.
func _reset_flags() -> void:
	input_flags = 0

# Transitions to casting state, then continously charge while action held.
func _cast_handler(delta : float) -> void:
	if input_flags & InputFlags.ACTION: 
		if PlayManager.get_current_state() is CastingState:
			_charging(delta)
		elif SystemData.use_bait("generic"):
			PlayManager.request_casting_state()
	else:
		if PlayManager.get_current_state() is CastingState:
			_throw_bobber()
			PlayManager.request_waiting_state()

func _charging(delta : float) -> void:
	time_held += delta
	
	# Local variables to control bar speed
	# TODO perhaps some upgrades may alter these?
	var min_rate : float = 50.0
	var max_rate : float = 180.0
	var ramp_strength : float = 1.5
	
	# Controls power by time. Slow near bottom, fast near top.
	var factor : float = pow(cast_power / 100.0, ramp_strength)
	var rate = lerp(min_rate, max_rate, factor)
	cast_power += bar_direction * rate * delta
	
	# Ping pongs the power bar.
	if cast_power >= 100.0:
		cast_power = 100.0
		bar_direction = -1.0
	if cast_power <= 0.0:
		cast_power = 0.0
		bar_direction = 1.0
	
	_update_power_ui()

# Controls the bar visual.
func _update_power_ui() -> void:
	if power_bar:
		power_bar.max_value = 100.0
		power_bar.value = cast_power
	
	_flash_power_bar()

# Flashes the bar as it approaches max.
func _flash_power_bar() -> void:
	if cast_power >= 70.0 :
		var color_strength = abs(((100.0 - cast_power) / 30.0) - 1.0)
		power_bar.modulate = Color(1.0, color_strength, color_strength)
	else : power_bar.modulate = Color(1.0, 0, 0, 1.0)

# Scans children and clears all Bobber classes.
func _clear_bobbers() -> void:
	bobber_hook = 0
	active_bobber_count = 0
	for child in get_children():
		if child is Bobber : child.queue_free()

# Sets flag on or off
func _set_flag(flag : int, enabled : bool) -> void:
	if enabled : input_flags |= flag
	else : input_flags &= ~flag

# Movement handler
func _movement() -> void:
	var direction : float = 0.0
	if input_flags & InputFlags.MOVE_LEFT : direction -= 1.0
	if input_flags & InputFlags.MOVE_RIGHT : direction += 1.0
	velocity = Vector2(direction * move_speed, 0)

# Controls the bobbing motion
func _water_bob(delta : float) -> void:
	bob_timer += delta
	var bob : float = sin(bob_timer) * bob_amplitude
	boat_sprite.position.y = bob

# Aiming handler
func _aiming(delta) -> void:
	arrow_sprite.visible = true
	var direction : float = 0.0
	if input_flags & InputFlags.AIM_UP : direction += 1.0
	if input_flags & InputFlags.AIM_DOWN : direction -= 1.0
	
	# Moves arrow if up xor down are pressed. Clamps degrees between 20 and 80
	if direction != 0.0:
		cast_angle += direction * angle_speed * delta
		cast_angle = clamp(cast_angle, 20.0, 80.0)
		_update_arrow()

# Sets the position and angle of the arrow.
func _update_arrow() -> void:
	arrow_sprite.rotation_degrees = -cast_angle
	var cast_angle_radian = deg_to_rad(cast_angle)
	arrow_sprite.position = Vector2(cos(cast_angle_radian), -sin(cast_angle_radian)) * arrow_distance

# Throws the bobber with input angle and force.
func _throw_bobber() -> void:
	if active_bobber_count < bobber_limit:
		active_bobber_count += 1
		var bobber : RigidBody2D = bobber_scene.instantiate()
		var radians : float = deg_to_rad(cast_angle)
		var impulse : Vector2 = Vector2(cos(radians), -sin(radians)) * (cast_power + 20) * 7.5
		bobber.hooked.connect(_on_bobber_fish_hook)
		bobber.hook_timeout.connect(_on_bobber_hook_timeout)
		add_child(bobber)
		bobber.apply_impulse(impulse)

## Handles signal functions
# Sets flag if fish is hooked.
func _on_bobber_fish_hook() -> void : bobber_hook += 1

# Timeout causes line to be cut. If no more bobbers out, transition state.
func _on_bobber_hook_timeout() -> void:
	active_bobber_count -= 1
	bobber_hook -=1
	if active_bobber_count <= 0:
		active_bobber_count = 0 # Guarantee the reset.
		bobber_hook = false
		PlayManager.request_idle_day_state()

# Make power bar visible and resets cast variables on CastingState
func _on_casting_state() -> void:
	power_bar.visible = true
	cast_power = 0.0
	time_held = 0.0

# Hide power bar on WaitingState
func _on_waiting_state() -> void:
	power_bar.visible = false
