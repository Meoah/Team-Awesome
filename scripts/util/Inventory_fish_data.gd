extends Resource
class_name Inventory_FishData

@export var display_name: String
@export var fish_id: int = 0
@export var fish_price: int = 0 #Night market read this
@export var icon: Texture2D
@export var is_bait: bool = false #Fishing rod can read this
@export var is_stackable = true
