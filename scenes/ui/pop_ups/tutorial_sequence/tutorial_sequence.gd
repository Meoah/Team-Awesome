extends Control



const tutorial_script : Dictionary = {
	00 : "null",
	01 : "Welcome to Arrow Fishing!",
	02 : "You play as Jeremy the Jerboa",
	03 : "Press Space Bar to cast your Fishing Rod!",
	04 : "Everytime you cast your rod you use up bait.",
	05 : "When you run out of bait, click End Day to advance.",
	06 : "Press the arrow combination on screen \nwith either the arrow keys or WASD",
	07 : "Watch out for Variants. Gold shatters \nafter an incorrect input.",
	08 : "Evil red arrows must be pressed\nin the OPPOSITE direction",
	09 : "Good luck and Have Fun!",
	10 : "null"
}





var current_line : int = 0


func _ready() -> void:
	$Label.text = tutorial_script[1]

func new_text():
	$Label.text = tutorial_script[current_line]

func advance_dialogue():
	if current_line == 3:
		$Label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT,Control.PRESET_MODE_MINSIZE)
	if current_line == 4:
		$Label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		new_text()
	if current_line == 5:
		$Label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT,Control.PRESET_MODE_MINSIZE)
		new_text()
	if current_line == 10:
		$".".hide()
	if current_line < 10:
		current_line += 1
	if current_line == 10:
		hide()
	new_text()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_click"):
		advance_dialogue()
