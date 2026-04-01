extends Control
class_name HUDController

@export_category("Node Exports")
@export var fish_inventory : PanelContainer
@export var bait_inventory : PanelContainer
@export var rod_slot : Slot
@export var reel_slot : Slot
@export var lure_slot : Slot
@export var exotic_slot : Slot
@export var active_bait_slot : Slot
@export var active_bait_label : RichTextLabel
@export var money_label : MoneyLabel
@export var rent_label : RichTextLabel
@export var fish_bucket_value_label : Label
@export var day_label : Label
@export var week_label : Label

@export_category("Audio")
@export var receiving_money_sfx: AudioStream
@export var hover_sfx: AudioStream
@export var confirm_sfx: AudioStream

# Fadeout Consts
const FADE_DELAY_SECONDS: float = 2.0
const FADE_DURATION_SECONDS: float = 1.0
const HOVER_ALPHA: float = 1.0
const IDLE_ALPHA: float = 0.6

var fade_timer: Timer
var fade_tween: Tween

var current_money : float = 0.0

func _ready() -> void:
	# Bind Signals
	SystemData.inventory_updated.connect(_refresh_ui)
	SignalBus.slot_left_clicked.connect(_on_slot_left_clicked)
	
	# Initial setup.
	_fadeout_timer_setup()
	current_money = SystemData.get_money()
	
	# Waits for other system setup to finish, then refresh ui once.
	await get_tree().process_frame
	_refresh_ui()
	money_label._setup()

func _input(event : InputEvent) -> void:
	if PlayManager.get_current_state() is ShoppingState : return
	# Hover detection, updates the tooltip location if any part of the hud is hovered.
	if event is InputEventMouseMotion:
		var hovered : Control = get_viewport().gui_get_hovered_control()
		var tooltip_layer = GameManager.get_tooltip_layer()
		var is_valid_hover : bool = hovered \
			&& hovered.is_visible_in_tree() \
			&& hovered.mouse_filter != Control.MOUSE_FILTER_IGNORE \
			&& is_ancestor_of(hovered)
		
		if is_valid_hover:
			_tooltip(hovered, tooltip_layer)
			_set_hovered_state()
		else:
			tooltip_layer._hide_tooltip()
			_set_unhovered_state()

## Attempts to pull up tooltip data from hovered object, then displays it if it exists.
func _tooltip(hovered : Control, tooltip_layer : TooltipLayer) -> void:
	var mouse_position : Vector2 = get_viewport().get_mouse_position()
	tooltip_layer._update_tooltip_position(mouse_position)
	if hovered is Slot:
		var description : String = hovered.saved_data.get(ItemData.KEY_DESCRIPTION, "")
		tooltip_layer._show_tooltip(mouse_position, description)
	else : tooltip_layer._hide_tooltip()

## Refreshes each module.
func _refresh_ui() -> void:
	# Forces the fadeout to reset. TODO: Do we want this?
	#_set_hovered_state()
	#_set_unhovered_state()
	
	_update_equipment()
	_update_active_bait()
	_update_money()
	_update_weekday()

## Sets the slots of each equipment.
func _update_equipment() -> void:
	# TODO change this system when graphics are in.
	var equipment : Dictionary = SystemData.get_all_upgrades()
	rod_slot.set_slot(equipment.get(ItemData.ROD, {}))
	reel_slot.set_slot(equipment.get(ItemData.REEL, {}))
	lure_slot.set_slot(equipment.get(ItemData.LURE, {}))
	exotic_slot.set_slot(equipment.get(ItemData.EXOTIC, {}))

## Sets the active bait slot.
func _update_active_bait() -> void:
	var active_bait : int = SystemData.get_active_bait()
	var active_bait_quantity : int = SystemData.get_active_bait_count()
	var active_bait_data : Dictionary = ItemData.get_data(ItemData.BAIT, active_bait)
	
	active_bait_slot.set_slot(active_bait_data, active_bait_quantity)
	active_bait_label.text = active_bait_data.get(ItemData.KEY_NAME, "Nothing")

## Sets current money and rent.
func _update_money() -> void:
	var new_money: float = SystemData.get_money()
	var delta_money: float = new_money - current_money
	if delta_money > 0:
		var shake_strength : float = log(1.0 + delta_money)
		money_label.trigger_impact(shake_strength, true, Color(0.0, 0.75, 0.0, 1.0))
		AudioEngine.play_sfx(receiving_money_sfx)
	if new_money < current_money:
		var shake_strength : float = log(1.0 + abs(delta_money))
		if new_money < 10.0 : money_label.trigger_impact(shake_strength, true, Color(0.75, 0.0, 0.0, 1.0))
		else : money_label.trigger_impact(shake_strength, false)
	
	current_money = new_money
	money_label.text = "$%.2f" % current_money
	rent_label.text = "[color=red]$%.2f[/color]" % SystemData.calculate_rent()
	fish_bucket_value_label.text = "Total Value: $%.2f" % SystemData.get_delayed_money()

## Sets day and week.
func _update_weekday() -> void:
	day_label.text = "Day %d / 5" % SystemData.get_day()
	week_label.text = "Week %d" % SystemData.get_week()

## Sets up a timer for the fadeout.
func _fadeout_timer_setup() -> void:
	fade_timer = Timer.new()
	fade_timer.one_shot = true
	fade_timer.wait_time = FADE_DELAY_SECONDS
	fade_timer.timeout.connect(_on_fade_timer_timeout)
	add_child(fade_timer)

## Cancels the fade timer and sets the alpha back.
func _set_hovered_state() -> void:
	if fade_timer.time_left > 0.0 : fade_timer.stop()
	
	if fade_tween:
		fade_tween.kill()
		fade_tween = null
	
	modulate.a = HOVER_ALPHA

## Begins the timer if it's stopped.
func _set_unhovered_state() -> void:
	if fade_timer.time_left <= 0.0 : fade_timer.start()

func _on_slot_left_clicked(hovered: Slot) -> void:
	if hovered.get_parent() is not InventoryGrid: return
	if hovered.saved_data.has(ItemData.KEY_TYPE) && hovered.saved_data[ItemData.KEY_TYPE] == ItemData.BAIT:
		AudioEngine.play_sfx(confirm_sfx)
		SystemData.set_active_bait(hovered.saved_item_id)

## Signal connected function to trigger fadeout.
func _on_fade_timer_timeout() -> void:
	_fade_to_alpha(IDLE_ALPHA)

## Sets a tween to execute the fadeout.
func _fade_to_alpha(target_alpha: float) -> void:
	if fade_tween:
		fade_tween.kill()
		fade_tween = null
	
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", target_alpha, FADE_DURATION_SECONDS)

## Flips the fish inventory visibility and turns off the rest.
func _on_fish_dropdown_pressed() -> void:
	AudioEngine.play_sfx(confirm_sfx)
	fish_inventory.visible = !fish_inventory.visible
	bait_inventory.visible = false

## Flips the bait inventory visibility and turns off the rest.
func _on_bait_dropdown_pressed() -> void:
	AudioEngine.play_sfx(confirm_sfx)
	bait_inventory.visible = !bait_inventory.visible
	fish_inventory.visible = false


func _on_texture_button_pressed() -> void:
	GameManager.show_popup(BasePopup.POPUP_TYPE.PAUSE)


func _on_button_mouse_entered() -> void:
	AudioEngine.play_sfx(hover_sfx)
