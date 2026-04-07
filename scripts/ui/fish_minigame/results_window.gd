extends PanelContainer
class_name ResultsWindow

@export var _results_label: RichTextLabel


func set_text(incoming_text: String) -> void:
	_results_label.text = incoming_text
