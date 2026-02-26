extends Control
class_name Card

@export var card_name : Label

func _ready() -> void:
	tooltip_text = "Card Info Here"
	pass

func _make_custom_tooltip(for_text: String) -> Object:
	var label := Label.new()
	label.text = for_text
	label.add_theme_color_override("font_color", Color.YELLOW)
	return label
