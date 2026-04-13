extends CampInteractable

@export var nighttime_main_path: NodePath = ^".."
@onready var nighttime_main: NighttimeMain = get_node(nighttime_main_path)

func interact() -> void:
	var dialogue_id: int = 0102
	
	match SystemData.license:
		1:
			dialogue_id = 0102
		2:
			dialogue_id = 0103
		3:
			dialogue_id = 0104
	
	nighttime_main.show_dialogue(dialogue_id)
