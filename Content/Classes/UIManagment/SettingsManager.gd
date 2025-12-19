extends Control

class_name SettingsManager

# -- Names of the sound buses
@export var bus_name_music : String
@export var bus_name_audio : String
# -- Indexes of the sound buses
var bus_index_music : int
var bus_index_audio : int

func _ready () -> void:
	# Initilize indexes
	bus_index_music = AudioServer.get_bus_index(bus_name_music)
	bus_index_audio = AudioServer.get_bus_index(bus_name_audio)

func _on_music_slider_value_changed(value : int):
	AudioServer.set_bus_volume_db(bus_index_music, value)
	print("music")

func _on_audio_slider_value_changed(value : int):
	AudioServer.set_bus_volume_db(bus_index_audio, value)
	print("audio")
