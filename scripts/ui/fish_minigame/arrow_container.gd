extends PanelContainer
class_name ArrowContainer

@export var _arrow_list: HBoxContainer
@export var _highlight_node: Polygon2D

const HIGHLIGHT_MOVESPEED: float = 10.0

var _arrow_tracker: Array[Arrow] = []
var current_arrow_index: int = 0

func add_arrow(arrow: Arrow) -> void:
	_arrow_tracker.append(arrow)
	_arrow_list.add_child(arrow)


func erase_all_arrows() -> void:
	for arrow in _arrow_tracker:
		arrow.erase()


func correct_arrow(index: int) -> void:
	_arrow_tracker[index].correct()


func incorrect_arrow(index: int) -> void:
	_arrow_tracker[index].incorrect()


func _process(delta: float) -> void:
	_move_highlight(delta)
	if current_arrow_index >= _arrow_tracker.size(): hide()


func _move_highlight(delta: float) -> void:
	if !_arrow_tracker: return
	if current_arrow_index < 0 or current_arrow_index >= _arrow_tracker.size(): return
	
	var target_pos: Vector2 = _arrow_tracker[current_arrow_index].global_position
	if !_highlight_node.visible: _highlight_node.global_position = target_pos
	
	_highlight_node.show()
	_highlight_node.global_position = _highlight_node.global_position.lerp(target_pos, HIGHLIGHT_MOVESPEED * delta)
