extends Control
class_name Card

@export var card_name_label : RichTextLabel

var card_description : String = ""

func _ready() -> void:
	pass

func _refresh_all() -> void:
	_refresh_cost()

# Handles the cost window.
@export var cost_panel : Control
@export var cost_label : RichTextLabel
var cost : float = -1.0
var cost_type : String = "default"
func _refresh_cost() -> void:
	# If the cost is negative, don't display the window.
	if cost < 0:
		cost_panel.visible = false
		return
	cost_panel.visible = true
	
	# If cost is 0, it's free.
	if cost == 0.0:
		cost_label.text = "FREE!!"
		return
	
	# Prefixes
	var final_cost_string : String = ""
	match cost_type:
		"$":
			final_cost_string += "$ "
			final_cost_string += "%.2f" % cost
		_:
			final_cost_string = "Invalid cost type"
	
	cost_label.text = final_cost_string
