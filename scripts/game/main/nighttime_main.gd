extends Control
class_name NighttimeMain

## Audio exports
@export_category("Audio")
@export var default_bgm : AudioStream
@export var scavange_sfx: AudioStream
@export var scavange_bucket_empty_sfx: AudioStream
@export var sleeping_sfx: AudioStream

@export_category("Children Nodes")
@export var _jeremy_node: MainCharacter
@export var _house_trigger: CampInteractable
@export var _campfire_trigger: CampInteractable
@export var _felix_trigger: CampInteractable
@export var _scavange_trigger: CampInteractable
@export var _baitmonger_trigger: CampInteractable
@export var _food_stall_trigger: CampInteractable
@export var hud : HUD
@export var scavange_label : Label

var shop_save_data : Dictionary[ShopPopup.SHOP_TYPE_FLAGS, Array] = {}
var scavange: int = -1

func _ready() -> void:
	_sell_all_fish()
	_prepare_scavange_bucket()
		
	# Bind Signals
	SignalBus.start_bait_shop.connect(_start_bait_shop)
	SignalBus.shop_closed.connect(_save_shop_data)
	
	AudioEngine.play_bgm(default_bgm)
	
	await hud.fade_in().finished
	await _jeremy_node.walk_up_sequence()
	
	_check_shops()
	_check_win_condition()
	
	SystemData.camp_day = SystemData.get_day()


func _check_shops() -> void:
	_house_trigger.set_interactable_enabled(true)
	_campfire_trigger.set_interactable_enabled(true)
	_felix_trigger.set_interactable_enabled(true)
	_scavange_trigger.set_interactable_enabled(SystemData.license >= 2)
	_baitmonger_trigger.set_interactable_enabled(SystemData.license >= 2)
	_food_stall_trigger.set_interactable_enabled(SystemData.license >= 3)


func _check_win_condition() -> void:
	if SystemData.winner_screen_shown:
		return
	match SystemData.license:
		1, 2:
			if SystemData.get_money() >= SystemData.calculate_goal():
				GameManager.show_popup(BasePopup.POPUP_TYPE.WINNER)
		3: 
			if SystemData.boss_defeated:
				GameManager.show_popup(BasePopup.POPUP_TYPE.WINNER)


func _sell_all_fish() -> void:
	SystemData._transfer_money()
	SystemData._clear_fish_inventory()

func sleep_and_return_to_day() -> void:
	if PlayManager.get_current_state() is SleepingState:
		return
	
	if !PlayManager.request_sleeping_state():
		return
	
	AudioEngine.play_sfx(sleeping_sfx)
	AudioEngine.stop_bgm(8.0)
	await hud.fade_to_black(4.0).finished
	
	TimeManager._advance_time(8.0, true)
	SystemData.add_stamina(50.0)
	SystemData.camp_scavange = scavange
	
	if PlayManager.request_idle_day_state():
		GameManager.change_scene_deferred(GameManager.daytime_scene)


func leave_camp_to_day() -> void:
	TimeManager._advance_time(1.0, true)
	
	if PlayManager.request_sleeping_state():
		PlayManager.request_idle_day_state()
		GameManager.change_scene_deferred(GameManager.daytime_scene)


func _prepare_scavange_bucket() -> void:
	if SystemData.get_day() > SystemData.camp_day:
		SystemData.camp_scavange = 3
	scavange = SystemData.camp_scavange
	
	_update_bucket()


func use_scavenge_pile() -> void:
	if scavange > 0:
		AudioEngine.play_sfx(scavange_sfx)
		scavange -= 1
		
		var luck = randf_range(0.0, 1.0)
		if luck > 0.99: SystemData._add_bait(1, 5)
		if luck > 0.9: SystemData._add_bait(1, 1)
		if luck > 0.5: SystemData._add_bait(1, 1)
		if luck > 0.2: SystemData._add_bait(1, 1)
	
	_update_bucket()

func _update_bucket() -> void:
	var scavenge_pile := get_node_or_null("ScavangePile") as Area2D
	if scavenge_pile and scavange <= 0:
		scavenge_pile.rotation_degrees = 90
	
	var label := get_node_or_null("ScavangePile/Scavange") as Label
	if label:
		label.text = "Scavange attempts left: %d" % scavange

func talk_to_baitmonger() -> void:
	show_dialogue(0002)

func _start_bait_shop() -> void:
	var popup_parameters = {
		"shop_type" = ShopPopup.SHOP_TYPE_FLAGS.BAIT,
		"save_data" = shop_save_data.get(ShopPopup.SHOP_TYPE_FLAGS.BAIT, [])
	}
	
	GameManager.clear_popup_queue()
	if PlayManager.request_shopping_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.SHOP, popup_parameters)
		


func _save_shop_data(save_data : Array[Dictionary], shop_type : ShopPopup.SHOP_TYPE_FLAGS) -> void:
	shop_save_data.set(shop_type, save_data)

func _on_button_pressed() -> void:
	SystemData._add_money(200.0)


func use_campfire_meal() -> void:
	if !SystemData.can_use_campfire():
		show_dialogue(0106)
		return
	
	TimeManager._advance_time(0.5, true)
	SystemData.add_stamina(25.0)
	SystemData.mark_campfire_used(6.0)
	show_dialogue(0105)

func show_dialogue(dialogue_id: int) -> void:
	var popup_parameters = {
		"dialogue_id" = dialogue_id,
	}
	
	if PlayManager.request_dialogue_night_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.DIALOGUE, popup_parameters)
