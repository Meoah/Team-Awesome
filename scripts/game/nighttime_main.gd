extends Node2D

@export var info : Label

var scavange : int = 0

func _on_buy_bait_pressed() -> void:
	if player_data.spend_money(15.0):
		player_data._add_bait("generic", 10)

func _on_sleep_pressed() -> void:
	if player_data.get_day() == 5:
		if !player_data.spend_money(calculate_rent()):
			$Control.visible = true
			return
	
	player_data._next_day()
	GameManager.change_scene_deferred(GameManager.daytime_scene)

func _ready() -> void:
	scavange = 0
	if player_data.get_day() == 5:
		$Sleep.text = "Pay rent or die"

func _process(_delta) -> void:
	_update_info()

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


func _on_ded_pressed():
	player_data._reset_all()
	GameManager.request_main_menu()


func _on_scavenge_pressed() -> void:
	if scavange < 3:
		scavange += 1
		player_data._add_bait("generic", 1)
		if scavange >= 3:
			$Scavenge.visible = false
