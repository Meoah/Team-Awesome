extends Node

# Player Signals
signal player_dies

# Shop Signals
signal start_bait_shop
signal card_purchased(purchased_card_info : Dictionary)
signal shop_closed(save_data : Array[Dictionary], shop_type : ShopPopup.SHOP_TYPE_FLAGS)


<<<<<<< HEAD
# HUD Signal

signal slot_left_clicked

=======
>>>>>>> 69fa1fb8799a8313aef9dcb175195a758598b0b8

# Intro Signals
signal run_intro
