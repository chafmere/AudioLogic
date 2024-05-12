@tool
extends Control

var bus_effect_path: String = "res://addons/audiologic/BusEffectProfiles/bus_effects/"
var insert_sound_effect_path: String = "res://addons/audiologic/AudioEffects/insert_effects/"
var end_sound_effect_path: String = "res://addons/audiologic/AudioEffects/end_effects/"
var background_sound_effect_path: String = "res://addons/audiologic/AudioEffects/background/"

var gloabl_sounds_path: String = "res://addons/audiologic/AudioLogController/global_audiolog_sounds.tres"
var GLOBAL_AUDIOLOG_SOUNDS: AudiologGlobalSounds

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

@onready var insert_effect_button: Label = %InsertEffectButton
@onready var end_effect_button: Label = %endEffectButton
@onready var backgound_effect_button: Label = %BackgoundEffectButton
@onready var defult_bus_button: Label = %DefultBusButton
@onready var insert_effect_option_button: OptionButton = %InsertEffectOptionButton
@onready var end_effect_option_button: OptionButton = %EndEffectOptionButton
@onready var background_option_button: OptionButton = %BackgroundOptionButton
@onready var bus_effect_option_button: OptionButton = %BusEffectOptionButton
@onready var insert_play_button: Button = %InsertPlayButton
@onready var end_play_button: Button = %EndPlayButton
@onready var bg_play_button: Button = %BGPlayButton

@onready var insert_effect: AudioStreamPlayer = %InsertEffect
@onready var bg_sound: AudioStreamPlayer = %BgSound
@onready var end_effect: AudioStreamPlayer = %EndEffect


var active_bus_effect: BusEffectProfile
var new_bus_effect: BusEffectProfile
var item_index_to_remove: int
var bus_index_selected: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func assign_tracks() -> void:
	insert_effect.stream = GLOBAL_AUDIOLOG_SOUNDS.insert_audio_stream
	bg_sound.stream = GLOBAL_AUDIOLOG_SOUNDS.background_audio_stream
	end_effect.stream = GLOBAL_AUDIOLOG_SOUNDS.end_audio_stream
	active_bus_effect = GLOBAL_AUDIOLOG_SOUNDS.default_bus_effect_profile

func load_bus_dir() -> void:
	if effect_selector:
		effect_selector.clear()
		var dir = DirAccess.open(bus_effect_path)
		var effect_name: PackedStringArray =  dir.get_files()
		for e in effect_name:
			effect_selector.add_item(e)

func load_sound_effect_pools() -> void:
	if bus_effect_option_button:
		clear_bus_dir()
		var dir = DirAccess.open(insert_sound_effect_path)	
		var insert_sounds: PackedStringArray = dir.get_files()
		var id = 0
		for sounds : String in insert_sounds:
			if sounds.contains(".import"):
				continue
				
			insert_effect_option_button.add_item(sounds, id)
			if GLOBAL_AUDIOLOG_SOUNDS.insert_audio_stream.resource_path == (insert_sound_effect_path+sounds):
				var index = insert_effect_option_button.get_item_index(id)
				insert_effect_option_button.select(index)
				
			id += 1
		
		id = 0
		dir = DirAccess.open(end_sound_effect_path)
		var end_sounds: PackedStringArray = dir.get_files()
		for sounds in end_sounds:
			if sounds.contains(".import"):
				continue
			end_effect_option_button.add_item(sounds, id)
			
			if GLOBAL_AUDIOLOG_SOUNDS.end_audio_stream.resource_path == (end_sound_effect_path+sounds):
				var index = insert_effect_option_button.get_item_index(id)
				end_effect_option_button.select(index)
				
			id += 1
			
		id = 0
		dir = DirAccess.open(background_sound_effect_path)
		var bg_sounds: PackedStringArray = dir.get_files()
		for sounds in bg_sounds:
			if sounds.contains(".import"):
				continue
			background_option_button.add_item(sounds, id)
			
			if GLOBAL_AUDIOLOG_SOUNDS.background_audio_stream.resource_path == (background_sound_effect_path+sounds):
				var index = insert_effect_option_button.get_item_index(id)
				background_option_button.select(index)
				
			id += 1
			
		id = 0
		dir = DirAccess.open(bus_effect_path)
		var effect_name: PackedStringArray =  dir.get_files()
		for e in effect_name:
			if e.contains(".import"):
				continue
			bus_effect_option_button.add_item(e, id)
			if GLOBAL_AUDIOLOG_SOUNDS.default_bus_effect_profile.resource_path == (bus_effect_path+e):
				var index = bus_effect_option_button.get_item_index(id)
				bus_effect_option_button.select(index)
				
			id += 1

func clear_bus_dir() -> void:
	if bus_effect_option_button:
		bus_effect_option_button.clear()
		insert_effect_option_button.clear()
		background_option_button.clear()
		end_effect_option_button.clear()

func _on_visibility_changed() -> void:
	if visible:
		load_globals(gloabl_sounds_path)
		load_bus_dir()
		load_sound_effect_pools()
		assign_tracks()
	else:
		free_globals()

func free_globals()  -> void:
	GLOBAL_AUDIOLOG_SOUNDS = null

func load_globals(path: String) -> void:
	var globals = load(path)
	GLOBAL_AUDIOLOG_SOUNDS = globals

func _on_effect_selector_item_activated(index: int) -> void:
	var effect_to_load: String = effect_selector.get_item_text(index)
	var bus_effect_profile = ResourceLoader.load(bus_effect_path+effect_to_load)
	active_bus_effect = bus_effect_profile
	display_effect_stack(bus_effect_profile)
	
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
			
