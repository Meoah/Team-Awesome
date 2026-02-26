extends BasePopup
class_name ShopPopup

@export var card_stage: Control
@export var card_scene: PackedScene

func _ready() -> void:
	card_stage._add_card(card_scene.instantiate())
	card_stage._add_card(card_scene.instantiate())
	card_stage._add_card(card_scene.instantiate())


func _on_button_pressed() -> void:
	if card_scene:
		for each in range(10):
			card_stage._add_card(card_scene.instantiate())


func _on_back_pressed() -> void:
	PlayManager.request_idle_night_state()
	GameManager.dismiss_popup()
