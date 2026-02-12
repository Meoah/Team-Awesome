extends State
class_name IdleDayState

const STATE_NAME : String = "IDLE_DAY_STATE"

signal signal_idle_day

func _init(parent: StateMachine) -> void:
	state_name = STATE_NAME
	super._init(parent)

func enter(previous_state: State, data: Dictionary = {}) -> void:
	super.enter(previous_state, data)
	signal_idle_day.emit()

func exit(next_state: State) -> void:
	super.exit(next_state)
