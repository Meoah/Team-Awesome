extends State
class_name CastingState

const STATE_NAME : String = "CASTING_STATE"

signal signal_casting

func _init(parent: StateMachine) -> void:
	state_name = STATE_NAME
	super._init(parent)

func enter(previous_state: State, data: Dictionary = {}) -> void:
	super.enter(previous_state, data)
	signal_casting.emit()

func exit(next_state: State) -> void:
	super.exit(next_state)
