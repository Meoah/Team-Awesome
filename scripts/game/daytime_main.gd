extends Node2D

@export var fishingMinigameScene : PackedScene

#TODO Make these their own class and animate from their own scripts
@export var MC : Sprite2D
@export var Bobber : RigidBody2D

var timeSinceCast : float = 0.0
var bobberActive : bool = false
var bobberInWater : bool = false
var fishReady : bool = false
var fishTimer : float = 0.0

#Placeholder
var bobTime : float = 0.0
var bobOriginY : float = 0.0

func _ready() -> void:
	fishTimer = randf() * 5

func _process(delta: float) -> void:
	timeSinceCast += delta
	if Input.is_action_just_pressed("ui_accept") && !bobberActive:
		bobberActive = true
		Bobber.set_freeze_enabled(false)
		Bobber.global_position = MC.global_position
		Bobber.apply_impulse(Vector2(500,-500))
	
	#Placeholder bobber animation
	if bobberActive && Bobber.is_freeze_enabled():
		bobTime += delta
		Bobber.global_position.y = bobOriginY + sin(bobTime * 5.0) * 2.5
		
	if bobberInWater && timeSinceCast >= fishTimer:
		fishReady = true
		Bobber.set_freeze_enabled(false)
		
	if fishReady && Input.is_action_just_pressed("ui_accept"):
		fishReady = false
		bobberInWater = false
		bobberActive = false
		if fishingMinigameScene:
			var minigame = fishingMinigameScene.instantiate()
			add_child(minigame)


func _on_water_body_entered(body: Node2D) -> void:
	if body == Bobber && !bobberInWater:
		bobberInWater = true
		timeSinceCast = 0
		call_deferred("_bobber_on_water")
		

func _bobber_on_water() -> void:
	Bobber.set_linear_velocity(Vector2.ZERO)
	bobOriginY = Bobber.global_position.y
	Bobber.set_freeze_enabled(true)