func _on_load_track_pressed() -> void:
	load_track_file_dialog.popup()

func _on_load_track_file_dialog_file_selected(path: String) -> void:	
	var load_audio_stream = load(path)
	if load_audio_stream is AudioStream:
		preview_player.stream = load_audio_stream
		preview_track_name.set_text(path.get_file())

func _on_play_track_pressed() -> void:
	load_log_to_player()
	preview_player.bus = "AudioLog"
	insert_effect.play()
	await  insert_effect.finished
	preview_player.play()
	bg_sound.play()

func load_log_to_player() -> void:
	insert_effect.stream = GLOBAL_AUDIOLOG_SOUNDS.insert_audio_stream
	end_effect.stream = GLOBAL_AUDIOLOG_SOUNDS.end_audio_stream
	bg_sound.stream = GLOBAL_AUDIOLOG_SOUNDS.background_audio_stream
	set_audio_log_effect(GLOBAL_AUDIOLOG_SOUNDS.default_bus_effect_profile)

func _on_new_pressed() -> void:
	new_bus_effect = BusEffectProfile.new()
	new_stack_effect_dialog.current_file = bus_effect_path+"new_bus_effect.tres"
	new_stack_effect_dialog.popup()

func _on_new_stack_effect_dialog_file_selected(path: String) -> void:
	ResourceSaver.save(new_bus_effect,path)
	load_bus_dir()

func _on_stop_button_pressed() -> void:
	stop_players()

func stop_players() -> void:
	preview_player.stop()
	insert_effect.stop()
	end_effect.stop()
	bg_sound.stop()

func _on_add_pressed() -> void:
	audio_effect_selector.clear()
	var classes = ClassDB.get_inheriters_from_class("AudioEffect")
	for c in classes:
		audio_effect_selector.add_item(c)
	audio_effect_selector.popup()

func _on_audio_effect_selector_index_pressed(index: int) -> void:
	if active_bus_effect:
		var effect_to_load = audio_effect_selector.get_item_text(index)
		var new_audio_effect = ClassDB.instantiate(effect_to_load)
		active_bus_effect.bus_effects.append(new_audio_effect)
		if active_bus_effect == GLOBAL_AUDIOLOG_SOUNDS.default_bus_effect_profile:
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

	if active_bus_effect == GLOBAL_AUDIOLOG_SOUNDS.default_bus_effect_profile:
		set_audio_log_effect(active_bus_effect)
	display_effect_stack(active_bus_effect)
	
func _on_effect_selector_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 2:
		bus_index_selected = index
		var mouse_pos = get_global_mouse_position()
		bus_effect_selector_right_click.popup(Rect2i(mouse_pos,Vector2(122,62)))

func _on_bus_effect_selector_right_click_index_pressed(index: int) -> void:
	match index:
		0:
			load_bus_effect_to_default(bus_index_selected)
		1:
			on_delete_bus_effect(bus_index_selected)

func load_bus_effect_to_default(index: int) -> void:
	var effect_to_load = effect_selector.get_item_text(index)
	for i in bus_effect_option_button.item_count:
		if bus_effect_option_button.get_item_text(i) == effect_to_load:
			bus_effect_option_button.select(i)
			_on_bus_effect_option_button_item_selected(i)

func on_delete_bus_effect(index: int):
	var effect_to_delete: String = effect_selector.get_item_text(index)
	if FileAccess.file_exists(bus_effect_path+effect_to_delete):
		OS.move_to_trash(ProjectSettings.globalize_path(bus_effect_path+effect_to_delete))
	load_bus_dir()

func _on_insert_play_button_pressed() -> void:
	if insert_effect.playing:
		insert_effect.stop()
	else:
		insert_effect.play()
	
func _on_end_play_button_pressed() -> void:
	if end_effect.playing:
		end_effect.stop()
	else:
		end_effect.play()

func _on_bg_play_button_pressed() -> void:
	if bg_sound.playing:
		bg_sound.stop()
	else:
		bg_sound.play()

func _on_preview_player_finished() -> void:
	if visible:
		bg_sound.stop()
		end_effect.play()

func _on_end_effect_finished() -> void:
	pass

func _on_bus_effect_option_button_item_selected(index: int) -> void:
	var effect_to_load: String = bus_effect_option_button.get_item_text(index)
	var bus_effect_profile = ResourceLoader.load(bus_effect_path+effect_to_load)
	#active_bus_effect = bus_effect_profile
	set_audio_log_effect(bus_effect_profile)
	GLOBAL_AUDIOLOG_SOUNDS.default_bus_effect_profile = bus_effect_profile

func _on_insert_effect_option_button_item_selected(index: int) -> void:
	var insert_sound: String = insert_effect_option_button.get_item_text(index)
	var load_file: AudioStream = load(insert_sound_effect_path+insert_sound)
	insert_effect.stream = load_file
	GLOBAL_AUDIOLOG_SOUNDS.insert_audio_stream = load_file

func _on_end_effect_option_button_item_selected(index: int) -> void:
	var end_sound: String = end_effect_option_button.get_item_text(index)
	var load_file: AudioStream = load(end_sound_effect_path+end_sound)
	end_effect.stream = load_file
	GLOBAL_AUDIOLOG_SOUNDS.end_audio_stream = load_file

func _on_background_option_button_item_selected(index: int) -> void:
	var bg_file: String = background_option_button.get_item_text(index)
	var load_file: AudioStream = load(background_sound_effect_path+bg_file)
	bg_sound.stream = load_file
	GLOBAL_AUDIOLOG_SOUNDS.background_audio_stream = load_file
