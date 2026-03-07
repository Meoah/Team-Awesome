extends HSlider
class_name AudioSlider


@export_enum(AudioEngine.BUS_MASTER, AudioEngine.BUS_BGM, AudioEngine.BUS_SFX, AudioEngine.BUS_DIALOGUE) var audio_bus_name : String

func _ready() -> void:
	var audio_bus_index : int = AudioServer.get_bus_index(audio_bus_name)
	var current_volume : float = AudioServer.get_bus_volume_linear(audio_bus_index)
	
	value = current_volume

func _on_value_changed(_value) -> void:
	AudioEngine.set_bus_volume_linear(audio_bus_name, _value)
