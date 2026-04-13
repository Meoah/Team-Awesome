extends Area2D
class_name CampInteractable

@export var jeremy_path: NodePath = ^"../Jeremy"
var jeremy: MainCharacter

func _ready() -> void:
	jeremy = get_node_or_null(jeremy_path) as MainCharacter
	if jeremy: jeremy.player_interact.connect(_on_player_interact)

func _on_player_interact() -> void:
	if !jeremy: return
	if !overlaps_body(jeremy): return
	
	interact()

func interact() -> void: pass
