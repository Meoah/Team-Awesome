extends GridContainer

#Link slot
@export var slot: PackedScene

func _ready():
	#Connects to inventory siganal
	Inventory.inventory_updated.connect(refresh_ui)
	refresh_ui()

func refresh_ui():
	if slot == null:
		push_error("Inventory UI: Drag the slot scene inside the inspector")
	for child in get_children():
		child.queue_free()
	
	var contents = Inventory.get_all_fish()
	
	for fish in contents.keys():
		var amount = contents[fish]
		var new_slot = slot.instantiate()
	
		add_child(new_slot)
		new_slot.set_slot(fish, amount)
