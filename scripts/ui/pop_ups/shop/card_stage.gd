extends Control
class_name CardStage

const CARD_SIZE : Vector2 = Vector2(225, 300)

const GAP_SIZE : float = 16.0
const SIDE_PADDING : float = 4.0

const HOVER_SCALE : float = 1.08
const HOVER_PUSH_SIZE : float = 16.0
const HOVER_LIFT_SIZE : float = 8
const HOVER_LIFT_SCALE : float = 0.75
const ANIMATION_TIME : float = 0.12
const FAN_STRENGTH : float = 0.35

var cards : Array[Card] = []
var hovered : Card = null
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
	# Hover detection.
	if event is InputEventMouseMotion:
		_update_mouse_hover()
		# If a card is hovered, call for the tooltip to be moved.
		if hovered : GameManager.get_tooltip_layer()._update_tooltip_position(get_global_mouse_position())
	
	# Detects if a player is attempting to purchase a card.
	if event is InputEventMouseButton and event.pressed:
		if hovered and is_instance_valid(hovered):
			if SystemData.spend_money(hovered.card_cost):
				var purchased_card : Card = hovered
				_set_hover(null)
				purchased_card._card_purchased()
				# Wait until it actually exits, then refresh.
				purchased_card.tree_exited.connect(_refresh_layout, CONNECT_ONE_SHOT)
				purchased_card.queue_free()
			else:
				hovered._failed_purchase()

# Main function to add a card.
func _add_card(incoming_card : Card) -> void:
	add_child(incoming_card)
	_refresh_layout()

# Adds cards in a batch.
func _add_cards(incoming_cards : Array[Card]) -> void:
	for each_card in incoming_cards : add_child(each_card)
	_refresh_layout()

# Refreshes the board.
func _refresh_layout() -> void:
	_refresh_cards()
	_update_layout()

# Refreshes the cards by scanning each child for valid cards.
func _refresh_cards() -> void:
	cards.clear()
	for child in get_children():
		if child is Card:
			# Ignore cards that are on the way out.
			if child.is_queued_for_deletion(): continue
			cards.append(child)
			# Ensures the card has the correct mouse filter settings.
			child.mouse_filter = Control.MOUSE_FILTER_STOP

# Action taken when mouse moves on the screen.
func _update_mouse_hover() -> void:
	# If hovered card was freed, clear it.
	if hovered != null and !is_instance_valid(hovered) : _set_hover(null)
	
	# Abort if no cards.
	if cards.is_empty() : return
	
	## Find where the mouse is, then check if it's in the stage area, if not abort.
	var mouse_global_position : Vector2 = get_global_mouse_position()
	if !get_global_rect().has_point(mouse_global_position):
		if hovered != null : _set_hover(null)
		return
	
	# If base cache isn't ready, abort.
	if base_x.is_empty() || base_x.size() != cards.size() : return
	
	# Decide which hover method to use.
	var desired_step : float = CARD_SIZE.x + GAP_SIZE
	var fills_entire_space : bool = (base_step < desired_step)
	var hovered_card : Card = null
	
	# If the entire space is being used, allow mouse passthrough when scanning through cards.
	if fills_entire_space:
		# Subdivide the available space by the cards present. Assign those as valid bounds.
		var centers: Array[float] = []
		centers.resize(base_x.size())
		for index : int in range(base_x.size()):
			centers[index] = base_x[index] + CARD_SIZE.x * 0.5
		
		# Identify which card the mouse is within the bounds for.
		var mouse_local_position : Vector2 = get_local_mouse_position()
		var hovered_card_index : int = 0
		for index : int in range(centers.size() - 1):
			var mid : float = (centers[index] + centers[index + 1]) * 0.5
			if mouse_local_position.x >= mid:
				hovered_card_index = index + 1
		
		hovered_card = cards[hovered_card_index]
		if hovered_card != hovered : _set_hover(hovered_card)
		return

	# If it doesn't fill the entire space, only hover over the card when mouse is actually over a card.
	var highest_z_index : int = -1
	
	for index : int in range(cards.size()):
		# Select the current card, if it's not visible, ignore it.
		var current_card : Card = cards[index]
		if !is_instance_valid(current_card) : continue
		if !current_card.visible : continue
		
		# Determines if the mouse is within the bounds.
		var is_hit : bool = false
		
		# If it's visually within the bounds, it's a hit.
		if current_card.get_global_rect().has_point(mouse_global_position) : is_hit = true
		
		# Check if the mouse is within the previous bounds of the card prehover.
		if !is_hit and current_card == hovered:
			# Find the dimensions of where the card would be if unhovered.
			var stage_global_origin : Vector2 = get_global_transform().origin
			var base_position_global : Vector2 = stage_global_origin + Vector2(base_x[index], base_y)
			var base_rect_global : Rect2 = Rect2(base_position_global, CARD_SIZE)
			
			# If the mouse is within these bounds, it's a hit.
			if base_rect_global.has_point(mouse_global_position) : is_hit = true
		
		# Confirm the card as the hovered card.
		if is_hit:
			if hovered_card == null or current_card.z_index >= highest_z_index:
				hovered_card = current_card
				highest_z_index = current_card.z_index
	
	# Sets the hover.
	if hovered_card != hovered : _set_hover(hovered_card)

# Sets the hovered card.
func _set_hover(incoming_card : Card) -> void:
	if hovered == incoming_card : return
	hovered = incoming_card
	
	# Shows tooltip on cursor if hovered over.
	if hovered == null : GameManager.get_tooltip_layer()._hide_tooltip()
	else : GameManager.get_tooltip_layer()._show_tooltip(get_global_mouse_position(), _get_hover_tooltip_text(hovered))
	
	_update_layout()

func _get_hover_tooltip_text(incoming_card : Card) -> String:
	return incoming_card.card_description

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
		current_card.custom_minimum_size = CARD_SIZE
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
		current_card.z_index = (100 if is_hovered else index)
		
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

func save_current_cards() -> Array[Dictionary]:
	var save_data : Array[Dictionary] = []
	for each_card in cards:
		var card_save_data : Dictionary = each_card._package_save_data()
		save_data.append(card_save_data)
	return save_data

# Clears all cards from the stage.
signal cards_cleared
func _clear_cards() -> void:
	# Reset hover
	_set_hover(null)
	
	# Stop all tweens.
	for tween in tweens.values():
		if tween and tween.is_running():
			tween.kill()
	tweens.clear()
	
	# Kill each card.
	for each_card in cards:
		if is_instance_valid(each_card):
			each_card.queue_free()
	
	# Clears saved values.
	cards.clear()
	base_x.clear()
	
	# Waits one frame to ensure everything gets done.
	await get_tree().process_frame
	
	# Refresh and signal that the clear is finished.
	_refresh_layout()
	cards_cleared.emit()
