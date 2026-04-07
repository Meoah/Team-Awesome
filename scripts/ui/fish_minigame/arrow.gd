extends Control
class_name Arrow

enum Directions{
	LEFT,
	UP,
	DOWN,
	RIGHT
}

enum ArrowType{
	NORMAL,
	GOLD,
	EVIL,
	OBSCURED,
	HEALING,
}

const OPPOSITE_DIRECTION: Dictionary[Directions,Directions] = {
	Directions.LEFT:	Directions.RIGHT,
	Directions.UP:		Directions.DOWN,
	Directions.DOWN:	Directions.UP,
	Directions.RIGHT:	Directions.LEFT
}

@export_category("Children Nodes")
@export var _arrow_texture: TextureRect
@export var _smoke_vfx: Sprite2D
@export_category("Textures")
@export var _left_arrow_texture: Texture
@export var _up_arrow_texture: Texture
@export var _down_arrow_texture: Texture
@export var _right_arrow_texture: Texture

# Public Variables
var direction: Directions
var arrow_type: ArrowType

# Animation state
var _base_color: Color = Color.WHITE
var _base_scale: Vector2 = Vector2.ONE
var _base_pos: Vector2 = Vector2.ZERO

var _visual_tween: Tween
var _shake_tween: Tween


func _ready() -> void:
	_apply_type()
	_apply_direction()
	
	_base_color = _arrow_texture.self_modulate
	_base_scale = _arrow_texture.scale
	_base_pos = _arrow_texture.position


func _apply_type() -> void:
	match arrow_type:
		ArrowType.GOLD:
			_arrow_texture.self_modulate = Color.GOLD
		ArrowType.EVIL:
			_arrow_texture.self_modulate = Color.RED
			direction = OPPOSITE_DIRECTION.get(direction)


func _apply_direction() -> void:
	match direction:
		Directions.LEFT:	_arrow_texture.texture = _left_arrow_texture
		Directions.UP:		_arrow_texture.texture = _up_arrow_texture
		Directions.DOWN:	_arrow_texture.texture = _down_arrow_texture
		Directions.RIGHT:	_arrow_texture.texture = _right_arrow_texture


func _stop_visual_tween() -> void:
	if _visual_tween:
		_visual_tween.kill()
		_visual_tween = null


func _stop_shake_tween() -> void:
	if _shake_tween:
		_shake_tween.kill()
		_shake_tween = null
	_arrow_texture.position = _base_pos


func correct() -> void:
	_stop_visual_tween()
	_stop_shake_tween()
	
	_arrow_texture.position = _base_pos
	_arrow_texture.scale = _base_scale
	_arrow_texture.self_modulate = Color.LIME_GREEN
	
	var faded_color: Color = _arrow_texture.self_modulate
	faded_color.a = 0.0
	
	_visual_tween = create_tween()
	_visual_tween.tween_property(_arrow_texture, "scale", Vector2.ZERO, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_visual_tween.parallel().tween_property(_arrow_texture, "self_modulate", faded_color, 0.12)
	_visual_tween.tween_callback(_arrow_texture.hide)


func erase() -> void:
	_stop_visual_tween()
	_stop_shake_tween()
	
	_arrow_texture.position = _base_pos
	
	var faded_color: Color = _arrow_texture.self_modulate
	faded_color.a = 0.0
	
	_visual_tween = create_tween()
	_visual_tween.tween_property(_arrow_texture, "scale", _base_scale * 0.2, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_visual_tween.parallel().tween_property(_arrow_texture, "self_modulate", faded_color, 0.10)
	
	_visual_tween.tween_callback(_arrow_texture.hide)


func incorrect() -> void:
	_stop_visual_tween()
	shake()
	
	_visual_tween = create_tween()
	_visual_tween.tween_property(_arrow_texture, "self_modulate", Color.RED, 0.05)
	_visual_tween.tween_property(_arrow_texture, "self_modulate", _base_color, 0.10)
	_visual_tween.tween_property(_arrow_texture, "self_modulate", Color.RED, 0.05)
	_visual_tween.tween_property(_arrow_texture, "self_modulate", _base_color, 0.10)


func shake() -> void:
	_stop_shake_tween()
	_arrow_texture.position = _base_pos
	
	_shake_tween = create_tween()
	_shake_tween.tween_property(_arrow_texture, "position", _base_pos + Vector2(-10, 0), 0.08)
	_shake_tween.tween_property(_arrow_texture, "position", _base_pos + Vector2(10, 0), 0.08)
	_shake_tween.tween_property(_arrow_texture, "position", _base_pos + Vector2(-8, 0), 0.05)
	_shake_tween.tween_property(_arrow_texture, "position", _base_pos + Vector2(8, 0), 0.05)
	_shake_tween.tween_property(_arrow_texture, "position", _base_pos, 0.04)
