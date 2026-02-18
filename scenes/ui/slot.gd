extends PanelContainer

@onready var icon_rect = $Icon
@onready var count_label = $Icon/CountLabel

func set_slot(fish_data: Inventory_FishData, amount: int):
	icon_rect.texture = fish_data.icon
	
	#Only show count if count is > 1
	if amount > 1:
		count_label.text = str(amount)
		count_label.show()
	else:
		count_label.hide()
		
