extends CanvasLayer
class_name TutorialSequence

@export var label : RichTextLabel

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

signal tutorial_done
var current_line : int = 0

func _ready() -> void:
	label.text = tutorial_script[1]
var current_position : int = 1

const positions : Dictionary = {
	1 : Vector2(640.0,360),
	2 : Vector2(349,512.0),
	3 : Vector2(349,512.0),
	4 : Vector2(676,202.0),
	5 : Vector2(1040,598.0),
	6 : Vector2(640.0,360),
}

func advance_position():
	$TutorialSequence.global_position = positions[current_position]
	if current_position <= 5 : current_position += 1

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_click"):
		advance_position()
		advance_dialogue()

func new_text():
	label.text = tutorial_script[current_line]

func advance_dialogue():
	if current_line == 3:
		label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT,Control.PRESET_MODE_MINSIZE)
	if current_line == 4:
		label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		new_text()
	if current_line == 5:
		label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT,Control.PRESET_MODE_MINSIZE)
		new_text()
	if current_line < 10:
		current_line += 1
	if current_line == 10:
		hide()
	new_text()
