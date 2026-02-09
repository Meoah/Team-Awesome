extends Node2D

@export var fishingMinigameScene : PackedScene

#TODO Make these their own class and animate from their own scripts
@export var MC : Sprite2D
@export var bobber_scene : PackedScene
@export var info : Label #Temp
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
var bobber : RigidBody2D

func _ready() -> void:
	_update_info()
	MCOriginY = MC.global_position.y
	fishTimer = randf() * 5
	bobber = bobber_scene.instantiate()
	
	if player_data.get_day() == 1 && player_data.get_week() == 1:
		player_data._add_bait("generic", 5)

func _process(delta: float) -> void:
	timeSinceCast += delta
	boatTimer += delta
	#TODO Don't leave this here, figure out when to update later
	_update_info()
	
	
	if Input.is_action_just_pressed("ui_accept") && !bobberActive && player_data.use_bait("generic"):
		bobber.global_position = MC.global_position + Vector2(0,-50)
		bobber.apply_impulse(Vector2(500,-500))
		add_child(bobber)
		move_child(bobber, 3)
		bobberActive = true
	
	#Placeholder bobber animation
	if bobberActive && bobber.is_freeze_enabled():
		bobTime += delta
		bobber.global_position.y = bobOriginY + sin(bobTime * 5.0) * 2.5
		
	if bobberInWater && timeSinceCast >= fishTimer && !fishReady:
		fishReady = true
		Indicator.global_position = bobber.global_position + Vector2(0,-150)
		bobber.set_freeze_enabled(false)
		
	if fishReady && Input.is_action_just_pressed("ui_accept"):
		Indicator.global_position = Vector2(-100,-100)
		$FISH.play("FISH!") #Plays FISH! Animation
		await $FISH.animation_finished
		fishReady = false
		bobberInWater = false
		bobberActive = false
		bobber.queue_free()
		bobber = bobber_scene.instantiate()
		if fishingMinigameScene:
			GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.ARROWUI, {"flags" = BasePopup.POPUP_FLAG.WILL_PAUSE})
		
			
	MC.global_position.y = MCOriginY + sin(boatTimer * 4.0) * 2.0

#TODO move this elsewhere
func calculate_rent() -> float:
	var base : float = 100.0
	var growth : float = 1.15
	
	var rent : float = base * pow(growth, player_data.get_week() - 1)
	return rent

#TODO delete this when hud is functional
func _update_info() -> void:
	var info_string : String = ""
	var bait_inv : Dictionary = player_data.get_bait_inventory()
	
	info_string += "Money: $%.2f\n" % player_data.get_money()
	info_string += "Rent: $%.2f\n" % calculate_rent()
	info_string += "Week: %d\n" % player_data.get_week()
	info_string += "Day: %d\n" % player_data.get_day()
	info_string += "\nBait count\n-------------\n"
	for each in bait_inv:
		info_string += "%s: %d\n" % [each, bait_inv[each]]
	
	info.text = info_string

func is_can_fish() -> bool:
	for each in player_data.bait_inventory:
		if player_data.bait_inventory[each] != 0:
			return true
	return false

func _end_day() -> void:
	GameManager.change_scene_deferred(GameManager.nighttime_scene)

func _on_water_body_entered(body: Node2D) -> void:
	if body == bobber && !bobberInWater:
		bobberInWater = true
		timeSinceCast = 0
		call_deferred("_bobber_on_water")
		

func _bobber_on_water() -> void:
	bobber.set_linear_velocity(Vector2.ZERO)
	bobOriginY = bobber.global_position.y
	bobber.set_freeze_enabled(true)


func _on_fish_animation_finished(_anim_name: StringName) -> void:
	$FISH.stop(true)
	$FISH.seek(0)


func _on_button_pressed():
	_end_day()
