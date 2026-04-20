extends CharacterBody2D
class_name MainCharacter

@export_category("Children Nodes")
@export var bobber_scene : PackedScene
@export var collision_shape: CollisionShape2D
@export var arrow_sprite : Sprite2D
@export var body_sprite: AnimatedSprite2D
@export var power_bar : TextureProgressBar
@export var camera: DayCam
@export_category("Audio")
@export var charging_sfx : AudioStream
@export var hook_success_sfx : AudioStream
@export var casting_sfx: AudioStream
@export var _wood_step_sfx: AudioStream
@export var _dirt_step_sfx: AudioStream

# Arrow
var arrow_distance : float = 0.0
var cast_angle : float = 20.0
var angle_speed : float = 120.0
# Bobber
var active_bobber_count: int = 0
var bobber_limit: int = 1
var bobber_hook: int = 0

## How much stamina is refunded when retracting an unhooked bobber.
const EARLY_REEL_STAMINA_REFUND_RATIO: float = 0.5

## Prevents repeated stamina warning spam while the action button is held.
var cast_blocked_until_action_release: bool = false
# Movement
enum InputFlags{
	MOVE_LEFT	= 1 << 0,
	MOVE_RIGHT	= 1 << 1,
	AIM_UP		= 1 << 2,
	AIM_DOWN	= 1 << 3,
	ACTION		= 1 << 4
}
var input_flags : int = 0
var move_speed : float = 250.0
var suppress_gameplay_input_until_release: bool = false
var suppress_action_input_until_release: bool = false
# Bobbing
var bob_amplitude : float = 40.0
var bob_speed : float = 8.0
var bob_timer : float = 0.0
# Power bar
var cast_power : float = 0.0
var time_held : float = 0.0
var bar_direction : float = 1.0
# Parent Nodes
var daytime_node : DaytimeMain
var nighttime_node : NighttimeMain
# Signals
signal player_interact

var time_spent_per_cast: float = 1.5

var queued_cast_bait_id: int = -1
var hooked_bobbers: Array[Bobber] = []

func _ready() -> void:
	# Initializes arrow sprite.
	arrow_distance = arrow_sprite.position.length()
	_update_arrow()
	
	# Initializes parent nodes.
	if get_parent() is DaytimeMain : daytime_node = get_parent()
	if get_parent() is NighttimeMain : nighttime_node = get_parent()
	
	# Pass the play state machine and bind state signals to callables.
	if PlayManager.get_state_machine() : _bind_signals()
	
	# Changes stats according to equipment
	_check_equipment()

func _bind_signals() -> void:
	PlayManager.idle_day_state.signal_idle_day.connect(_reset_flags)
	PlayManager.idle_night_state.signal_idle_night.connect(_reset_flags)
	PlayManager.casting_state.signal_casting.connect(_on_casting_state)
	PlayManager.waiting_state.signal_waiting.connect(_on_waiting_state)


var stamina_usage: float = 10.0
var strength_multiplier: float = 1.0
# TODO CHANGE THIS LATER, THE EQUIPMENT IS FAKE RIGHT NOW, HARDCODED TO LICENSE.
func _check_equipment() -> void:
	match SystemData.license:
		1:
			pass
		2:
			stamina_usage = 7.5
			strength_multiplier = 4.0
		3:
			time_spent_per_cast *= 0.75
			stamina_usage = 6.0


func _input(event : InputEvent) -> void:
	if event.is_echo(): return
	
	if suppress_gameplay_input_until_release:
		input_flags = 0
		interacted = false
		
		if _has_any_gameplay_input_pressed():
			get_viewport().set_input_as_handled()
			return
		
		suppress_gameplay_input_until_release = false
	
	if suppress_action_input_until_release:
		if event.is_action_pressed("action"):
			_set_flag(InputFlags.ACTION, false)
			get_viewport().set_input_as_handled()
			return
		
		if event.is_action_released("action"):
			_set_flag(InputFlags.ACTION, false)
			suppress_action_input_until_release = false
			cast_blocked_until_action_release = false
			return
	
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
	
	if event.is_action_released("action"):
		_set_flag(InputFlags.ACTION, false)
		cast_blocked_until_action_release = false


func _process(delta: float) -> void:
	if PlayManager.is_aiming() : _cast_handler(delta)


func _physics_process(delta: float) -> void:
	if PlayManager.is_movement_allowed() : _movement()
	else:
		velocity = Vector2.ZERO
		body_sprite.play("idle")
	if PlayManager.is_aiming() : _aiming(delta)
	else : arrow_sprite.visible = false
	if !PlayManager.is_dialogue() : _action()
	
	move_and_slide()


func _notification(what: int) -> void:
	# Resets movement flags to 0 if window loses focus.
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT : input_flags = 0


