extends BasePopup
class_name ShopPopup

@export var card_stage : Control
@export var card_scene : PackedScene
enum SHOP_TYPE_FLAGS {BAIT, UPGRADE, TAROT}
var shop_type : int = 0

func _ready() -> void:
	card_stage._add_card(prep_card())
	card_stage._add_card(prep_card())
	card_stage._add_card(prep_card())

# Prepares a card
func prep_card(_card_data : Dictionary = {}) -> Card:
	var new_card : Card = card_scene.instantiate()
	var item_category : String = generate_item_category()
	var item_id : int = generate_item_id(item_category)
	
	new_card._set_item(item_category, item_id)
	return new_card

# Returns with a category based off shop type.
func generate_item_category() -> String:
	match shop_type:
		SHOP_TYPE_FLAGS.BAIT : return ItemData.BAIT
		SHOP_TYPE_FLAGS.TAROT : return ItemData.TAROT
		SHOP_TYPE_FLAGS.UPGRADE : return [ItemData.ROD, ItemData.REEL, ItemData.LURE, ItemData.EXOTIC].pick_random()
	return ""

# Returns a random ID from a list of available IDs from chosen category.
func generate_item_id(item_category : String) -> int:
	var available_ids = ItemData.get_available_ids(item_category)
	# TODO prune certain ids based off critria?
	# TODO actual weighted randomness
	if available_ids : return available_ids.pick_random()
	else : return 0

func _on_button_pressed() -> void:
	for each in range(10):
		card_stage._add_card(prep_card())

func _on_back_pressed() -> void:
	PlayManager.request_idle_night_state()
	GameManager.dismiss_popup()
