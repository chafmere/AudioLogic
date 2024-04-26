@tool
extends EditorPlugin

const AUTOLOAD_NAME : String = "AudioLogController"
const AUTOLOAD_EFFECTS_NAME: String = "AudioLogEffectsManager"
const AUDIO_LOG_BUS_LAYOUT = preload("res://addons/audiologic/AudioLogController/audio_log_bus_layout.tres")
const MAIN_EDITOR = preload("res://addons/audiologic/AudioLogicEditor/main_editor.tscn")
var main_panel_instance

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME,"res://addons/audiologic/AudioLogController/AudioLogController.tscn")
	#add_autoload_singleton(AUTOLOAD_EFFECTS_NAME,"res://addons/audiologic/audiologiceffectmanager.gd")
	main_panel_instance = MAIN_EDITOR.instantiate()
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	_make_visible(false)
	
func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
	#remove_autoload_singleton(AUTOLOAD_EFFECTS_NAME)
	if main_panel_instance:
		main_panel_instance.queue_free()

func _has_main_screen():
	return true

func _enable_plugin() -> void:
	add_interact_action()
	create_audiolog_buses()
	
func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible
		
func _get_plugin_name():
	return "AudioLogic"

func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
	
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
	AudioServer.set_bus_send(audio_log_bus,"AudioLogic")

func create_audio_log_bg_bus() -> void:
	var audio_log_bus : int = AudioServer.bus_count
	AudioServer.add_bus(audio_log_bus)
	AudioServer.set_bus_name(audio_log_bus,"AudioLogBackground")
	AudioServer.set_bus_send(audio_log_bus,"AudioLogic")
