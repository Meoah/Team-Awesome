extends Node

# Player Signals
signal player_dies

# Shop Signals
signal start_bait_shop
signal card_purchased(purchased_card_info : Dictionary)
signal shop_closed(save_data : Array[Dictionary], shop_type : ShopPopup.SHOP_TYPE_FLAGS)
