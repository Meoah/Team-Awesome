extends BasePopup

class_name InventoryPopup

# List of fish entries:
var fish_list: Array = []

const FishSlotScene := preload("res://scenes/ui/inventory_slot.tscn")

#PopUP setup
func _on_init() -> void:
	type = POPUP_TYPE.INVENTORY
	
func _on_ready() -> void:
	pass
		
func on_before_show() -> void:
	_update_display()

#Called after popup screen is on screen
func on_after_show() -> void:
	pass
func on_before_dismiss() -> void:
	pass
	
func on_after_dismiss() -> void:
	pass

func is_will_pause() -> bool:
	return true
# Find the index of a fish in the array
func _find_fish_index(fish: FishData) -> int:
	for i in range(fish_list.size()):
		if fish_list[i].fish == fish:
			return i
	return -1

# Add fish to inventory
func add_fish(fish: FishData, amount: int = 1) -> void:
	var index := _find_fish_index(fish)
	if index != -1:
		fish_list[index].count += amount
	else:
		fish_list.append({
			"fish": fish,
			"count": amount
		})
	_update_display()

# Remove fish from inventory
func remove_fish(fish: FishData, amount: int = 1) -> void:
	var index := _find_fish_index(fish)
	if index == -1:
		return

	fish_list[index].count -= amount
	if fish_list[index].count <= 0:
		fish_list.remove_at(index)

	_update_display()

# Check if the player has at least one of a fish
func has_fish(fish: FishData) -> bool:
	var index := _find_fish_index(fish)
	if index == -1:
		return false
	return fish_list[index].count > 0

# How many of this fish does player have
func get_fish_count(fish: FishData) -> int:
	var index := _find_fish_index(fish)
	if index == -1:
		return 0
	return fish_list[index].count

 #Getting a list of all fish types the player has
func get_fish_list() -> Array:
	var types: Array = []
	for entry in fish_list:
		types.append(entry.fish)
	return types


# Show inventory popup
func open_inventory() -> void:
	_update_display()
	


# Update the label text
func _update_display() -> void:
	var container := $FishListContainer
	if container == null:
		return

#Remove any old slots
	for child in container.get_children():
		child.queue_free()
#Create a new slot for each fish entry
	for entry in fish_list:
		if  entry.fish == null:
			continue
	
		var slot = FishSlotScene.instantiate()
		slot.setup(entry.fish, entry.count)
		container.add_child(slot)
