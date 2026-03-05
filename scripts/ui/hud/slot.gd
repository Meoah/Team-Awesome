extends PanelContainer
class_name Slot

@onready var icon_rect = $Icon
@onready var count_label = $Icon/CountLabel

var saved_data : Dictionary = {}
var saved_item_id : int = 0

## Listens for clicks and emits a signal if detected.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		SignalBus.slot_left_clicked.emit(self)
		accept_event()

## Sets the slot's quantity and texture according to the incoming data.
func set_slot(data : Dictionary, quantity : int = 1, item_id : int = -1):
	# If data exists, save it to this object, otherwise abort.
	if !data : return
	saved_data = data
	if item_id > 0 : saved_item_id = item_id
	
	# Loads the image if it exists.
	var image_path = saved_data.get("image", "")
	if image_path : icon_rect.texture = load(image_path)
	
	# Only show count if count is > 1.
	if quantity > 1:
		count_label.text = str(quantity)
		count_label.show()
	else:
		count_label.hide()
