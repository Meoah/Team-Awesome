extends BasePopup
class_name ShopPopup

@export var card_stage : CardStage
@export var card_scene : PackedScene
@export var generic_bait_button : Button

enum SHOP_TYPE_FLAGS {NONE, BAIT, UPGRADE, TAROT}
var shop_type : SHOP_TYPE_FLAGS = SHOP_TYPE_FLAGS.NONE
var save_data : Array = []

const INITIAL_DRAWN_CARDS : int = 3 # TODO move this to system data to manipulate later.

func _on_ready() -> void:
	# Sets initial cards.
	if save_data : for each_saved_card in save_data : card_stage._add_card(prep_card(each_saved_card))
	else : card_stage._add_cards(_new_hand(INITIAL_DRAWN_CARDS))
	
	# Enables bait button if bait shop.
	if shop_type != SHOP_TYPE_FLAGS.BAIT : generic_bait_button.visible = false
	
	# Bind Signals
	SignalBus.card_purchased.connect(_card_purchased)

func _on_set_params() -> void:
	shop_type = params.get("shop_type", shop_type)
	save_data = params.get("save_data", save_data)

func _new_hand(number_of_cards) -> Array[Card]:
	var new_cards : Array[Card] = []
	new_cards.resize(number_of_cards)
	for index : int in range(number_of_cards):
		new_cards[index] = prep_card()
	return new_cards

# Prepares a card. If no data found, generates a new card.
func prep_card(card_data : Dictionary = {}) -> Card:
	var new_card : Card = card_scene.instantiate()
	# New card.
	if !card_data:
		var item_category : String = generate_item_category()
		var item_id : int = generate_item_id(item_category)
		new_card._set_item(item_category, item_id)
	# Reloading saved card.
	else : new_card._reload_parameters(card_data)
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
	var shop_save_data : Array[Dictionary] = card_stage.save_current_cards()
	SignalBus.shop_closed.emit(shop_save_data, shop_type)
	PlayManager.request_idle_night_state()
	GameManager.dismiss_popup()

# Buys generic bait, always available in bait shop.
func _on_bait_pressed() -> void:
	if SystemData.spend_money(15.0):
		SystemData._add_bait("Generic Bait", 10)

func _card_purchased(card_info : Dictionary = {}) -> void:
	var item_category : String = card_info.get(Card.PURCHASED_ITEM_CATEGORY, "")
	var item_id : int = card_info.get(Card.PURCHASED_ITEM_ID, -1)
	var item_quantity : int = card_info.get(Card.PURCHASED_ITEM_QUANTITY, 1)
	
	var item_data : Dictionary = ItemData.get_data(item_category, item_id)
	
	match item_category:
		ItemData.BAIT:
			SystemData._add_bait(item_data.get(ItemData.KEY_NAME), item_quantity)
		[ItemData.ROD, ItemData.REEL, ItemData.LURE, ItemData.EXOTIC]:
			pass # TODO upgrade system
		ItemData.TAROT:
			pass # TODO idk man

# Clears current card stage, then refills cards by INITIAL_DRAWN_CARDS
func _on_reroll_pressed() -> void:
	if !SystemData.spend_money(10.0) : return
	
	card_stage._clear_cards()
	await card_stage.cards_cleared
	
	card_stage._add_cards(_new_hand(INITIAL_DRAWN_CARDS))
