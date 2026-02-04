extends Control

#FishData.gd for inventory shop resource

#load fish data"
var FISH01= preload("res://assets/textures/fish/doodle_fish/Fish01.tres")
var FISH02 = preload("res://assets/textures/fish/doodle_fish/Fish02.tres")
var FISH03 = preload("res://assets/textures/fish/doodle_fish/Fish03.tres")
var FISH04 = preload("res://assets/textures/fish/doodle_fish/Fish04.tres")

var ALL_FISH := [FISH01, FISH02, FISH03, FISH04]

func _ready() -> void:
	#Show what fish the player has and the amount when shop opens
	for fish in ALL_FISH:
		var count := Inventory.get_fish_count(fish)
		print("Player has", count, "x", fish.display_name, "(price: )", fish.fish_price, ")")

func sell_fish(fish: FishData) -> void:
	if not Inventory.has_fish(fish):
		print("Player does not have any ", fish.display_name)
		return
	 #remove one fish from inventory to sell
	Inventory.remove_fish(fish, 1)
	
	#Add money or whatever currency is used in the game
	var currency_earned = fish.fish_price
	print("Sold x ", fish.display_name, "for ", currency_earned, " earned")
