extends Control

@onready var icon = $Fish_Slot
@onready var amount_label = $Fish_Slot/Fish_Amount 

func setup(fish: FishData, amount: int) -> void:
	if fish != null:
		icon.texture = fish.icon
	amount_label.text = "x" + str(amount)
