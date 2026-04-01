extends RichTextLabel
class_name MoneyLabel

@export var shake_decay : float = 12.0
@export var noise_speed : float = 10.0

@export var flash_color : Color = Color(1.0, 0.2, 0.2, 1.0)
@export var flash_duration : float = 0.1

var shake_amount : float = 0.0
var time_elapsed : float = 0.0
var original_position : Vector2
var original_modulate : Color
var flash_timer : float = 0.0
var active_flash_color : Color

var noise : FastNoiseLite

func _ready() -> void:
	set_process(false)

func _setup() -> void:
	original_position = position
	original_modulate = modulate
	
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 1.0
	set_process(true)

func _process(delta : float) -> void:
	time_elapsed += delta
	
	_update_shake(delta)
	_update_flash(delta)

func trigger_impact(incoming_strength: float, should_flash: bool = true, incoming_flash_color: Color = flash_color) -> void:
	shake_amount = max(shake_amount, incoming_strength)
	
	if should_flash:
		flash_timer = flash_duration
		active_flash_color = incoming_flash_color
		modulate = active_flash_color

func _update_shake(delta : float) -> void:
	if shake_amount > 0.0:
		shake_amount = max(shake_amount - shake_decay * delta, 0.0)
		
		var noise_x : float = noise.get_noise_1d(time_elapsed * noise_speed)
		var noise_y : float = noise.get_noise_1d((time_elapsed + 100.0) * noise_speed)
		
		var strength : float = shake_amount * shake_amount
		var offset : Vector2 = Vector2(noise_x, noise_y) * strength
		
		position = original_position + offset
	else:
		position = original_position

func _update_flash(delta : float) -> void:
	if flash_timer > 0.0:
		flash_timer = max(flash_timer - delta, 0.0)
		
		if flash_duration > 0.0:
			var flash_progress : float = 1.0 - (flash_timer / flash_duration)
			modulate = active_flash_color.lerp(original_modulate, flash_progress)
		else:
			modulate = original_modulate
	else:
		modulate = original_modulate
