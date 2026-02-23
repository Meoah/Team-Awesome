extends Control
class_name PopupQueue

# TODO Blocker functionaility

var _queue = {}
var _number_paused : int = 0

@export var _blocker : Blocker

func _ready() -> void:
	# The PopupQueue itself blocks mouse inputs from getting to the SceneRoot. 
	#	Therefore, it must be hidden on ready to prevent unwanted blocking.
	self.visible = false

# Force resets the queue.
func clear_queue() -> void:
	# Resets the blocker and stops the tween if in the middle of transition.
	_blocker.kill_tween()
	_blocker.set_alpha(0.0, false)
	# Finds all popups in the queue and frees them.
	for each : BasePopup in _queue.values():
		each.visible = false
		_queue.erase(each.name)
		each.queue_free()
	# Same reason as we have it in _ready().
	self.visible = false

## Procedure: Show Popup
# Find the popup within the PopupLibrary by type, then sets up the popup according to given parameters.
func show_popup(popup_type : BasePopup.POPUP_TYPE, params : Dictionary = {}) -> String:
	var popup : BasePopup = PopupLibrary.create_popup(popup_type, params)
	
	_on_before_show(popup)
	return popup.name # Returns name for debug purposes

# Allows running of preparation functions before actual showing of popup.
func _on_before_show(popup: BasePopup) -> void:
	popup.on_before_show()
	_show(popup)

# Shows the popup.
func _show(popup: BasePopup) -> void:
	# Places called popup on top of the stack while placing the blocker right behind it.
	self.add_child(popup)
	self.move_child(popup, -1)
	self.move_child(_blocker, -2)
	
	_queue[popup.name] = popup # Places the popup in an array for self tracking.
	
	self.visible = true # Forces the popup queue itself to be visible if it wasn't already.
	popup.visible = true # Finally show the popup.
	_set_blocker_alpha(popup.bg_opacity, popup) # Sets the blocker.
	_on_after_show(popup)

# Allows running of functions after the initial show.
func _on_after_show(popup: BasePopup) -> void:
	popup.on_after_show()
	
	# If the popup has a pausing parameter, increment a counter by 1 and transition to pause state.
	if popup.is_will_pause():
		GameManager.request_pause()
		_number_paused += 1

# Sets the blocker's alpha with respect to parameters.
func _set_blocker_alpha(alpha : float, popup : BasePopup) -> void:
	# Checks parameters.
	var will_pause : bool = popup.is_will_pause()
	var do_not_tween : bool = popup.fast_up
	
	# Checks the alpha of the blocker.
	var current_alpha : float = _blocker.get_current_alpha()
	
	# Determines if we're starting or ending a blocker.
	var is_beg_queue : bool = current_alpha == 0
	var is_end_queue : bool = alpha == 0
	
	# If nothing to do, return.
	if current_alpha == alpha : return
	
	# Determine if we will use a fading tween.
	var use_tween = false
	if is_end_queue || (is_beg_queue && !will_pause) : use_tween = true
	if do_not_tween : use_tween = false
	
	# Actual setting of the blocker.
	_blocker.set_alpha(alpha, use_tween)

## Procedure: Dismiss Popup
# Optional argument if we want a specific popup removed by name. Otherwise, it removes the top-most popup from the stack.
func dismiss_popup(popup_name: String = "") -> void:
	if _queue.size() < 1 : return # If the queue size only has 1 or less (aka only blocker), don't bother continuing as the queue is already empty.
	
	var popup: BasePopup # Holder variable.
	# If called for specific popup, find that popup within the stack, then target that for dismissal.
	if _queue.has(popup_name):
		popup = _queue[popup_name]
		_on_before_dismiss(popup)
	# If using default value, simply find the one on top of the visual stack.
	elif popup_name == "":
		popup = _queue.values().back()
		_on_before_dismiss(popup)

# Allows running of preparation functions before actual dismissal of popup.
func _on_before_dismiss(popup: BasePopup) -> void:
	popup.on_before_dismiss()
	
	# Decrement pause tracker by 1 if popup has pausing parameter.
	if (popup.is_will_pause()) && _number_paused > 0:
		_number_paused -= 1
		if _number_paused == 0:
			GameManager.request_unpause() # Transition away from pause if counter hits 0.
	
	_dismiss(popup)

# Dismisses the popup.
func _dismiss(popup: BasePopup) -> void:
	_queue.erase(popup.name) # Remove the popup from the self tracker.
	
	# Moves next popup in line to front if exists
	if(_queue.size() > 0):
		var next_popup: BasePopup = _queue.values().back()
		self.move_child(next_popup, -1)
		self.move_child(_blocker, -2)
	
	# Dismisses the popup from view.
	popup.visible = false
	if(_queue.size() <= 0):
		self.visible = false # If there are no more popups in the tracker, hide the queue itself.
	
	_on_after_dismiss(popup)

# Allows running of functions after the dismissal.
func _on_after_dismiss(popup: BasePopup) -> void:
	popup.on_after_dismiss() # TODO Unsure if await is required here.
	popup.queue_free() # Placed here at the very end to ensure the function finishes its procedure before freeing.

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# Allows escape to dismiss popup.
		if event.keycode == KEY_ESCAPE and event.is_released():
			if _queue.size() == 0 : return
			
			# Checks if state needs to be set back from pause.
			var popup: BasePopup = _queue.values().back()
			var current_state = GameManager.get_current_state()
			
			# Pause only happens after all the DISMISS_ON_ESCAPE are down.
			if popup && (popup.is_dismiss_on_escape()) : GameManager.dismiss_popup()
			elif current_state == GameManager.play_state : GameManager.show_popup(BasePopup.POPUP_TYPE.PAUSE)
