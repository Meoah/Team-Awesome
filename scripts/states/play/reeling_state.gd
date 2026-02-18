extends State
class_name ReelingState

const STATE_NAME : String = "REELING_STATE"

signal signal_reeling

func _init(parent: StateMachine) -> void:
	state_name = STATE_NAME
	super._init(parent)

func enter(previous_state: State, data: Dictionary = {}) -> void:
	super.enter(previous_state, data)
	signal_reeling.emit()

func exit(next_state: State) -> void:
	super.exit(next_state)
