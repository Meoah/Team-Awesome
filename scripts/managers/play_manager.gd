extends Node

## States
var idle_day_state : IdleDayState
var dialogue_day_state : DialogueDayState
var moving_day_state : MovingDayState
var casting_state : CastingState
var waiting_state : WaitingState
var reeling_state : ReelingState
var catching_state : CatchingState
var idle_night_state : IdleNightState
var dialogue_night_state : DialogueNightState
var moving_night_state : MovingNightState
var shopping_state : ShoppingState
var sleeping_state : SleepingState
var dead_state : DeadState
# State Machine
var state_machine : StateMachine
# Valid movement states
var movement_states : Dictionary = {
	IdleDayState.STATE_NAME : true,
	MovingDayState.STATE_NAME : true,
	IdleNightState.STATE_NAME : true,
	MovingNightState.STATE_NAME : true
}
# Valid aiming states
var aiming_states : Dictionary = {
	IdleDayState.STATE_NAME : true,
	MovingDayState.STATE_NAME : true,
	CastingState.STATE_NAME : true,
}
# Daytime states
var daytime_states : Dictionary = {
	IdleDayState.STATE_NAME : true,
	DialogueDayState.STATE_NAME : true,
	MovingDayState.STATE_NAME : true,
	CastingState.STATE_NAME : true,
	WaitingState.STATE_NAME : true,
	ReelingState.STATE_NAME : true,
	CatchingState.STATE_NAME : true,
}

func _ready() -> void:
	_setup_state_machine()

# Initializes state machine.
func _setup_state_machine() -> void:
	# Valid transitions.
	var transitions : Dictionary = {
		IdleDayState.STATE_NAME : [
			DialogueDayState.STATE_NAME,
			MovingDayState.STATE_NAME,
			CastingState.STATE_NAME,
			IdleNightState.STATE_NAME
		],
		DialogueDayState.STATE_NAME : [
			IdleDayState.STATE_NAME,
			DeadState.STATE_NAME
		],
		MovingDayState.STATE_NAME : [
			IdleNightState.STATE_NAME,
			DialogueDayState.STATE_NAME,
			CastingState.STATE_NAME,
			DeadState.STATE_NAME
		],
		CastingState.STATE_NAME : [
			IdleDayState.STATE_NAME,
			WaitingState.STATE_NAME
		],
		WaitingState.STATE_NAME : [
			ReelingState.STATE_NAME,
			IdleDayState.STATE_NAME,
			CatchingState.STATE_NAME
		],
		ReelingState.STATE_NAME : [
			CatchingState.STATE_NAME
		],
		CatchingState.STATE_NAME : [
			IdleDayState.STATE_NAME
		],
		IdleNightState.STATE_NAME : [
			DialogueNightState.STATE_NAME,
			MovingNightState.STATE_NAME,
			ShoppingState.STATE_NAME,
			SleepingState.STATE_NAME,
			DeadState.STATE_NAME
		],
		DialogueNightState.STATE_NAME : [
			IdleNightState.STATE_NAME,
			ShoppingState.STATE_NAME,
			DeadState.STATE_NAME
		],
		MovingNightState.STATE_NAME : [
			IdleNightState.STATE_NAME,
			DialogueNightState.STATE_NAME,
			ShoppingState.STATE_NAME,
			DeadState.STATE_NAME
		],
		ShoppingState.STATE_NAME : [
			IdleNightState.STATE_NAME,
			DeadState.STATE_NAME
		],
		SleepingState.STATE_NAME : [
			IdleDayState.STATE_NAME,
			DeadState.STATE_NAME
		],
		DeadState.STATE_NAME : [
			IdleDayState.STATE_NAME,
			IdleNightState.STATE_NAME],
		
	}
	
	# Initializes state machine with name and valid transitions.
	state_machine = StateMachine.new("play_state", transitions)
	
	# Initializes each state machine to hook up with state machine.
	idle_day_state = IdleDayState.new(state_machine)
	dialogue_day_state = DialogueDayState.new(state_machine)
	moving_day_state = MovingDayState.new(state_machine)
	casting_state = CastingState.new(state_machine)
	waiting_state = WaitingState.new(state_machine)
	reeling_state = ReelingState.new(state_machine)
	catching_state = CatchingState.new(state_machine)
	idle_night_state = IdleNightState.new(state_machine)
	dialogue_night_state = DialogueNightState.new(state_machine)
	moving_night_state = MovingNightState.new(state_machine)
	shopping_state = ShoppingState.new(state_machine)
	sleeping_state = SleepingState.new(state_machine)
	dead_state = DeadState.new(state_machine)
	
	# Initial state.
	state_machine.transition_to(dead_state)

# Getters.
func get_current_state() -> State : return state_machine.current_state
func get_state_machine() -> StateMachine : return state_machine

## Requests by other systems. Returns false if invalid transition.
func request_idle_day_state() -> bool : return state_machine.transition_to(idle_day_state) == OK
func request_dialogue_day_state() -> bool : return state_machine.transition_to(dialogue_day_state) == OK
func request_moving_day_state() -> bool : return state_machine.transition_to(moving_day_state) == OK
func request_casting_state() -> bool : return state_machine.transition_to(casting_state) == OK
func request_waiting_state() -> bool : return state_machine.transition_to(waiting_state) == OK
func request_reeling_state() -> bool : return state_machine.transition_to(reeling_state) == OK
func request_catching_state() -> bool : return state_machine.transition_to(catching_state) == OK
func request_idle_night_state() -> bool : return state_machine.transition_to(idle_night_state) == OK
func request_dialogue_night_state() -> bool : return state_machine.transition_to(dialogue_night_state) == OK
func request_moving_night_state() -> bool : return state_machine.transition_to(moving_night_state) == OK
func request_shopping_state() -> bool : return state_machine.transition_to(shopping_state) == OK
func request_sleeping_state() -> bool : return state_machine.transition_to(sleeping_state) == OK
func request_dead_state() -> bool : return state_machine.transition_to(dead_state) == OK

# State boolean checks.
func is_movement_allowed() -> bool : return movement_states.has(state_machine.current_state.state_name)
func is_aiming() -> bool : return aiming_states.has(state_machine.current_state.state_name)
func is_daytime() -> bool : return daytime_states.has(state_machine.current_state.state_name)
