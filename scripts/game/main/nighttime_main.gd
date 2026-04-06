extends Control
class_name NighttimeMain

## Audio exports
@export_category("Audio")
@export var default_bgm : AudioStream
@export var scavange_sfx: AudioStream
@export var scavange_bucket_empty_sfx: AudioStream
@export var sleeping_sfx: AudioStream

@export_category("Children Nodes")
@export var jeremy_node : MainCharacter
@export var house_trigger : Area2D
@export var bucket_trigger : Area2D
@export var shop_trigger : Area2D
@export var upgrade_trigger : Area2D
@export var tarot_trigger : Area2D
@export var hud : HUD

var weather_color : Color = Color.WHITE
var shop_save_data : Dictionary[ShopPopup.SHOP_TYPE_FLAGS, Array] = {}
var scavange: int = -1

func _ready() -> void:
	_sell_all_fish()
	_prepare_scavange_bucket()
		
	# Bind Signals
	jeremy_node.player_interact.connect(_interaction)
	SignalBus.start_bait_shop.connect(_start_bait_shop)
	SignalBus.shop_closed.connect(_save_shop_data)
	
	AudioEngine.play_bgm(default_bgm)
	
	await hud.fade_in(0.5).finished
	
	_check_win_condition()
	
	SystemData.camp_day = SystemData.get_day()


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


func _interaction() -> void:
	if house_trigger.overlaps_body(jeremy_node) : _sleep()
	if bucket_trigger.overlaps_body(jeremy_node) : _bucket()
	if shop_trigger.overlaps_body(jeremy_node) : _bait_shop()
	if upgrade_trigger.overlaps_body(jeremy_node) : _upgrade_shop()
	#TODO if tarot_trigger.overlaps_body(jeremy_node) : _tarot_shop()

func _sell_all_fish() -> void:
	SystemData._transfer_money()
	SystemData._clear_fish_inventory()

func _sleep() -> void:
	var final_day = 1 + (SystemData.license * 2)
	if SystemData.get_day() >= final_day:
		if SystemData.get_money() < SystemData.calculate_goal():
			SignalBus.player_dies.emit()
			return
	if PlayManager.get_current_state() is not SleepingState:
		if PlayManager.request_sleeping_state():
			AudioEngine.play_sfx(sleeping_sfx)
			AudioEngine.stop_bgm(8.0)
			await hud.fade_to_black(4.0).finished
			if PlayManager.request_idle_day_state():
				SystemData.add_stamina(50)
				SystemData._next_day()
				SystemData.camp_scavange = scavange
				GameManager.change_scene_deferred(GameManager.daytime_scene)


func _prepare_scavange_bucket() -> void:
	if SystemData.get_day() > SystemData.camp_day:
		SystemData.camp_scavange = 3
	scavange = SystemData.camp_scavange
	
	_update_bucket()

@export var scavange_label : Label
func _bucket() -> void:
	if scavange > 0:
		AudioEngine.play_sfx(scavange_sfx)
		scavange -= 1
		scavange_label.text = "Scavange attempts left: %d" % scavange
		var luck = randf_range(0.0, 1.0)
		if luck > 0.99 : SystemData._add_bait(1, 5)
		if luck > 0.9 : SystemData._add_bait(1, 1)
		if luck > 0.5 : SystemData._add_bait(1, 1)
		if luck > 0.2 : SystemData._add_bait(1, 1)
	if scavange <= 0:
		if bucket_trigger.rotation_degrees != 90:
			AudioEngine.play_sfx(scavange_bucket_empty_sfx)
		bucket_trigger.rotation_degrees = 90

func _update_bucket() -> void:
	if scavange <= 0:
		bucket_trigger.rotation_degrees = 90
	scavange_label.text = "Scavange attempts left: %d" % scavange

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
	
