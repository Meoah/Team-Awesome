extends State

class_name WeatherState

const STATE_NAME : String = "Weather_State"

func _init(parent : StateMachine) -> void:
	state_name = STATE_NAME
	super._init(parent)
	
func enter(previous_state : State, data : Dictionary = {}) -> void:
	super.enter(previous_state, data)
	WeatherManager._roll_daily_weather()

func exit(next_state : State) -> void:
	super.exit(next_state)
