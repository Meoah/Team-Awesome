extends Node2D

@export var fishingMinigameScene : PackedScene

#TODO Make these their own class and animate from their own scripts
@export var MC : Sprite2D
@export var Bobber : RigidBody2D
@export var Score : Label
@export var Indicator : Sprite2D

var timeSinceCast : float = 0.0
var bobberActive : bool = false
var bobberInWater : bool = false
var fishReady : bool = false
var fishTimer : float = 0.0
var boatTimer : float = 0.0

var MCOriginY : float = 0.0

#Placeholder
var bobTime : float = 0.0
var bobOriginY : float = 0.0

func _ready() -> void:
	Score.text = "Score: " + str(player_data.get_score())
	MCOriginY = MC.global_position.y
	fishTimer = randf() * 5

func _process(delta: float) -> void:
	timeSinceCast += delta
	boatTimer += delta
	#TODO Don't leave this here, figure out when to update later
	Score.text = "Score: " + str(player_data.get_score())
	
	if Input.is_action_just_pressed("ui_accept") && !bobberActive:
		bobberActive = true
		Bobber.set_freeze_enabled(false)
		Bobber.global_position = MC.global_position
		Bobber.apply_impulse(Vector2(500,-500))
	
	#Placeholder bobber animation
	if bobberActive && Bobber.is_freeze_enabled():
		bobTime += delta
		Bobber.global_position.y = bobOriginY + sin(bobTime * 5.0) * 2.5
		
	if bobberInWater && timeSinceCast >= fishTimer && !fishReady:
		fishReady = true
		Indicator.global_position = Bobber.global_position + Vector2(0,-150)
		Bobber.set_freeze_enabled(false)
		
	if fishReady && Input.is_action_just_pressed("ui_accept"):
		fishReady = false
		bobberInWater = false
		bobberActive = false
		Indicator.global_position = Vector2(-100,-100)
		$FISH.play("FISH!") #Plays FISH! Animation
		await get_tree().create_timer(1).timeout
		if fishingMinigameScene:
			var minigame = fishingMinigameScene.instantiate()
			add_child(minigame)
			
	MC.global_position.y = MCOriginY + sin(boatTimer * 4.0) * 2.0





func _on_water_body_entered(body: Node2D) -> void:
	if body == Bobber && !bobberInWater:
		bobberInWater = true
		timeSinceCast = 0
		call_deferred("_bobber_on_water")
		

func _bobber_on_water() -> void:
	Bobber.set_linear_velocity(Vector2.ZERO)
	bobOriginY = Bobber.global_position.y
	Bobber.set_freeze_enabled(true)


func _on_fish_animation_finished(_anim_name: StringName) -> void:
			$FISH.stop(true)
			$FISH.seek(0)
