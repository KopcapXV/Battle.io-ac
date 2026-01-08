extends Control

class_name SettingsManager

# -- Names of the sound buses
@export var bus_name_music : String
@export var bus_name_audio : String
# -- Indexes of the sound buses
var bus_index_music : int
var bus_index_audio : int
# -- Slider nodes references
@export var music_slider : HSlider
@export var audio_slider : HSlider

func _ready () -> void:
	# Initilize indexes
	bus_index_music = AudioServer.get_bus_index(bus_name_music)
	bus_index_audio = AudioServer.get_bus_index(bus_name_audio)
	SETTINGS_Set_slider_from_volume(music_slider, bus_name_music, bus_index_music)
	SETTINGS_Set_slider_from_volume(audio_slider, bus_name_audio, bus_index_audio)
	
func SETTINGS_Set_slider_from_volume (slider : HSlider, bus_name : String, bus_index : int) -> void:
	if not slider:
		return
	var current_db
	if 	 (bus_name == "Music"):
		current_db = ThisClient.bus_music_value
	elif (bus_name == "Audio"):
		current_db = ThisClient.bus_audio_value
	else:
		print("<Settings manager> : No such bus")
		return
	var percent = ((current_db + 80.0) / 80.0) * 100.0
	slider.value = clamp(percent, 0.0, 100.0)
	call_deferred("SETTINGS_Connect_slider_signal", slider, bus_name)
	
func SETTINGS_Connect_slider_signal (slider : HSlider, bus_name : String) -> void:
	if   (bus_name == "Music"):
		slider.value_changed.connect(_on_music_slider_value_changed)
	elif (bus_name == "Audio"):
		slider.value_changed.connect(_on_audio_slider_value_changed)
	else:
		print("<Settings manager> : No such bus")
		return

func _on_music_slider_value_changed(value : int):
	var db_value = (value / 100.0) * 80.0 - 80.0
	AudioServer.set_bus_volume_db(bus_index_music, db_value)
	ThisClient.bus_music_value = db_value
	print("<Settigs manager> : music changed")

func _on_audio_slider_value_changed(value : int):
	var db_value = (value / 100.0) * 80.0 - 80.0
	AudioServer.set_bus_volume_db(bus_index_audio, db_value)
	ThisClient.bus_audio_value = db_value
	print("<Settings manager> : audio changed")
