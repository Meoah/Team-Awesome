extends State
class_name PauseState

const STATE_NAME : String = "PAUSE_STATE"

signal signal_paused

func _init(parent : StateMachine) -> void:
	state_name = STATE_NAME
	super._init(parent)

func enter(previous_state: State, data: Dictionary = {}) -> void:
	super.enter(previous_state, data)
	signal_paused.emit()
	GameManager.get_tree().paused = true

func exit(_next_state : State) -> void:
	GameManager.get_tree().paused = false
