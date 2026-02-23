class_name DialoguePopup
extends BasePopup

@export var speaker_label : Label
@export var speaker_nine_slice : NinePatchRect
@export var speaker_margin : MarginContainer

var dialogue_id : int = 0000

func _on_init() -> void:
	type = POPUP_TYPE.DIALOGUE

func _ready() -> void:
	set_speaker()

func _on_set_params() -> void:
	if params.has("dialogue_id") : dialogue_id = params["dialogue_id"]

func set_speaker(speaker_name : String = "NO NAME SET") -> void:
	speaker_label.text = speaker_name
	await get_tree().process_frame
	
	# Find the width of the label and margins.
	var label_width : float = speaker_label.get_minimum_size().x
	var pad_width : float = speaker_margin.get_theme_constant("margin_left") + speaker_margin.get_theme_constant("margin_right")
	
	# Combine and set the size of the box.
	speaker_nine_slice.custom_minimum_size.x = label_width + pad_width

func _on_exit_pressed():
	GameManager.popup_queue.dismiss_popup()
