extends HSlider

@export var audio_bus_name: String #creates a variable of String type that will give a name to an audio bus

var audio_bus_id #declares a variable that can be used as a parameter for the 
				 #AudioServer function

func _ready():
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)

func _on_value_changed(value) -> void:
	var db = linear_to_db(value) #converts volume to decibals
	AudioServer.set_bus_volume_db(audio_bus_id, db)
