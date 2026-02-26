extends Node2D
class_name DaytimeMain

## Node exports
@export var jeremy_node : MainCharacter
@export var bobber_scene : PackedScene
@export var info : Label #Temp

func _ready() -> void:
	PlayManager.request_idle_day_state()
	_update_info()
	
	if SystemData.get_day() == 1 && SystemData.get_week() == 1:
		SystemData._add_bait("generic", 5)

func _process(_delta: float) -> void:
	#TODO Don't leave this here, figure out when to update later
	_update_info()

#TODO move this elsewhere
func calculate_rent() -> float:
	var base : float = 100.0
	var growth : float = 1.15
	
	var rent : float = base * pow(growth, SystemData.get_week() - 1)
	return rent

#TODO delete this when hud is functional
func _update_info() -> void:
	var info_string : String = ""
	var bait_inv : Dictionary = SystemData.get_bait_inventory()
	
	info_string += "Money: $%.2f\n" % SystemData.get_money()
	info_string += "Rent: $%.2f\n" % calculate_rent()
	info_string += "Week: %d\n" % SystemData.get_week()
	info_string += "Day: %d\n" % SystemData.get_day()
	info_string += "\nBait count\n-------------\n"
	for each in bait_inv:
		info_string += "%s: %d\n" % [each, bait_inv[each]]
	
	info.text = info_string

func is_can_fish() -> bool:
	for each in SystemData.bait_inventory:
		if SystemData.bait_inventory[each] != 0:
			return true
	return false

func _end_day() -> void:
	if PlayManager.request_idle_night_state():
		GameManager.change_scene_deferred(GameManager.nighttime_scene)

func _play_minigame() -> void:
	$FISH.play("FISH!") #Plays FISH! Animation
	await $FISH.animation_finished
	var popup_parameters = {
		"flags" = BasePopup.POPUP_FLAG.WILL_PAUSE
	}
	GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.MINIGAMEUI, popup_parameters)

func _on_fish_animation_finished(_anim_name: StringName) -> void:
	$FISH.stop(true)
	$FISH.seek(0)

func _on_button_pressed():
	_end_day()


func _on_debug_pressed() -> void:
	var popup_parameters = {
		"dialogue_id" = 0,
		"flags" = BasePopup.POPUP_FLAG.DISMISS_ON_ESCAPE
	}
	if PlayManager.request_dialogue_day_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.DIALOGUE, popup_parameters)
