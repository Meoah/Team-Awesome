extends CanvasLayer
class_name HUDPlaceholder

# TODO This shit sucks, replace asap

@export var general_info : RichTextLabel
@export var bait_info : RichTextLabel

func _process(_delta: float) -> void:
	pass

func calculate_rent() -> float:
	var base : float = 100.0
	var growth : float = 1.15
	
	var rent : float = base * pow(growth, SystemData.get_week() - 1)
	return rent
