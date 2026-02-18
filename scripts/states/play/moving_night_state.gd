extends State
class_name MovingNightState

const STATE_NAME : String = "MOVING_NIGHT_STATE"

signal signal_moving_night

func _init(parent: StateMachine) -> void:
	state_name = STATE_NAME
	super._init(parent)

func enter(previous_state: State, data: Dictionary = {}) -> void:
	super.enter(previous_state, data)
	signal_moving_night.emit()

func exit(next_state: State) -> void:
	super.exit(next_state)
