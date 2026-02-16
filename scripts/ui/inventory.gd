extends Node

signal inventory_updated

var inventory_contents: Dictionary = {}

#add fish to inventory
func add_fish(fish: Inventory_FishData, amount: int = 1) -> void:
	if inventory_contents.has(fish):
		inventory_contents[fish] += amount
	else:
		inventory_contents[fish] = amount
	
	inventory_updated.emit()
	
func get_all_fish() -> Dictionary:
	return inventory_contents

#Remove fish from inventory
func remove_fish(fish: Inventory_FishData, amount: int = 1) -> void:
	if not inventory_contents.has(fish):
		return
	inventory_contents[fish] -= amount
	#Make sure there are no negative numbers
	if inventory_contents[fish] <= 0:
		inventory_contents.erase(fish)
	inventory_updated.emit()

#Check if the player has at least one of a fish
func has_fish(fish: Inventory_FishData) -> bool:
	return inventory_contents.has(fish) and inventory_contents[fish] > 0

#How many of this fish does player have
func get_fish_count(fish: Inventory_FishData) -> int:
	if inventory_contents.has(fish):
		return inventory_contents[fish]
	return 0

func refresh_ui():
	for child in get_children():
		child.queue_free()
		var contents = Inventory.get_all_fish()
		for fish in contents.keys():
			var amount = contents[fish]
			
#Useful for the nigh market
func get_total_inventory_value() -> int:
	var total = 0
	for fish in inventory_contents.keys():
		var stack_value = fish.fish_price
		total += fish.fish_price * inventory_contents[fish]
	return total

func clear_inventory() -> void:
	inventory_contents.clear()
	inventory_updated.emit()
