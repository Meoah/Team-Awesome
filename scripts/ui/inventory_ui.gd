extends Control

#Finds the grid container with the slots
@onready var slot_grid = $Panel/SlotGrid

#Retrieves a list of the fish types the player has
var fish_list = Inventory.get_fish_list()

func _ready():
	update_inventory_ui()
	
func update_inventory_ui() -> void:
	#Get all of the slot panels inside of the grid container
	var slots = slot_grid.get_children()
	
	#Read through each slot:
	for i in range(slots.size()):
		var slot = slots[i]
		var label = slot.get_node("Label")
		
		if i < fish_list.size():
			var fish = fish_list[i]
			var fish_name = fish.fish_name
			var amount = Inventory.get_fish_count(fish)
			label.text = fish_name
		else:
			label.text = ""
