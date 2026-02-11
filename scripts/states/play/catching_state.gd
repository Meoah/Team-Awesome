extends State
class_name CatchingState

const STATE_NAME : String = "CATCHING_STATE"

signal signal_catching

func _init(parent: StateMachine) -> void:
	state_name = STATE_NAME
	super._init(parent)

func enter(previous_state: State, data: Dictionary = {}) -> void:
	super.enter(previous_state, data)
	signal_catching.emit()

func exit(next_state: State) -> void:
	super.exit(next_state)
