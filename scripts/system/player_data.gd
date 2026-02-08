extends Node
class_name PlayerData

# TODO Rename to systemdata later, pain in the ass to do it mid production
# TODO Change to autoload with its own class

## PlayerData 
##	Holds all the game variables to be used by every other script.

var player_money : float = 0.0
var day : int = 1
var fish_inventory : Array[String] = [] #TODO must be changed to Array[int] when ID system is done
var bait_inventory : Dictionary = {
	"generic" = 0,
	"special" = 0
}
var current_upgrades : int = 0

# Bit flag system for upgrades.
enum UPGRADE_FLAG{
	ROD1 = 0 << 0,
	ROD2 = 0 << 1,
	ROD3 = 0 << 2
}

# Resets everything to default values.
func _reset_all() -> void:
	_reset_money()
	_reset_day()
	_reset_fish_inventory()
	_reset_fish_inventory()
	_reset_upgrades()

## Money methods
func _set_money(money : float) -> void : player_money = money
func get_money() -> float : return player_money
func _add_money(money : float) -> void : player_money += money
func _reset_money() -> void : player_money = 0.0

## Week and day methods. Five days in a week.
func _set_day(input_day : int) -> void : day = input_day
func _next_day() -> void : day += 1
func get_day() -> int : return (day % 5) + 1
func get_week() -> int : return day / 5
func _reset_day() -> void : day = 1

## Fish inventory methods.
#TODO Change system to accomidate a fish ID system instead
func _set_fish_inventory(inv : Array[String]) -> void : fish_inventory = inv
func get_fish_inventory() -> Array : return fish_inventory
func _add_fish(fish : FishResource) -> void : fish_inventory.append(fish.name)
func _reset_fish_inventory() -> void : fish_inventory = []

# Removes a specific fish by ID.
func _remove_fish(fish : String) -> void:
	if fish_inventory.has(fish):
		var found_fish : int = fish_inventory.find(fish)
		print("Removed fish: ", fish_inventory.pop_at(found_fish))

# Removes fish at specific index value.
func _remove_fish_at_index(index : int) -> void:
	if fish_inventory.size() > index:
		print("Removed fish: ", fish_inventory.pop_at(index))

## Bait inventory methods.
func _set_bait_inventory(bait_inv : Dictionary) -> void : for each in bait_inventory : if each in bait_inv : bait_inventory[each] = bait_inv[each]
func get_bait_inventory() -> Dictionary : return bait_inventory
func _add_bait(bait : String) -> void : if bait in bait_inventory : bait_inventory[bait] += 1
func _reset_bait_inventory() -> void : for each in bait_inventory : bait_inventory[each] = 0

# Attempts to use a bait. Returns false if either invalid bait or bait count is at 0.
func use_bait(bait : String) -> bool:
	if bait in bait_inventory:
		if bait_inventory[bait] > 0:
			bait_inventory[bait] -= 1
			return true
		else : print("Attempted to use bait at 0 count: ", bait)
	else : print("Attempted to use invalid bait: ", bait)
	return false

## Upgrade system methods.
func _set_current_upgrades(flags : int) -> void: current_upgrades = flags
func get_current_upgrades() -> int : return current_upgrades
func _add_upgrade(flag : int) -> void : current_upgrades |= flag
func _remove_upgrade(flag : int) -> void : current_upgrades &= ~flag
func has_upgrade(flag : int) -> bool : return (current_upgrades & flag) != 0
func _reset_upgrades() -> void : current_upgrades = 0
