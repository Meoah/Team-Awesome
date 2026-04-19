extends Node

## SystemData
##	Holds all the game variables to be used by every other script.

# Variables
var player_money : float = 0.0
var delayed_money : float = 0.0
var day : int = 1
var active_bait : int = -1
var fish_inventory : Dictionary = {} # {fish_id : int = count : int}
var bait_inventory : Dictionary = {} # {bait_id : int = count : int}
var buff_inventory : Dictionary = {} # {buff_id : int = duration : int}
var upgrade_inventory : Dictionary = {
	ItemData.ROD : {
		ItemData.KEY_NAME : "Empty!",
		ItemData.KEY_DESCRIPTION : "There's nothing here.."
			},
	ItemData.REEL : {
		ItemData.KEY_NAME : "Empty!",
		ItemData.KEY_DESCRIPTION : "There's nothing here.."
			},
	ItemData.LURE : {
		ItemData.KEY_NAME : "Empty!",
		ItemData.KEY_DESCRIPTION : "There's nothing here.."
			},
	ItemData.EXOTIC : {
		ItemData.KEY_NAME : "Empty!",
		ItemData.KEY_DESCRIPTION : "There's nothing here.."
			},
		}
var license: int = -1
var player_stamina: float = 100.0
var fresh_run: bool = true
var camp_tutorial_shown: bool = false
var camp_day: int = 0
var camp_scavange: int = 3
var boss_defeated: bool = false
var winner_screen_shown: bool = false
var value_multiplier: float = 1.0
var campfire_available_at_hour: float = 0.0

# Signals
signal inventory_updated
signal stamina_updated
signal not_enough_stamina

# Resets everything to default values.
func _reset_all() -> void:
	_reset_money()
	_reset_day()
	_clear_fish_inventory()
	_reset_bait_inventory()
	_reset_upgrades()
	
	camp_day = 0
	camp_scavange = 3
	player_stamina = 100.0
	fresh_run = true
	camp_tutorial_shown = false
	boss_defeated = false
	winner_screen_shown = false
	value_multiplier = 1.0
	campfire_available_at_hour = 0.0

## Money methods
func _set_money(money : float) -> void:
	player_money = money
	inventory_updated.emit()
func get_money() -> float : return player_money
func get_delayed_money() -> float : return delayed_money
func _add_money(money : float) -> void:
	player_money += money
	inventory_updated.emit()
func _add_money_delay(money : float) -> void : delayed_money += money
func _reset_money() -> void:
	player_money = 0.0
	delayed_money = 0.0

# Attempts to spend money. Returns false if not enough.
func spend_money(cost : float) -> bool:
	if cost > player_money : return false
	player_money -= cost
	inventory_updated.emit()
	return true

# Moves all delayed_money to player_money.
func _transfer_money() -> void:
	player_money += delayed_money
	delayed_money = 0.0
	inventory_updated.emit()


func calculate_goal() -> float:
	match license:
		1: return 500.0
		2: return 2500.0
		3: return -1
		_: return -1

## Week and day methods. Five days in a week.
func _set_day(input_day : int) -> void:
	day = input_day
	inventory_updated.emit()
func _next_day() -> void:
	day += 1
	inventory_updated.emit()
func get_day() -> int : return day
func _reset_day() -> void:
	day = 1
	inventory_updated.emit()

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

# Resets inventory to null.
func _clear_fish_inventory() -> void:
	fish_inventory.clear()
	inventory_updated.emit()


## Bait inventory methods.
func _set_bait_inventory(bait_inv : Dictionary) -> void:
	for each in bait_inventory : if each in bait_inv : bait_inventory[each] = bait_inv[each]
	inventory_updated.emit()
func get_bait_inventory() -> Dictionary : return bait_inventory
func _reset_bait_inventory() -> void:
	for each in bait_inventory : bait_inventory[each] = 0
	inventory_updated.emit()

# Adds bait into inventory.
func _add_bait(bait : int, quantity : int = 1) -> void:
	if bait_inventory.has(bait) : bait_inventory[bait] += quantity
	else : bait_inventory.set(bait, quantity)
	inventory_updated.emit()

# Attempts to use a bait. Returns false if either invalid bait or bait count is at 0.
func use_bait(bait : int) -> bool:
	if bait == -1 : return true
	
	if bait in bait_inventory:
		if bait_inventory[bait] > 0:
			bait_inventory[bait] -= 1
			if bait_inventory[bait] <= 0:
				bait_inventory.erase(bait)
				active_bait = -1
			inventory_updated.emit()
			return true
		else : print("Attempted to use bait at 0 count: ", bait)
	
	print("Attempted to use invalid bait: ", bait)
	return false

func get_active_bait() -> int : return active_bait
func get_active_bait_count() -> int :
	if bait_inventory.has(active_bait) : return bait_inventory[active_bait]
	else : return 0
func set_active_bait(bait : int) -> void:
	if bait == -1 : active_bait = -1
	if bait_inventory.has(bait) : if bait_inventory[bait] > 0 : active_bait = bait
	inventory_updated.emit()

## Upgrade system methods.
func get_all_upgrades() -> Dictionary : return upgrade_inventory
func get_upgrade(category : String) -> Dictionary : return upgrade_inventory.get(category, {})
func set_upgrade(category : String, upgrade_data : Dictionary) -> void:
	upgrade_inventory.set(category, upgrade_data)
	inventory_updated.emit()
func _reset_upgrades() -> void :
	upgrade_inventory = {
		ItemData.ROD : {
			ItemData.KEY_NAME : "Empty!",
			ItemData.KEY_DESCRIPTION : "There's nothing here.."
				},
		ItemData.REEL : {
			ItemData.KEY_NAME : "Empty!",
			ItemData.KEY_DESCRIPTION : "There's nothing here.."
				},
		ItemData.LURE : {
			ItemData.KEY_NAME : "Empty!",
			ItemData.KEY_DESCRIPTION : "There's nothing here.."
				},
		ItemData.EXOTIC : {
			ItemData.KEY_NAME : "Empty!",
			ItemData.KEY_DESCRIPTION : "There's nothing here.."
				},
			}
	inventory_updated.emit()

func get_stamina() -> float:
	return player_stamina

func set_stamina(new_stamina: float) -> void:
	player_stamina = clamp(new_stamina, 0.0, 100.0)
	stamina_updated.emit()

func add_stamina(value: float) -> void:
	player_stamina += value
	player_stamina = clamp(player_stamina, 0.0, 100.0)
	stamina_updated.emit()

func use_stamina(value: float) -> bool:
	if value > player_stamina:
		not_enough_stamina.emit()
		inventory_updated.emit()
		return false
	
	player_stamina -= value
	stamina_updated.emit()
	return true

func can_use_campfire() -> bool:
	return TimeManager.get_absolute_hour() >= campfire_available_at_hour

func get_campfire_hours_remaining() -> float:
	return max(0.0, campfire_available_at_hour - TimeManager.get_absolute_hour())

func mark_campfire_used(cooldown_hours: float = 6.0) -> void:
	campfire_available_at_hour = TimeManager.get_absolute_hour() + cooldown_hours
