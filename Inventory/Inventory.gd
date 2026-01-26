extends Node

#List of fish names and the position in the array index:
const FISH_NAMES: = [
	"Sunfish", #id 0
	"Tuna", # id 1
	"Minnow", # id 2
	"Bluetang", #id 3
	"Pompano", #id 4
]

#Player's inventory: Fish IDs
var inventory: Array[int] = []

#Add fish by id number
func add_fish(id: int) -> void:
	inventory.append(id)

#Remove fish by id number
func remove_fish(id: int) -> void:
	inventory.erase(id)

#Check if the player has at least one of a fish
func has_fish(id: int) -> bool:
	return id in inventory

#Turn fish id into the fish's name
func get_fish_name(id: int) -> String:
	if id >= 0 and id < FISH_NAMES.size():
		return FISH_NAMES[id]
	return "Unknown Fish"
