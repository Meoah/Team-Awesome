extends CampInteractable

@export var nighttime_main_path: NodePath = ^".."
@onready var nighttime_main: NighttimeMain = get_node(nighttime_main_path)

func interact() -> void:
	nighttime_main.use_scavenge_pile()