func walk_up_sequence(target_x: float = 350.0) -> void:
	set_physics_process(false)
	body_sprite.flip_h = false
	collision_shape.set_disabled(true)
	
	body_sprite.play("walking")
	
	while global_position.x < target_x:
		velocity.x = move_speed
		move_and_slide()
		
		if global_position.x >= target_x:
			break
		
		await get_tree().physics_frame
	
	velocity.x = 0.0
	collision_shape.set_disabled(false)
	set_physics_process(true)
	_sync_held_movement_input()


## Resets the gameplay input flags.
func _reset_flags() -> void:
	input_flags = 0
	cast_blocked_until_action_release = false
	suppress_action_input_until_release = false


## Suppresses gameplay input until all current inputs are released.
func suppress_input_until_release() -> void:
	suppress_gameplay_input_until_release = true
	input_flags = 0
	interacted = false
	cast_blocked_until_action_release = false


## Suppresses only the action input until it is released.
##
## This is only armed if the action button is currently being held when
## control is returned to the player. If action is not held, do not consume the
## next press.
func suppress_action_until_release() -> void:
	_set_flag(InputFlags.ACTION, false)
	interacted = false
	cast_blocked_until_action_release = false

	if Input.is_action_pressed("action"):
		suppress_action_input_until_release = true
	else:
		suppress_action_input_until_release = false


func _has_any_gameplay_input_pressed() -> bool:
	return (
		Input.is_action_pressed("left")
		or Input.is_action_pressed("right")
		or Input.is_action_pressed("up")
		or Input.is_action_pressed("down")
		or Input.is_action_pressed("action")
	)


## Syncs held movement inputs after scripted movement finishes.
func _sync_held_movement_input() -> void:
	_set_flag(InputFlags.MOVE_LEFT, Input.is_action_pressed("left"))
	_set_flag(InputFlags.MOVE_RIGHT, Input.is_action_pressed("right"))


## Re-applies currently held movement input after a scripted handoff.
func apply_held_movement_input() -> void:
	_sync_held_movement_input()


## Handles cast input and charge state transitions.
func _cast_handler(delta: float) -> void:
	if input_flags & InputFlags.ACTION:
		if PlayManager.get_current_state() is CastingState:
			body_sprite.flip_h = false
			_charging(delta)

		elif active_bobber_count < bobber_limit:
			_try_begin_cast()

	elif PlayManager.get_current_state() is CastingState:
		AudioEngine.play_sfx(casting_sfx)

		if _throw_bobber():
			PlayManager.request_waiting_state()
		else:
			PlayManager.request_idle_day_state()


## Attempts to enter the casting state.
##
## If the player does not have enough stamina, the cast is blocked before the
## charging phase begins and the stamina UI is asked to shake and flash.
func _try_begin_cast() -> void:
	if SystemData.get_stamina() < stamina_usage:
		if not cast_blocked_until_action_release:
			SystemData.not_enough_stamina.emit()
			cast_blocked_until_action_release = true
		return

	body_sprite.flip_h = false
	PlayManager.request_casting_state()


# Charges the power bar.
func _charging(delta : float) -> void:
	time_held += delta
	
	# Local variables to control bar speed
	# TODO perhaps some upgrades may alter these?
	var min_rate : float = 50.0
	var max_rate : float = 180.0
	var ramp_strength : float = 1.5
	AudioEngine.play_sfx(charging_sfx, "", 1.0, 1, 0, 2.21)
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
	hooked_bobbers.clear()
	
	for child in get_children():
		if child is Bobber:
			child.queue_free()

# Sets flag on or off
func _set_flag(flag : int, enabled : bool) -> void:
	if enabled : input_flags |= flag
	else : input_flags &= ~flag

# Movement handler
func _movement() -> void:
	var direction : float = 0.0
	if input_flags & InputFlags.MOVE_LEFT:
		body_sprite.flip_h = true
		direction -= 1.0
	if input_flags & InputFlags.MOVE_RIGHT:
		body_sprite.flip_h = false
		direction += 1.0
		
	if direction != 0.0 : body_sprite.play("walking")
	else : body_sprite.play("idle")
	
	velocity = Vector2(direction * move_speed, 0)

# Action handler.
var interacted: bool = false

