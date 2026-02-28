extends Control
class_name NighttimeMain

## Audio exports
@export_file_path("*.wav") var default_bgm_path

@export var jeremy_node : MainCharacter
@export var house_trigger : Area2D
@export var bucket_trigger : Area2D
@export var shop_trigger : Area2D
@export var upgrade_trigger : Area2D
@export var tarot_trigger : Area2D

@export var house_label : Label

var shop_save_data : Dictionary[ShopPopup.SHOP_TYPE_FLAGS, Array] = {}

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
	_sell_all_fish()
	if SystemData.get_day() == 5:
		house_label.text = "PAY RENT OR DIE"
		
	# Bind Signals
	jeremy_node.player_interact.connect(_interaction)
	SignalBus.start_bait_shop.connect(_start_bait_shop)
	SignalBus.shop_closed.connect(_save_shop_data)
	
	AudioEngine.play_bgm(default_bgm_path)

func _interaction() -> void:
	if house_trigger.overlaps_body(jeremy_node) : _sleep()
	if bucket_trigger.overlaps_body(jeremy_node) : _bucket()
	if shop_trigger.overlaps_body(jeremy_node) : _bait_shop()
	if upgrade_trigger.overlaps_body(jeremy_node) : _upgrade_shop()
	if tarot_trigger.overlaps_body(jeremy_node) : _tarot_shop()


#TODO move this elsewhere
func calculate_rent() -> float:
	var base : float = 100.0
	var growth : float = 1.15
	
	var rent : float = base * pow(growth, SystemData.get_week() - 1)
	return rent

func _sell_all_fish() -> void:
	SystemData._transfer_money()
	SystemData._clear_fish_inventory()

func _sleep() -> void:
	if SystemData.get_day() == 5:
		if !SystemData.spend_money(calculate_rent()):
			SignalBus.player_dies.emit()
			return
	if PlayManager.request_sleeping_state():
		if PlayManager.request_idle_day_state():
			SystemData._next_day()
			GameManager.change_scene_deferred(GameManager.daytime_scene)

@export var scavange_label : Label
var scavange : int = 3
func _bucket() -> void:
	if scavange > 0:
		scavange -= 1
		scavange_label.text = "Scavange attempts left: %d" % scavange
		var luck = randf_range(0.0, 1.0)
		if luck > 0.99 : SystemData._add_bait("Generic Bait", 5)
		if luck > 0.9 : SystemData._add_bait("Generic Bait", 1)
		if luck > 0.5 : SystemData._add_bait("Generic Bait", 1)
		if luck > 0.2 : SystemData._add_bait("Generic Bait", 1)
	if scavange <= 0:
		bucket_trigger.rotation_degrees = 90

func _bait_shop() -> void:
	var popup_parameters = {
		"dialogue_id" = 0002,
	}
	if PlayManager.request_dialogue_night_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.DIALOGUE, popup_parameters)

func _start_bait_shop() -> void:
	var popup_parameters = {
		"shop_type" = ShopPopup.SHOP_TYPE_FLAGS.BAIT,
		"save_data" = shop_save_data.get(ShopPopup.SHOP_TYPE_FLAGS.BAIT, [])
	}
	
	GameManager.clear_popup_queue()
	if PlayManager.request_shopping_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.SHOP, popup_parameters)
		
func _upgrade_shop() -> void:
	_start_upgrade_shop()

func _start_upgrade_shop() -> void:
	var popup_parameters = {
		"shop_type" = ShopPopup.SHOP_TYPE_FLAGS.UPGRADE,
		"save_data" = shop_save_data.get(ShopPopup.SHOP_TYPE_FLAGS.UPGRADE, [])
	}
	
	GameManager.clear_popup_queue()
	if PlayManager.request_shopping_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.SHOP, popup_parameters)

func _tarot_shop() -> void:
	_start_tarot_shop()

func _start_tarot_shop() -> void:
	var popup_parameters = {
		"shop_type" = ShopPopup.SHOP_TYPE_FLAGS.TAROT,
		"save_data" = shop_save_data.get(ShopPopup.SHOP_TYPE_FLAGS.TAROT, [])
	}
	
	GameManager.clear_popup_queue()
	if PlayManager.request_shopping_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.SHOP, popup_parameters)

func _save_shop_data(save_data : Array[Dictionary], shop_type : ShopPopup.SHOP_TYPE_FLAGS) -> void:
	shop_save_data.set(shop_type, save_data)

func _on_button_pressed() -> void:
	SystemData._add_money(200.0)
