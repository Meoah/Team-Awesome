extends Control
class_name NighttimeMain

@export var info : Label
@export var jeremy_node : MainCharacter
@export var house_node : Area2D
@export var shop_node : Area2D

@export var shop_ui : Control
@export var sleep_ui : Control

var scavange : int = 0

func _on_buy_bait_pressed() -> void:
	if SystemData.spend_money(15.0):
		SystemData._add_bait("generic", 10)

func _on_sleep_pressed() -> void:
	if SystemData.get_day() == 5:
		if !SystemData.spend_money(calculate_rent()):
			SignalBus.player_dies.emit()
			return
	if PlayManager.request_sleeping_state():
		print("Sleepin")
		if PlayManager.request_idle_day_state():
			SystemData._next_day()
			GameManager.change_scene_deferred(GameManager.daytime_scene)

func _ready() -> void:
	scavange = 0
	_sell_all_fish()
	if SystemData.get_day() == 5:
		$Sleep.text = "Pay rent or die"
	jeremy_node.player_interact.connect(_interaction)

func _process(_delta) -> void:
	_update_info()

func _interaction() -> void:
	if shop_node.overlaps_body(jeremy_node):
		if shop_ui.visible : shop_ui.visible = false
		else : shop_ui.visible = true
	if house_node.overlaps_body(jeremy_node):
		sleep_ui.visible = true

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

func _sell_all_fish() -> void:
	SystemData._transfer_money()
	SystemData._clear_fish_inventory()

func _on_scavenge_pressed() -> void:
	if scavange < 3:
		scavange += 1
		SystemData._add_bait("generic", 1)
		if scavange >= 3:
			$ShopUI/Scavenge.visible = false
