extends Node
class_name PlayerData

var playerScore : float = 0.0
#Attaches inventory to player data
var fish_inventory : Array = []
var bait_inventory : Dictionary = {
	"generic" = 0,
	"special" = 0
}

func set_score(score : float) -> void:
	playerScore = score
	
func add_score(score : float) -> void:
	playerScore += score
	
func get_score() -> float:
	return playerScore
	
func reset_score() -> void:
	playerScore = 0.0
