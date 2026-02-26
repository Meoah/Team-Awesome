extends Control
class_name Card

signal hovered(card: Control)
signal unhovered(card: Control)

func _ready() -> void:
	mouse_entered.connect(func(): hovered.emit(self))
	mouse_exited.connect(func(): unhovered.emit(self))
