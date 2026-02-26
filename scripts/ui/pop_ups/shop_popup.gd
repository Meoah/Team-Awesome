extends BasePopup
class_name ShopPopup

@export var card_stage : Control
@export var card_scene : PackedScene

func _ready() -> void:
	card_stage._add_card(prep_card())
	card_stage._add_card(prep_card())
	card_stage._add_card(prep_card())

func prep_card(_card_data : Dictionary = {}) -> Card:
	var new_card : Card = card_scene.instantiate()
	return new_card

func _on_button_pressed() -> void:
	for each in range(10):
		card_stage._add_card(prep_card())

func _on_back_pressed() -> void:
	PlayManager.request_idle_night_state()
	GameManager.dismiss_popup()
