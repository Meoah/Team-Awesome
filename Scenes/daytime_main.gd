extends Node2D

#TODO Make these instances later
@export var MC : Sprite2D
@export var Bobber : RigidBody2D

var bobberActive : bool = false

func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if !bobberActive:
			bobberActive = true
			Bobber.set_freeze_enabled(false)
			Bobber.global_position = MC.global_position
			Bobber.apply_impulse(Vector2(500,-500))


func _on_water_body_entered(body: Node2D) -> void:
	if body == Bobber:
		body.set_linear_velocity(Vector2(0,0))
		body.set_freeze_enabled(true)
