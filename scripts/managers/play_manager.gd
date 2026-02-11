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
			IdleDayState.STATE_NAME
		],
		MovingDayState.STATE_NAME : [
			IdleNightState.STATE_NAME,
			DialogueDayState.STATE_NAME,
			CastingState.STATE_NAME
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
			IdleNightState.STATE_NAME
		],
		IdleNightState.STATE_NAME : [
			DialogueNightState.STATE_NAME,
			MovingNightState.STATE_NAME,
			ShoppingState.STATE_NAME,
			SleepingState.STATE_NAME
		],
		DialogueNightState.STATE_NAME : [
			IdleNightState.STATE_NAME,
			ShoppingState.STATE_NAME
		],
		MovingNightState.STATE_NAME : [
			IdleNightState.STATE_NAME,
			DialogueNightState.STATE_NAME,
			ShoppingState.STATE_NAME
		],
		ShoppingState.STATE_NAME : [
			IdleNightState.STATE_NAME,
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
	dead_state = DeadState.new(state_machine)
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
