extends CharacterBody2D
class_name MainCharacter

## Node exports
@export var bobber_scene : PackedScene
@export var arrow_sprite : Sprite2D
@export var boat_sprite : Sprite2D

# Arrow
var arrow_distance : float = 0.0
var cast_strength : float = 500.0
var cast_angle : float = 20.0
var angle_speed : float = 120.0

# Bobber
var active_bobber_count : int = 0
var bobber_limit : int = 1

# Movement
enum InputFlags{
	MOVE_LEFT  = 1 << 0,
	MOVE_RIGHT = 1 << 1,
	AIM_UP     = 1 << 2,
	AIM_DOWN   = 1 << 3
}
var input_flags : int = 0
var move_speed : float = 200.0

# Bobbing
var bob_amplitude : float = 2.0
var bob_speed : float = 4.0
var bob_timer : float = 0.0

func _ready() -> void:
	arrow_distance = arrow_sprite.position.length()
	_update_arrow()

func _input(event: InputEvent) -> void:
	#TODO statemachine
	
	if event.is_action_pressed("left"):		_set_flag(InputFlags.MOVE_LEFT, true)
	if event.is_action_released("left"):	_set_flag(InputFlags.MOVE_LEFT, false)
	if event.is_action_pressed("right"):	_set_flag(InputFlags.MOVE_RIGHT, true)
	if event.is_action_released("right")	:_set_flag(InputFlags.MOVE_RIGHT, false)
	if event.is_action_pressed("up"):		_set_flag(InputFlags.AIM_UP, true)
	if event.is_action_released("up"):		_set_flag(InputFlags.AIM_UP, false)
	if event.is_action_pressed("down"):		_set_flag(InputFlags.AIM_DOWN, true)
	if event.is_action_released("down"):	_set_flag(InputFlags.AIM_DOWN, false)

func _physics_process(delta: float) -> void:
	_movement()
	_water_bob(delta)
	_aiming(delta)
	
	move_and_slide()

func _notification(what: int) -> void:
	# Resets movement flags to 0 if window loses focus.
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT : input_flags = 0

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

func _throw_bobber() -> void:
	if active_bobber_count < bobber_limit:
		active_bobber_count += 1
		var bobber = bobber_scene.instantiate()
