extends Node

#Dictionary: key is FishData resource

#How many of a fish a player has
var fish_counts: ={}

#add fish to inventory
func add_fish(fish: FishData, amount: int = 1) -> void:
	if fish_counts.has(fish):
		fish_counts[fish] += amount
	else:
		fish_counts[fish] = amount

#Remove fish from inventory
func remove_fish(fish: FishData, amount: int = 1) -> void:
	if not fish_counts.has(fish):
		return
	fish_counts[fish] -= amount
	if fish_counts[fish] <= 0:
		fish_counts.erase(fish)

#Check if the player has at least one of a fish
func has_fish(fish: FishData) -> bool:
	return fish_counts.has(fish) and fish_counts[fish] > 0

#How many of this fish does player have
func get_fish_count(fish: FishData) -> int:
	if fish_counts.has(fish):
		return fish_counts[fish]
	return 0
