extends Area2D
class_name CampInteractable

@export var jeremy_path: NodePath = ^"../Jeremy"
@export var collision_shape: CollisionShape2D

var jeremy: MainCharacter


func _ready() -> void:
	jeremy = get_node_or_null(jeremy_path) as MainCharacter
	if jeremy: jeremy.player_interact.connect(_on_player_interact)


func _on_player_interact() -> void:
	if !jeremy: return
	if !overlaps_body(jeremy): return
	
	interact()


func interact() -> void:
	pass


func set_interactable_enabled(enabled: bool) -> void:
	visible = enabled
	monitoring = enabled
	monitorable = enabled
	
	if collision_shape: collision_shape.disabled = !enabled