## Handles the action button while not in dialogue.
func _action() -> void:
	if !(input_flags & InputFlags.ACTION):
		interacted = false
		return

	if not interacted:
		player_interact.emit()
		interacted = true

	if _try_retract_waiting_bobber():
		return

	if bobber_hook > 0:
		if PlayManager.request_reeling_state():
			var hooked_bobber: Bobber = _get_reel_target_bobber()
			if not hooked_bobber:
				return

			var distance: float = hooked_bobber.position.x
			var encounter_type: Bobber.EncounterType = hooked_bobber.encounter_type
			var bait_id: int = hooked_bobber.cast_bait_id

			AudioEngine.play_sfx(hook_success_sfx)
			_clear_bobbers()

			if daytime_node:
				daytime_node.start_fishing_encounter(encounter_type, distance, bait_id)

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
func _throw_bobber() -> bool:
	AudioEngine.stop_sfx_key(charging_sfx)
	
	if active_bobber_count >= bobber_limit: return false
	
	var bait_id: int = SystemData.get_active_bait()
	
	if !SystemData.use_stamina(stamina_usage): return false
	if !SystemData.use_bait(bait_id): return false
	
	queued_cast_bait_id = bait_id
	
	TimeManager._advance_time(time_spent_per_cast)
	active_bobber_count += 1
	
	var bobber: Bobber = bobber_scene.instantiate()
	bobber.cast_bait_id = queued_cast_bait_id
	queued_cast_bait_id = -1
	
	var radians: float = deg_to_rad(cast_angle)
	var impulse: Vector2 = Vector2(cos(radians), -sin(radians)) * (cast_power + 20) * 7.5 * strength_multiplier
	
	bobber.hooked.connect(_on_bobber_fish_hook)
	bobber.hook_timeout.connect(_on_bobber_hook_timeout)
	
	if daytime_node: bobber.landed_in_water.connect(daytime_node._on_bobber_landed_in_water)
	
	add_child(bobber)
	bobber.apply_impulse(impulse)
	return true

func _get_reel_target_bobber() -> Bobber:
	var chosen: Bobber = null
	var best_x: float = -INF
	
	for bobber in hooked_bobbers:
		if !is_instance_valid(bobber):
			continue
		if bobber.global_position.x > best_x:
			best_x = bobber.global_position.x
			chosen = bobber
	
	return chosen


## Returns the best landed, unhooked bobber that can be retracted manually.
func _get_waiting_target_bobber() -> Bobber:
	var chosen: Bobber = null
	var best_x: float = -INF

	for child in get_children():
		var bobber: Bobber = child as Bobber
		if not bobber:
			continue

		if not is_instance_valid(bobber):
			continue

		if bobber.is_queued_for_deletion():
			continue

		if bobber.fish_hooked:
			continue

		if not bobber.is_in_water:
			continue

		if bobber.global_position.x > best_x:
			best_x = bobber.global_position.x
			chosen = bobber

	return chosen


## Attempts to retract an unhooked bobber before a fish bites.
##
## Refunds the bait used for the cast and half of the stamina cost.
func _try_retract_waiting_bobber() -> bool:
	if !(PlayManager.get_current_state() is WaitingState):
		return false

	if bobber_hook > 0:
		return false

	var waiting_bobber: Bobber = _get_waiting_target_bobber()
	if not waiting_bobber:
		return false

	_refund_retracted_cast(waiting_bobber)

	if waiting_bobber.timer:
		waiting_bobber.timer.stop()

	waiting_bobber.queue_free()
	active_bobber_count = max(active_bobber_count - 1, 0)
	hooked_bobbers.erase(waiting_bobber)

	if active_bobber_count <= 0:
		PlayManager.request_idle_day_state()

	return true


## Refunds the resources used by a manually retracted cast.
func _refund_retracted_cast(bobber: Bobber) -> void:
	SystemData.add_stamina(stamina_usage * EARLY_REEL_STAMINA_REFUND_RATIO)

	if bobber.cast_bait_id == -1:
		return

	SystemData._add_bait(bobber.cast_bait_id, 1)

	if SystemData.get_active_bait() == -1:
		SystemData.set_active_bait(bobber.cast_bait_id)


## Handles signal functions
# Sets flag if fish is hooked.
func _on_bobber_fish_hook(bobber: Bobber) -> void:
	bobber_hook += 1
	if !hooked_bobbers.has(bobber): hooked_bobbers.append(bobber)

# Timeout causes line to be cut. If no more bobbers out, transition state.
func _on_bobber_hook_timeout(bobber: Bobber) -> void:
	active_bobber_count -= 1
	hooked_bobbers.erase(bobber)
	
	if bobber_hook > 0: bobber_hook -= 1
	
	if active_bobber_count <= 0:
		active_bobber_count = 0
		bobber_hook = 0
		PlayManager.request_idle_day_state()

# Make power bar visible and resets cast variables on CastingState
func _on_casting_state() -> void:
	power_bar.visible = true
	cast_power = 0.0
	time_held = 0.0

# Hide power bar on WaitingState
func _on_waiting_state() -> void:
	power_bar.visible = false


func _on_body_frame_changed() -> void:
	if body_sprite.get_animation() == "walking":
		if body_sprite.frame == 1 or body_sprite.frame == 3:
			_footstep_sfx()

## Checks which ground surface Jeremy is on, then play the appropriate sound.
func _footstep_sfx() -> void:
	# TODO We perhaps we can use an area2D to detect what's under his feet. For now,
	#	we just determine surface by main scene.
	if daytime_node: AudioEngine.play_sfx(_wood_step_sfx)
	if nighttime_node: AudioEngine.play_sfx(_dirt_step_sfx)
