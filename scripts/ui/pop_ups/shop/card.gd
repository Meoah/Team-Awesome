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

signal card_purchased(purchased_card_info : Dictionary)

const PURCHASED_ITEM_TYPE : String = "item_type"

var purchased_card_info : Dictionary = {}

func _ready() -> void:
	_set_parameters(ItemData.get_data(item_type, item_id))
	_refresh_all()

func _set_item(incoming_type : String, incoming_id : int) -> void:
	item_type = incoming_type
	item_id = incoming_id

func _set_parameters(data : Dictionary = {}) -> void:
	if data.has(ItemData.KEY_NAME) : card_name = data.get(ItemData.KEY_NAME)
	if data.has(ItemData.KEY_IMAGE) : card_image = data.get(ItemData.KEY_IMAGE)
	if data.has(ItemData.KEY_TYPE) : card_type = data.get(ItemData.KEY_TYPE)
	if data.has(ItemData.KEY_QUANTITY_MIN) || data.has(ItemData.KEY_QUANTITY_MAX) : _set_quantity(data)
	if data.has(ItemData.KEY_COST) : _set_cost(data)
	if data.has(ItemData.KEY_DESCRIPTION) : card_description = data.get(ItemData.KEY_DESCRIPTION)
	_refresh_all()

# Sets the quantity of the item.
func _set_quantity(data : Dictionary) -> void:
	# Finds the minimum and maximum allowed values.
	var quantity_min : int = 1
	var quantity_max : int = 1
	if data.has(ItemData.KEY_QUANTITY_MIN) : quantity_min = data.get(ItemData.KEY_QUANTITY_MIN)
	if data.has(ItemData.KEY_QUANTITY_MAX) : quantity_max = data.get(ItemData.KEY_QUANTITY_MAX)
	
	# If maximum is ever smaller than minimum, take minimum. However, if minimum is below 1, set it to 1 anyways.
	if quantity_max <= quantity_min : card_quantity = quantity_min
	if quantity_min < 1 : card_quantity = 1
	
	# Randomly choose between the minimum and maximum and set that as the quantity.
	card_quantity = randi_range(quantity_min, quantity_max)

# Sets the cost of the item.
func _set_cost(data : Dictionary) -> void:
	# Since cost type only matters if there exists a cost, set it here.
	if data.has(ItemData.KEY_COST_TYPE) : card_cost_type = data.get(ItemData.KEY_COST_TYPE)
	
	# Determines the cost factor, which must be between 0 and 1.
	var cost_factor : float = 0.9
	if data.has(ItemData.KEY_COST_FACTOR) : cost_factor = data.get(ItemData.KEY_COST_FACTOR)
	cost_factor = clamp(cost_factor, 0.0, 1.0) - 1.0
	
	# Randomizes the cost according to +/- the factor by a percentage.
	card_cost = data.get(ItemData.KEY_COST)
	cost_factor = randf_range((1.0 - cost_factor), (1.0 + cost_factor))
	card_cost *= cost_factor
	
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
func _card_purchased() -> void:
	card_purchased.emit(purchased_card_info)
