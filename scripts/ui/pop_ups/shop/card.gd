extends Control
class_name Card

var card_name : String = ""
var card_image : NodePath = ""
var card_type : String = ""
var card_cost : float = -1.0
var card_cost_type : String = "$"
var card_quantity : int = 1
var card_description : String = ""

var item_type : String = ""
var item_id : int = 0

func _ready() -> void:
	_refresh_all()

func _set_item(incoming_type : String, incoming_id : int) -> void:
	item_type = incoming_type
	item_id = incoming_id
	_set_parameters(ItemData.get_data(item_type, item_id))

func _set_parameters(data : Dictionary = {}) -> void:
	card_name = data.get(ItemData.KEY_NAME, card_name)
	card_image = data.get(ItemData.KEY_IMAGE, card_image)
	card_type = data.get(ItemData.KEY_TYPE, card_type)
	card_description = data.get(ItemData.KEY_DESCRIPTION, card_description)
	if data.has(ItemData.KEY_QUANTITY_MIN) || data.has(ItemData.KEY_QUANTITY_MAX) : _set_quantity(data)
	if data.has(ItemData.KEY_COST) : _set_cost(data)
	
	_refresh_all()

# Sets the quantity of the item.
func _set_quantity(data : Dictionary) -> void:
	# Finds the minimum and maximum allowed values.
	var quantity_min : int = data.get(ItemData.KEY_QUANTITY_MIN, 1)
	var quantity_max : int = data.get(ItemData.KEY_QUANTITY_MAX, 1)
	
	# Minimum must be at least 1
	quantity_min = max(1, quantity_min)
	
	# Maximum cannot be smaller than minimum
	quantity_max = max(quantity_min, quantity_max)
	
	# Randomly choose between the minimum and maximum and set that as the quantity.
	card_quantity = randi_range(quantity_min, quantity_max)

# Sets the cost of the item.
func _set_cost(data : Dictionary) -> void:
	# Since cost type only matters if there exists a cost, set it here.
	card_cost_type = data.get(ItemData.KEY_COST_TYPE, card_cost_type)
	
	# Gets the base cost.
	var base_cost : float = data.get(ItemData.KEY_COST, 0.0)
	
	# Stability (0..1) into variance.
	var stability : float = float(data.get(ItemData.KEY_COST_STABILITY, 0.9))
	stability = clamp(stability, 0.0, 1.0)
	var variance : float = 1.0 - stability
	
	# Randomizes the cost according to +/- the variance by a percentage.
	var multiplier : float = randf_range(1.0 - variance, 1.0 + variance)
	card_cost = base_cost * multiplier
	
	# Finally, multiply the cost by the quantity.
	card_cost *= card_quantity

func _refresh_all() -> void:
	_refresh_type()
	_refresh_name()
	_refresh_image()
	_refresh_quantity()
	_refresh_cost()

@export var card_type_panel : PanelContainer
@export var card_type_label : RichTextLabel
func _refresh_type() -> void:
	if !card_type:
		card_type_panel.visible = false
		return
	
	card_type_label.text = card_type

@export var card_name_label : RichTextLabel
func _refresh_name() -> void:
	if card_name : card_name_label.text = card_name

@export var card_image_texture_rect : TextureRect
func _refresh_image() -> void:
	if card_image : card_image_texture_rect.texture = load(card_image)

@export var card_quantity_panel : PanelContainer
@export var card_quantity_label : RichTextLabel
func _refresh_quantity() -> void:
	if card_quantity <= 1:
		card_quantity_panel.visible = false
		return
	
	card_quantity_label.text = "x %d" % card_quantity

# Handles the cost window.
@export var card_cost_panel : PanelContainer
@export var card_cost_label : RichTextLabel
func _refresh_cost() -> void:
	# If the cost is negative, don't display the window.
	if card_cost < 0:
		card_cost_panel.visible = false
		return
	card_cost_panel.visible = true
	
	# If cost is 0, it's free.
	if card_cost == 0.0:
		card_cost_label.text = "FREE!!"
		return
	
	# Prefixes or suffixes the cost by type.
	var final_cost_string : String = ""
	match card_cost_type:
		"$":
			final_cost_string += "$ "
			final_cost_string += "%.2f" % card_cost
		_:
			final_cost_string = "%.2f" % card_cost
	
	card_cost_label.text = final_cost_string

# Handles what happens when item is purchased.
const PURCHASED_ITEM_CATEGORY : String = "item_category"
const PURCHASED_ITEM_ID : String = "item_id"
const PURCHASED_ITEM_QUANTITY : String = "item_quantity"
func _card_purchased() -> void:
	var purchased_card_info : Dictionary = {
		PURCHASED_ITEM_CATEGORY : item_type,
		PURCHASED_ITEM_ID : item_id,
		PURCHASED_ITEM_QUANTITY : card_quantity
	}
	
	SignalBus.card_purchased.emit(purchased_card_info)

# TODO Make the card play a failure animation.
func _failed_purchase() -> void:
	pass

# Saves the current data.
const SAVED_ITEM_CATEGORY : String = "item_category"
const SAVED_ITEM_ID : String = "item_id"
const SAVED_ITEM_NAME : String = "card_name"
const SAVED_ITEM_IMAGE : String = "card_image"
const SAVED_ITEM_TYPE : String = "card_type"
const SAVED_ITEM_COST : String = "card_cost"
const SAVED_ITEM_COST_TYPE : String = "card_cost_type"
const SAVED_ITEM_QUANTITY : String = "card_quantity"
const SAVED_ITEM_DESCRIPTION : String = "card_description"
func _package_save_data() -> Dictionary:
	return {
		SAVED_ITEM_CATEGORY : item_type,
		SAVED_ITEM_ID : item_id,
		SAVED_ITEM_NAME : card_name,
		SAVED_ITEM_IMAGE : card_image,
		SAVED_ITEM_TYPE : card_type,
		SAVED_ITEM_DESCRIPTION : card_description,
		SAVED_ITEM_COST : card_cost,
		SAVED_ITEM_COST_TYPE : card_cost_type,
		SAVED_ITEM_QUANTITY : card_quantity,
	}

# Loads the saved parameters.
func _reload_parameters(save_data : Dictionary = {}) -> void:
	item_type = save_data.get(SAVED_ITEM_CATEGORY, item_type)
	item_id = save_data.get(SAVED_ITEM_ID, item_id)
	card_name = save_data.get(SAVED_ITEM_NAME, card_name)
	card_image = save_data.get(SAVED_ITEM_IMAGE, card_image)
	card_type = save_data.get(SAVED_ITEM_TYPE, card_type)
	card_description = save_data.get(SAVED_ITEM_DESCRIPTION, card_description)
	card_cost_type = save_data.get(SAVED_ITEM_COST_TYPE, card_cost_type)
	card_cost = save_data.get(SAVED_ITEM_COST, card_cost)
	card_quantity = save_data.get(SAVED_ITEM_QUANTITY, card_quantity)
	
	_refresh_all()
