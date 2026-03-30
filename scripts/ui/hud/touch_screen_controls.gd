extends Control
class_name TouchScreenControls

var ignore_input : bool = false
var has_touch_input : bool = false


func _input(event: InputEvent) -> void:
	if ignore_input : return
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		show()
		has_touch_input = true


func _ready() -> void:
	hide()


func _on_right_pressed() -> void:
	_press_action("right")


func _on_right_released() -> void:
	_release_action("right")


func _on_down_pressed() -> void:
	_press_action("down")


func _on_down_released() -> void:
	_release_action("down")


func _on_left_pressed() -> void:
	_press_action("left")


func _on_left_released() -> void:
	_release_action("left")


func _on_up_pressed() -> void:
	_press_action("up")


func _on_up_released() -> void:
	_release_action("up")


func _on_button_pressed() -> void:
	_press_action("action")


func _on_button_released() -> void:
	_release_action("action")


func _press_action(action_name : String) -> void:
	var event : InputEventAction = InputEventAction.new()
	event.action = action_name
	event.pressed = true
	Input.parse_input_event(event)


func _release_action(action_name : String) -> void:
	var event : InputEventAction = InputEventAction.new()
	event.action = action_name
	event.pressed = false
	Input.parse_input_event(event)
