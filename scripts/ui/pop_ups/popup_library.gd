extends RefCounted
class_name PopupLibrary

# The list of popups. Add to this anytime we need a specific popup functionality.
const _BLOCKER = preload("res://scenes/ui/pop_ups/blocker.tscn")
const _GENERIC = preload("res://scenes/ui/pop_ups/generic_popup.tscn")
const _PAUSE = preload("res://scenes/ui/pop_ups/pause_popup.tscn")
const _SETTINGS = preload("res://scenes/ui/pop_ups/settings_popup.tscn")
const _MINIGAME = preload("res://scenes/ui/pop_ups/fish_minigame/minigame_popup.tscn")
const _BOSS_MINIGAME = preload("res://scenes/ui/pop_ups/fish_minigame/boss_minigame_popup.tscn")
const _DIALOGUE = preload("res://scenes/ui/pop_ups/dialogue_popup.tscn")
const _SHOP = preload("res://scenes/ui/pop_ups/shop_popup.tscn")
const _CREDITS = preload("res://scenes/ui/pop_ups/credits.tscn")
const _WINNER = preload("res://scenes/ui/pop_ups/winner_popup.tscn")

# Returns a popup with desired parameters if requested.
static func create_popup(popup_type: int, params: Dictionary = {}) -> BasePopup:
	# Preps the returning popup.
	var popup: BasePopup
	
	# Look for the requested popup and instantiate it.
	match popup_type:
		BasePopup.POPUP_TYPE.MINIGAME:
			popup = _MINIGAME.instantiate()
		BasePopup.POPUP_TYPE.BOSS_MINIGAME:
			popup = _BOSS_MINIGAME.instantiate()
		BasePopup.POPUP_TYPE.DIALOGUE:
			popup = _DIALOGUE.instantiate()
		BasePopup.POPUP_TYPE.SHOP:
			popup = _SHOP.instantiate()
		BasePopup.POPUP_TYPE.PAUSE:
			popup = _PAUSE.instantiate()
		BasePopup.POPUP_TYPE.SETTINGS:
			popup = _SETTINGS.instantiate()
		BasePopup.POPUP_TYPE.CREDITS:
			popup = _CREDITS.instantiate()
		BasePopup.POPUP_TYPE.WINNER:
			popup = _WINNER.instantiate()
		_: # Default
			popup = _GENERIC.instantiate()
	
	# Sets the parameters if there are any.
	popup.set_params(params)
	
	return popup

# Returns a blocker.
static func create_blocker() -> Blocker:
	var blocker = _BLOCKER.instantiate()
	return blocker
