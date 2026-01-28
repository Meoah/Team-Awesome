extends Control

#Finds the grid container with the slots
@onready var slot_grid = $Panel/SlotGrid

func _ready():
	update_inventory_ui()
	
func update_inventory_ui() -> void:
	#Get all of the slot panels inside of the grid container
	var slots = slot_grid.get_children()
	
	#Read through each slot:
	for i in range(slots.size()):
		var slot = slots[i]
		var label = slot.get_node("Label")
		
		if i < Inventory.inventory.size():
			var fish_id = Inventory.inventory[i]
			var fish_name = Inventory.get_fish_name(fish_id)
			label.text = fish_name
		else:
			label.text = ""
