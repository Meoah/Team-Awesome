extends Node

## States
var play_state : PlayState
var pause_state : PauseState
var main_menu_state : MainMenuState
# State Machine
var state_machine : StateMachine
# Nodes
@export var scene_root : Control
@export var popup_queue : PopupQueue

func _ready() -> void:
	# Check to see if the current scene is the default. If so, kill it.
	#	This script is attached to an autoload, so it can't also be the initial
	#	scene as it would have two instances going at once.
	var default = get_tree().current_scene
	if default and default.name == "default":
		print("Current scene is default, freeing it.")
		default.queue_free()
	
	_setup_state_machine()

# Initializes state machine.
func _setup_state_machine() -> void:
	# Valid transitions.
	var transitions : Dictionary = {
		MainMenuState.STATE_NAME : [
			PlayState.STATE_NAME],
		PlayState.STATE_NAME : [
			MainMenuState.STATE_NAME,
			PauseState.STATE_NAME],
		PauseState.STATE_NAME : [
			MainMenuState.STATE_NAME,
			PlayState.STATE_NAME],
	}
	
	# Initializes state machine with name and valid transitions.
	state_machine = StateMachine.new("game_state", transitions)
	
	# Initializes each state machine to hook up with state machine.
	main_menu_state = MainMenuState.new(state_machine)
	play_state = PlayState.new(state_machine)
	pause_state = PauseState.new(state_machine)
	
	# Initial state.
	state_machine.transition_to(main_menu_state)

# Getters.
func get_current_state() -> State : return state_machine.current_state
func get_scene_container() -> Control : return scene_root

## Requests by other systems. Returns false if invalid transition
func request_play() -> bool:
	var success : bool = state_machine.transition_to(play_state)
	return success
func request_pause() -> bool:
	var success : bool = state_machine.transition_to(pause_state)
	return success
func request_unpause() -> bool:
	var success : bool = state_machine.transition_to(play_state)
	return success
func request_main_menu() -> bool:
	var success : bool = state_machine.transition_to(main_menu_state)
	return success

# Clears any popups left in queue.
func clear_popup_queue() -> void:
	popup_queue.clear_queue()

# Waits one frame to let allow signals to finalize.
func change_scene_deferred(scene : PackedScene) -> void:
	await get_tree().process_frame
	change_scene_sync(scene)

# Clears all scenes from the root then calls the requested scene.
func change_scene_sync(scene : PackedScene) -> void:
	for child in scene_root.get_children():
		child.queue_free()
	var new_scene = scene.instantiate()
	scene_root.add_child(new_scene)
