class_name DialoguePopup
extends BasePopup

# TODO Multiple options

## Node Exports
@export var speaker_label : Label
@export var speaker_nine_slice : NinePatchRect
@export var speaker_margin : MarginContainer
@export var speaker_image_l : TextureRect
@export var speaker_image_r : TextureRect
@export var content_margin : MarginContainer
@export var continue_arrow : TextureRect
@export var content : RichTextLabel
@export var option_a : Button
@export var option_b : Button

var dialogue_id : int = 0000
var current_section_id : int = 0001
var current_section : Dictionary = {}

func _on_init() -> void:
	type = POPUP_TYPE.DIALOGUE

func _on_set_params() -> void:
	if params.has("dialogue_id") : dialogue_id = params["dialogue_id"]

func _on_ready() -> void:
	# Bind Signals
	option_a.pressed.connect(Callable(self, "_advance_dialogue").bind("a"))
	option_b.pressed.connect(Callable(self, "_advance_dialogue").bind("b"))
	
	# Start
	_dialogue()

func _reset_variables() -> void:
	continue_arrow.visible = false
	goto = 0
	
	option_a.visible = false
	option_a_goto = 0
	option_a.text = "Option A"
	
	option_b.visible = false
	option_b_goto = 0
	option_b.text = "Option B"
	
	current_section_parameters = []

func _dialogue() -> void:
	# Retrieves data by ID. If invalid, abort popup.
	var dialogue_data : Dictionary = DialogueData.get_dialogue(dialogue_id)
	if dialogue_data.is_empty():
		_exit()
		return
	
	# Finds current section by ID. If invalid, abort popup.
	current_section = dialogue_data.get(current_section_id, {})
	if current_section.is_empty():
		_exit()
		return
	
	_reset_variables()
	_set_dialogue_parameters(current_section.get(DialogueData.KEY_PARAMETERS, []))
	
	# Name and image
	_set_speaker(current_section.get(DialogueData.KEY_NAME, ""))
	_set_images(current_section.get(DialogueData.KEY_IMAGE_L, ""), current_section.get(DialogueData.KEY_IMAGE_R, ""))
	
	# Content
	_set_content(current_section.get(DialogueData.KEY_TEXT, ""))
	# TODO _set_SFX(current_section.get(DialogueData.KEY_SFX, ""))

# Sets current parameters
var current_section_parameters : Array = []
func _set_dialogue_parameters(parameters : Array = []) -> void:
	current_section_parameters = parameters

# Sets the speaker name if it exists.
func _set_speaker(speaker_name : String = "") -> void:
	# If no speaker name, turns off the speaker nameplate altogether.
	if !speaker_name: 
		speaker_nine_slice.visible = false
		content_margin.add_theme_constant_override("margin_top", 24)
		return
	
	content_margin.add_theme_constant_override("margin_top", 48)
	speaker_nine_slice.visible = true
	speaker_label.text = speaker_name
	
	# Find the width of the label and margins.
	var label_width : float = speaker_label.get_minimum_size().x
	var pad_width : float = speaker_margin.get_theme_constant("margin_left") + speaker_margin.get_theme_constant("margin_right")
	
	# Combine and set the size of the box.
	speaker_nine_slice.custom_minimum_size.x = label_width + pad_width

# Changes the texture of the character portrait on the right.
func _set_images(image_path_l : NodePath = "", image_path_r : NodePath = "") -> void:
	# Sets the textures if there is one.
	if !image_path_l : speaker_image_l.texture = null
	else: speaker_image_l.texture = load(image_path_l)
	if !image_path_r : speaker_image_r.texture = null
	else: speaker_image_r.texture = load(image_path_r)

# Preps the content window.
var is_typing : bool = false
var skip_requested : bool = false
func _set_content(incoming_text : String) -> void:
	# Skips this if there's no text.
	if !incoming_text:
		content.text = ""
		return
	
	# Preps the text to be sent to the typewriter.
	content.text = incoming_text
	content.visible_characters = 0
	is_typing = true
	skip_requested = false
	play_typewriter()

