extends State
class_name DialogueDayState

const STATE_NAME : String = "DIALOGUE_DAY_STATE"

signal signal_dialogue_day

func _init(parent: StateMachine) -> void:
	state_name = STATE_NAME
	super._init(parent)

func enter(previous_state: State, data: Dictionary = {}) -> void:
	super.enter(previous_state, data)
	signal_dialogue_day.emit()

func exit(next_state: State) -> void:
	super.exit(next_state)
