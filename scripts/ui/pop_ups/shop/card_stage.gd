extends Control
class_name CardStage

# TODO Selecting cards

const CARD_SIZE : Vector2 = Vector2(225, 300)

const GAP_SIZE : float = 16.0
const SIDE_PADDING : float = 24.0

const HOVER_SCALE : float = 1.08
const HOVER_PUSH_SIZE : float = 16.0
const HOVER_LIFT_SIZE : float = 8
const HOVER_LIFT_SCALE : float = 0.75
const ANIMATION_TIME : float = 0.12
const FAN_STRENGTH : float = 0.35

var cards : Array[Card] = []
var hovered : Control = null
var tweens : Dictionary = {}

var base_x: Array[float] = []
var base_y: float = 0.0
var base_step: float = 0.0

func _ready() -> void:
	# If the sizes changes for any reason, refresh the cards.
	resized.connect(_update_layout)
	_refresh_cards()
	
	# Makes sure everything is up and running before refreshing the layout.
	await get_tree().process_frame
	_update_layout()

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion : _update_mouse_hover()

# Main function to add a card.
func _add_card(incoming_card : Card) -> void:
	add_child(incoming_card)
	_refresh_layout()

# Refreshes the board.
func _refresh_layout() -> void:
	_refresh_cards()
	_update_layout()

# Refreshes the cards by scanning each child for valid cards.
func _refresh_cards() -> void:
	cards.clear()
	for valid_card : Card in get_children():
		cards.append(valid_card)
		# Ensures the card has the correct mouse filter settings.
		valid_card.mouse_filter = Control.MOUSE_FILTER_STOP

# Action taken when mouse moves on the screen.
func _update_mouse_hover() -> void:
	# Abort if no cards.
	if cards.is_empty() : return
	
	# Find where the mouse is, then check if it's in the stage area, if not abort.
	var mouse_global_position : Vector2 = get_global_mouse_position()
	if !get_global_rect().has_point(mouse_global_position):
		if hovered != null : _set_hover(null)
		return
	
	# If base cache isn't ready, abort.
	if base_x.is_empty() || base_x.size() != cards.size() : return
	
	# Check if mouse is within the vertical bounds of any card, if not abort.
	var mouse_local_position : Vector2 = get_local_mouse_position()
	if mouse_local_position.y < base_y or mouse_local_position.y > base_y + CARD_SIZE.y:
		if hovered != null : _set_hover(null)
		return
	
	# Subdivide the available space by the cards present. Assign those as valid bounds.
	var centers: Array[float] = []
	centers.resize(base_x.size())
	for index : int in range(base_x.size()):
		centers[index] = base_x[index] + CARD_SIZE.x * 0.5
	
	# Identify which card the mouse is within the bounds for.
	var hovered_card_index : int = 0
	for index : int in range(centers.size() - 1):
		var mid : float = (centers[index] + centers[index + 1]) * 0.5
		if mouse_local_position.x >= mid:
			hovered_card_index = index + 1
	
	# Once hovered card is determined, if it isn't already the hovered card, set it.
	var hovered_card : Card = cards[hovered_card_index]
	if hovered_card != hovered : _set_hover(hovered_card)

# Sets the hovered card.
func _set_hover(incoming_card : Card) -> void:
	hovered = incoming_card
	_update_layout()

# Main updater
func _update_layout() -> void:
	_refresh_cards()
	
	# Check number of cards, if empty, abort.
	var number_of_cards : int = cards.size()
	if number_of_cards == 0 : return
	
	# Determine overlapping limits.
	var available_width : float = max(0.0, size.x - SIDE_PADDING * 2.0)
	var desired_step : float = CARD_SIZE.x + GAP_SIZE
	var step : float = desired_step
	
	# Finds the lower number between desired step and what is actually available.
	var step_fit : float = (available_width - CARD_SIZE.x) / float(number_of_cards - 1)
	step = min(desired_step, step_fit)
	
	# Sets up the base positions, if every card was unhovered.
	base_step = step
	base_y = (size.y - CARD_SIZE.y) * 0.5
	var base_total : float = CARD_SIZE.x + float(number_of_cards - 1) * step
	var base_start_x : float = SIDE_PADDING + (available_width - base_total) * 0.5
	base_x.resize(number_of_cards)
	for index : int in range(number_of_cards):
		base_x[index] = base_start_x + float(index) * step
	
	# Check to see which card is hovered, if any.
	var hovered_index : int = (cards.find(hovered) if hovered else -1)
	var has_hover : bool = (hovered_index != -1)
	
	# Actual placing of cards.
	for index : int in range(number_of_cards):
		# Set the current card to manipulate and reset its size and pivot.
		var current_card : Card = cards[index]
		current_card.size = CARD_SIZE
		current_card.pivot_offset = current_card.size * 0.5
		
		# Check if the card if hovered. If so, set the scale to HOVER_SCALE.
		var is_hovered : bool = has_hover and (index == hovered_index)
		var target_scale : Vector2 = Vector2.ONE * (HOVER_SCALE if is_hovered else 1.0)
		
		# Pull from the base x and y.
		var x : float = base_x[index]
		var y : float = base_y
		
		# Runs if the card isn't the one being hovered but there exists a hovered card.
		#	The goal is to fan the cards away from the hovered card.
		if has_hover and !is_hovered:
			# Determines the direction and distance (by index) to push away from the hovered card.
			var direction : float = (-1.0 if index < hovered_index else 1.0)
			var distance : int = abs(index - hovered_index)
			
			# Moves the card away from the hovered card. The closer the card, the harder the push.
			if distance > 0:
				var factor : float = 1.0 / float(distance)
				var fan : float = ease(factor, FAN_STRENGTH)
				x += direction * (HOVER_PUSH_SIZE * fan)
			
			# Safeguard that restricts the fanned cards from going out of bounds.
			var min_x : float = SIDE_PADDING
			var max_x : float = max(SIDE_PADDING, size.x - SIDE_PADDING - CARD_SIZE.x)
			x = clamp(x, min_x, max_x)
			
		# Runs if the current card is the hovered card.
		#	Pushes the hovered card upwards.
		if is_hovered:
			var added_height : float = CARD_SIZE.y * (HOVER_SCALE - 1.0)
			y -= HOVER_LIFT_SIZE + added_height * HOVER_LIFT_SCALE
		
		# Ensures the hovered card is the highest on the z axis.
		current_card.z_index = (1000 if is_hovered else index)
		
		# Once all calculations are done, send to the animator.
		_animate_card(current_card, Vector2(x, y), target_scale)

# Animates the cards moving.
func _animate_card(incoming_card : Card, target_position : Vector2, target_scale : Vector2) -> void:
	# Checks if the incoming_card is actively running, if so kill that tween.
	if tweens.has(incoming_card):
		var old_tween : Tween = tweens[incoming_card]
		if old_tween and old_tween.is_running():
			old_tween.kill()
	
	# Starts a new tween to move the card and set their scale, then place it in the tweens[] for tracking.
	var new_tween : Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tweens[incoming_card] = new_tween
	new_tween.tween_property(incoming_card, "position", target_position, ANIMATION_TIME)
	new_tween.parallel().tween_property(incoming_card, "scale", target_scale, ANIMATION_TIME)