# Plays a typewriter animation for the given text.
const TYPEWRITER_SPEED : float = 0.02
func play_typewriter() -> void:
	# Typing.
	while content.visible_characters < content.get_total_character_count():
		if skip_requested : break
		content.visible_characters += 1
		await get_tree().create_timer(TYPEWRITER_SPEED).timeout
		
	# Ensures text is fully displayed when ending early.
	content.visible_characters = content.get_total_character_count()
	is_typing = false
	_wait_player_input()

# Sets up the dialogue box to advance by waiting for player input.
var waiting : bool = false
var goto : int = 0
var option_a_goto : int = 0
var option_b_goto : int = 0
func _wait_player_input() -> void:
	if DialogueData.PARAMETER_SIGNAL_ON_EXIT not in current_section_parameters:
		_emit_section_signals()
	
	var option_a_text = current_section.get(DialogueData.KEY_OPTION_A, "")
	var option_b_text = current_section.get(DialogueData.KEY_OPTION_B, "")
	waiting = true
	# Checks if options are available, if so, reveal the relevent buttons, if not show the continue arrow.
	if option_a_text: 
		option_a.text = option_a_text
		option_a.visible = true
		option_a_goto = current_section.get(DialogueData.KEY_OPTION_A_GOTO, 0)
	if option_b_text:
		option_b.text = option_b_text
		option_b.visible = true
		option_b_goto = current_section.get(DialogueData.KEY_OPTION_B_GOTO, 0)
	# Continue Arrow
	if !option_a_text && !option_b_text:
		continue_arrow.visible = true
	# If there's KEY_GOTO, set it.
		if current_section.get(DialogueData.KEY_GOTO, 0) : goto = current_section.get(DialogueData.KEY_GOTO, 0)

# Attempts to advance text.
func _request_advance() -> void:
	await get_tree().process_frame # Failsafe to ensure all checks accurate.
	if !is_typing and !waiting : return
	
	# If typewriter is still going, skip to end.
	if is_typing:
		skip_requested = true
		return
	# If KEY_RETURN exists, dismiss popup on dialogue finish.
	if current_section.get(DialogueData.KEY_RETURN, false):
		_exit()
		return
	# Only allow advancing dialogue through continue if option buttons aren't there.
	if continue_arrow.visible: _advance_dialogue("continue")

# Advances dialogue according to goto. If no goto, attempt to go to the next section.
func _advance_dialogue(source : String) -> void:
	match source:
		"a" : current_section_id = (option_a_goto if option_a_goto > 0 else current_section_id + 1)
		"b" : current_section_id = (option_b_goto if option_b_goto > 0 else current_section_id + 1)
		"continue" : current_section_id = (goto if goto > 0 else current_section_id + 1)
	
	_dialogue()

# Attempts to emit each signal in the signal array.
func _emit_section_signals() -> void:
	var signals: Array = current_section.get(DialogueData.KEY_SIGNAL, [])
	if signals.is_empty() : return
	
	# Checks if the string provided is a string, then check if it's a valid signal. If yes, emit it.
	for each_signal in signals:
		if typeof(each_signal) != TYPE_STRING : continue
		var signal_name : String = String(each_signal)
		if SignalBus.has_signal(signal_name) : SignalBus.emit_signal(signal_name)
		else : push_warning("SignalBus missing signal: %s" % signal_name)

# Dismisses the popup after waiting one frame.
func _exit() -> void:
	if DialogueData.PARAMETER_SIGNAL_ON_EXIT in current_section_parameters:
		_emit_section_signals()
	await get_tree().process_frame
	GameManager.popup_queue.dismiss_popup()

func on_after_dismiss() -> void:
	# Resets state back to previous state. 
	# TODO this sucks, make a callback function.
	if PlayManager.get_current_state() is DialogueDayState : PlayManager.request_idle_day_state()
	if PlayManager.get_current_state() is DialogueNightState : PlayManager.request_idle_night_state()

func _input(event : InputEvent) -> void:
	if event.is_echo() : return
	
	if event.is_action_pressed("action"):
		_request_advance()
	if event.is_action_pressed("mouse_click"):
		_request_advance()
