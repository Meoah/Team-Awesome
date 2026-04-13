extends Area2D

@export var nighttime_main_path: NodePath = ^".."
@onready var nighttime_main: NighttimeMain = get_node(nighttime_main_path)

func _on_body_entered(body: Node2D) -> void:
	if body is MainCharacter:
		nighttime_main.leave_camp_to_day()
