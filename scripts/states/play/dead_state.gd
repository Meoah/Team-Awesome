extends State
class_name DeadState

const STATE_NAME : String = "DEAD_STATE"

signal signal_dead

func _init(parent: StateMachine) -> void:
	state_name = STATE_NAME
	super._init(parent)

func enter(previous_state: State, data: Dictionary = {}) -> void:
	super.enter(previous_state, data)
	signal_dead.emit()

func exit(next_state: State) -> void:
	super.exit(next_state)
