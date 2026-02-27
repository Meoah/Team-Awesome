extends Node

## SystemData
##	Holds all the game variables to be used by every other script.

# Variables
var player_money : float = 0.0
var delayed_money : float = 0.0
var day : int = 1
var fish_inventory : Dictionary = {} # {fish_id : int = count : int}
var bait_inventory : Dictionary = {}
var current_upgrades : int = 0

# Signals
signal inventory_updated

# Bit flag system for upgrades.
enum UPGRADE_FLAG{
	ROD1 = 1 << 0,
	ROD2 = 1 << 1,
	ROD3 = 1 << 2
}

# Resets everything to default values.
func _reset_all() -> void:
	_reset_money()
	_reset_day()
	_clear_fish_inventory()
	_reset_bait_inventory()
	_reset_upgrades()

## Money methods
func _set_money(money : float) -> void : player_money = money
func get_money() -> float : return player_money
func get_waiting_money() -> float : return delayed_money
func _add_money(money : float) -> void : player_money += money
func _add_money_delay(money : float) -> void : delayed_money += money
func _reset_money() -> void:
	player_money = 0.0
	delayed_money = 0.0

# Attempts to spend money. Returns false if not enough.
func spend_money(cost : float) -> bool:
	if cost > player_money:
		return false
	player_money -= cost
	return true

# Moves all delayed_money to player_money.
func _transfer_money() -> void:
	player_money += delayed_money
	delayed_money = 0.0

## Week and day methods. Five days in a week.
func _set_day(input_day : int) -> void : day = input_day
func _next_day() -> void : day += 1
func get_day() -> int : return ((day - 1) % 5) + 1
func get_week() -> int : return ((day - 1) / 5) + 1
func _reset_day() -> void : day = 1

## Fish inventory methods.
func _set_fish_inventory(inv : Dictionary) -> void : fish_inventory = inv
func get_all_fish() -> Dictionary : return fish_inventory
# Add fish to inventory
func _add_fish(fish_id: int, amount: int = 1) -> void:
	if fish_inventory.has(fish_id):
		fish_inventory[fish_id] += amount
	else:
		fish_inventory[fish_id] = amount
	inventory_updated.emit()

# Remove specified fish from inventory. Defaults to one quantity.
func _remove_fish(fish_id: int, amount: int = 1) -> void:
	if not has_fish(fish_id):
		return
	fish_inventory[fish_id] -= amount
	#Make sure there are no negative numbers
	if fish_inventory[fish_id] <= 0:
		fish_inventory.erase(fish_id)
	inventory_updated.emit()

# Check if the player has at least the specified amount of a fish. Defaults to checking for one.
func has_fish(fish_id: int, amount: int = 1) -> bool:
	return fish_inventory.has(fish_id) and fish_inventory[fish_id] >= amount

# Returns how many of this fish the players has.
func get_fish_count(fish_id: int) -> int:
	if fish_inventory.has(fish_id):
		return fish_inventory[fish_id]
	return 0

# Returns the total inventory value. 
# TODO: While this works, we might not need this, as we have modifiers to money gain, it 
#		is currently easier to just put in the modified money directly after catching it.
#		However, there is a case to be made to use this for counting specifically base values.
#		Either use the base values for something or delete this function later.
func get_total_inventory_value() -> float:
	var total : float = 0
	for fish in fish_inventory.keys():
		var stack_value = FishData.FISH_ID[fish]["value"] * fish_inventory[fish]
		total += stack_value
	return total

# Resets inventory to null.
func _clear_fish_inventory() -> void:
	fish_inventory.clear()
	inventory_updated.emit()


## Bait inventory methods.
func _set_bait_inventory(bait_inv : Dictionary) -> void : for each in bait_inventory : if each in bait_inv : bait_inventory[each] = bait_inv[each]
func get_bait_inventory() -> Dictionary : return bait_inventory
func _reset_bait_inventory() -> void : for each in bait_inventory : bait_inventory[each] = 0

# Adds bait into inventory.
func _add_bait(bait : String, quantity : int = 1) -> void:
	if bait_inventory.has(bait) : bait_inventory[bait] += quantity
	else : bait_inventory.set(bait, quantity)

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
