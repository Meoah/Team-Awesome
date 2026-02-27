extends CanvasLayer
class_name HUDPlaceholder

# TODO This shit sucks, replace asap

@export var general_info : RichTextLabel
@export var bait_info : RichTextLabel

func _process(_delta: float) -> void:
	_update_info()

func calculate_rent() -> float:
	var base : float = 100.0
	var growth : float = 1.15
	
	var rent : float = base * pow(growth, SystemData.get_week() - 1)
	return rent

func _update_info() -> void:
	var info_string : String = ""
	
	info_string += "Money: $%.2f\n" % SystemData.get_money()
	info_string += "Rent: $%.2f\n" % calculate_rent()
	info_string += "Week: %d\n" % SystemData.get_week()
	info_string += "Day: %d\n" % SystemData.get_day()
	
	general_info.text = info_string
	
	var bait_info_string : String = ""
	var bait_inv : Dictionary = SystemData.get_bait_inventory()
	bait_info_string += "Bait count\n-------------\n"
	for each in bait_inv:
		bait_info_string += "%s: %d\n" % [each, bait_inv[each]]
	
	bait_info.text = bait_info_string
