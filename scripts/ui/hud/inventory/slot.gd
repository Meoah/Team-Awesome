extends PanelContainer

@onready var icon_rect = $Icon
@onready var count_label = $Icon/CountLabel

func set_slot(fish_id: int, amount: int):
	var fish = FishData.FISH_ID[fish_id]
	icon_rect.texture = load(fish["image"])
	
	#Only show count if count is > 1
	if amount > 1:
		count_label.text = str(amount)
		count_label.show()
	else:
		count_label.hide()
