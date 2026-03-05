extends Control
class_name HUDTooltipController

func _input(event : InputEvent) -> void:
	# Hover detection, updates the tooltip location if any part of the hud is hovered.
	if event is InputEventMouseMotion:
		var hovered: Control = get_viewport().gui_get_hovered_control()
		if hovered && hovered.is_visible_in_tree() && hovered.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			GameManager.get_tooltip_layer()._update_tooltip_position(get_viewport().get_mouse_position())
