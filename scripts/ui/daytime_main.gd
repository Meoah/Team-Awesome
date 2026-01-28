extends Node2D

#TODO Make these instances later
@export var MC : Sprite2D
@export var Bobber : RigidBody2D

var bobberActive : bool = false

func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") && !bobberActive:
		bobberActive = true
		Bobber.freeze = false
		Bobber.global_position = MC.global_position
		Bobber.apply_impulse(Vector2(500,-500), Vector2.ZERO)


func _on_water_body_entered(body: Node2D) -> void:
	if body == Bobber:
		call_deferred("_bobber_on_water")

func _bobber_on_water() -> void:
	Bobber.linear_velocity = Vector2.ZERO
	Bobber.angular_velocity = 0.0
	Bobber.freeze = true
