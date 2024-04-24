@tool
extends EditorPlugin

const AUTOLOAD_NAME : String = "AudioLogController"
const AUDIO_LOG_BUS_LAYOUT = preload("res://addons/audiologic/AudioLogController/audio_log_bus_layout.tres")

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME,"res://addons/audiologic/AudioLogController/AudioLogController.tscn")

func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)

func _enable_plugin() -> void:
	add_interact_action()
	create_audiolog_buses()
	
func add_interact_action() -> void:
	if ProjectSettings.has_setting('input/audiologic_interact'):
		return
		
	var input_interact : InputEventKey = InputEventKey.new()
	input_interact.keycode = KEY_F
	ProjectSettings.set_setting('input/audiologic_interact', {'deadzone': 0.5 , 'events':[input_interact]})

func create_audiolog_buses() -> void:
	if AudioServer.get_bus_index("AudioLogic") == -1:
		create_audio_logic_bus()
	if AudioServer.get_bus_index("AudioLog") == -1:
		create_audio_log_bus()
	if AudioServer.get_bus_index("AudioLogBackground")  == -1:
		create_audio_log_bg_bus()

func create_audio_logic_bus() -> void:
	var audio_log_bus : int = AudioServer.bus_count 
	AudioServer.add_bus(audio_log_bus)
	AudioServer.set_bus_name(audio_log_bus,"AudioLogic")

func create_audio_log_bus() -> void:
	var audio_log_bus : int = AudioServer.bus_count
	AudioServer.add_bus(audio_log_bus)
	AudioServer.set_bus_name(audio_log_bus,"AudioLog")
	var bus_effect_profile = load("res://addons/audiologic/BusEffectProfiles/bus_effects/high_pass_crunch.tres")
	for b in bus_effect_profile.bus_effects:
		AudioServer.add_bus_effect(audio_log_bus,b)
	AudioServer.set_bus_send(audio_log_bus,"AudioLogic")

func create_audio_log_bg_bus() -> void:
	var audio_log_bus : int = AudioServer.bus_count
	AudioServer.add_bus(audio_log_bus)
	AudioServer.set_bus_name(audio_log_bus,"AudioLogBackground")
	AudioServer.set_bus_send(audio_log_bus,"AudioLogic")
