@tool
extends Control

var bus_effect_path: String = "res://addons/audiologic/BusEffectProfiles/bus_effects/"
@onready var effect_selector: ItemList = %EffectSelector
@onready var effect_stack: ItemList = %EffectStack
@onready var play_track: Button = %PlayTrack
@onready var load_track: Button = %LoadTrack
@onready var load_track_file_dialog: FileDialog = %LoadTrackFileDialog
@onready var preview_player: AudioStreamPlayer = %PreviewPlayer
@onready var preview_track_name: Label = %PreviewTrackName
@onready var new: Button = %New
@onready var add: Button = %Add
@onready var new_stack_effect_dialog: FileDialog = %NewStackEffectDialog
@onready var audio_effect_selector: PopupMenu = %AudioEffectSelector
@onready var effect_selector_right_click: PopupMenu = %EffectSelectorRightClick
@onready var bus_effect_selector_right_click: PopupMenu = %BusEffectSelectorRightClick


var active_bus_effect: BusEffectProfile
var new_bus_effect: BusEffectProfile
var item_index_to_remove: int
var bus_index_to_delete: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func load_bus_dir() -> void:
	if effect_selector:
		effect_selector.clear()
		var dir = DirAccess.open(bus_effect_path)
		var effect_name: PackedStringArray =  dir.get_files()
		for e in effect_name:
			effect_selector.add_item(e)

func _on_visibility_changed() -> void:
	if visible:
		load_bus_dir()

func _on_effect_selector_item_activated(index: int) -> void:
	var effect_to_load: String = effect_selector.get_item_text(index)
	var bus_effect_profile = ResourceLoader.load(bus_effect_path+effect_to_load)
	active_bus_effect = bus_effect_profile
	set_audio_log_effect(bus_effect_profile)
	
func display_effect_stack(_bus_effect: BusEffectProfile) -> void:
	effect_stack.clear()
	for e: AudioEffect in _bus_effect.bus_effects:
		effect_stack.add_item(e.get_class())

func set_audio_log_effect(_bus_effect: BusEffectProfile) -> void:
	var bus = AudioServer.get_bus_index("AudioLog")
	# remove effects
	for e in AudioServer.get_bus_effect_count(bus):
		AudioServer.remove_bus_effect(bus, 0)
	#add new effects
	for b in _bus_effect.bus_effects:
		var new_name : String = b.get_class()
		new_name = new_name.replace("AudioEffect", "")
		b.resource_name = new_name
		AudioServer.add_bus_effect(bus,b)

func _on_effect_selector_item_selected(index: int) -> void:
	var effect_to_load: String = effect_selector.get_item_text(index)
	var bus_effect_profile = ResourceLoader.load(bus_effect_path+effect_to_load)
	active_bus_effect = bus_effect_profile
	display_effect_stack(bus_effect_profile)

func _on_effect_stack_item_selected(index: int) -> void:
	var effect_to_preview =  effect_stack.get_item_text(index)
	for e in active_bus_effect.bus_effects:
		if e.get_class() == effect_to_preview:
			EditorInterface.inspect_object(e)
		#	var editor = EditorInspectorPlugin.new()
			
func _on_load_track_pressed() -> void:
	load_track_file_dialog.popup()

func _on_load_track_file_dialog_file_selected(path: String) -> void:	
	var load_audio_stream = load(path)
	if load_audio_stream is AudioStream:
		preview_player.stream = load_audio_stream
		preview_track_name.set_text(path.get_file())

func _on_play_track_pressed() -> void:
	preview_player.bus = "AudioLog"
	preview_player.play()

func _on_new_pressed() -> void:
	new_bus_effect = BusEffectProfile.new()
	new_stack_effect_dialog.current_file = bus_effect_path+"new_bus_effect.tres"
	new_stack_effect_dialog.popup()

func _on_new_stack_effect_dialog_file_selected(path: String) -> void:
	ResourceSaver.save(new_bus_effect,path)
	load_bus_dir()

func _on_stop_button_pressed() -> void:
	preview_player.stop()

func _on_add_pressed() -> void:
	var classes = ClassDB.get_inheriters_from_class("AudioEffect")
	for c in classes:
		audio_effect_selector.add_item(c)
	audio_effect_selector.popup()

func _on_audio_effect_selector_index_pressed(index: int) -> void:
	if active_bus_effect:
		var effect_to_load = audio_effect_selector.get_item_text(index)
		var new_audio_effect = ClassDB.instantiate(effect_to_load)
		active_bus_effect.bus_effects.append(new_audio_effect)
		#var bus_effect_index = effect_selector.get_selected_items()
		set_audio_log_effect(active_bus_effect)
		display_effect_stack(active_bus_effect)
	
func _on_effect_stack_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 2:
		item_index_to_remove = index
		var item_to_remove = effect_stack.get_item_text(index)
		var mouse_pos = get_global_mouse_position()
		effect_selector_right_click.popup(Rect2i(mouse_pos,Vector2(100,20)))
		effect_selector_right_click.set_item_text(1,item_to_remove)
		
func _on_effect_selector_right_click_index_pressed(index: int) -> void:
	active_bus_effect.bus_effects.remove_at(item_index_to_remove)
	_on_effect_selector_item_activated(index)
	display_effect_stack(active_bus_effect)

func _on_effect_selector_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 2:
		bus_index_to_delete = index
		var mouse_pos = get_global_mouse_position()
		bus_effect_selector_right_click.popup(Rect2i(mouse_pos,Vector2(122,62)))

func _on_bus_effect_selector_right_click_index_pressed(index: int) -> void:
	match index:
		0:
			_on_effect_selector_item_activated(bus_index_to_delete)
		1:
			on_delete_bus_effect(index)

func on_delete_bus_effect(index: int):
	var effect_to_delete: String = effect_selector.get_item_text(index)
	if FileAccess.file_exists(bus_effect_path+effect_to_delete):
		OS.move_to_trash(ProjectSettings.globalize_path(bus_effect_path+effect_to_delete))
	load_bus_dir()
