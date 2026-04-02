extends GridContainer
class_name InventoryGrid

## Options
@export_category("Options")
@export_enum("Fish", "Bait", "Buff") var grid_type : String

## Scene Exports
@export_category("Scenes")
@export var slot_scene: PackedScene

func _ready() -> void:
	# Connects to inventory signal
	SystemData.inventory_updated.connect(_refresh_ui)
	
	# Waits for setup to finish, then update the ui once.
	await get_tree().process_frame
	_refresh_ui()

## Repopulates the grid according to the grid type.
func _refresh_ui() -> void:
	if !slot_scene : push_error("InventoryGrid: Drag the slot scene inside the inspector")
	
	# Clears all children.
	for child in get_children() : child.queue_free()
	
	# Calls functions depending on grid_type
	match grid_type:
		"Fish" : _fish_grid()
		"Bait" : _bait_grid()
		"Buff" : _buff_grid()
		

## Handles fish grid.
func _fish_grid() -> void:
	var contents : Dictionary = SystemData.get_all_fish()
	for fish_id in contents.keys():
		var amount : int = contents[fish_id]
		var fish_data = FishData.FISH_ID.get(fish_id, {})
		var new_slot : Slot = slot_scene.instantiate()
	
		add_child(new_slot)
		new_slot.set_slot(fish_data, amount)

## Handles bait grid.
func _bait_grid() -> void:
	var contents : Dictionary = SystemData.get_bait_inventory()
	
	# Always put generic bait as first slot.
	var generic_bait_slot : Slot = slot_scene.instantiate()
	add_child(generic_bait_slot)
	generic_bait_slot.set_slot(ItemData.get_data(ItemData.BAIT, -1))
	
	for bait_id in contents.keys():
		var amount : int = contents[bait_id]
		var bait_data = ItemData.get_data(ItemData.BAIT, bait_id)
		var new_slot : Slot = slot_scene.instantiate()
	
		add_child(new_slot)
		new_slot.set_slot(bait_data, amount, bait_id)

## TODO Handles buff grid.
func _buff_grid() -> void:
	pass
