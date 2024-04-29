@tool
extends Control

var bus_effect_path: String = "res://addons/audiologic/BusEffectProfiles/bus_effects/"
var insert_sound_effect_path: String = "res://addons/audiologic/AudioEffects/insert_effects/"
var end_sound_effect_path: String = "res://addons/audiologic/AudioEffects/end_effects/"
var background_sound_effect_path: String = "res://addons/audiologic/AudioEffects/background/"
var list_path: String = "res://addons/audiologic/AudioLogicEditor/"

var GLOBAL_AUDIOLOG_SOUNDS: AudiologGlobalSounds
var global_audio_path: String =  "res://addons/audiologic/AudioLogController/global_audiolog_sounds.tres"
const PLACE_HOLDER_PROFILE = preload("res://addons/audiologic/ProfilePictures/PlaceHolder_size3_transparent.png")
const AUDIO_LOG_LIST = preload("res://addons/audiologic/AudioLogicEditor/audio_log_list.tres")

@onready var open_audiolog: FileDialog = %OpenAudiolog
@onready var add_audio_log: FileDialog = %AddAudioLog
@onready var add_profile_picture: FileDialog = %AddProfilePicture
@onready var save_audio_log: FileDialog = %SaveAudioLog


@onready var current_log: AudioLog = AudioLog.new()
@onready var picture_button: Button = %PictureButton
@onready var audio_log_name: LineEdit = %AudioLogName
@onready var file_open: Button = %FileOpen
@onready var profile_picture: TextureRect = %ProfilePicture
@onready var speaker_name: LineEdit = %SpeakerName
@onready var log_text: TextEdit = %LogText

@onready var insert_effect_default_override_button: OptionButton = $HBoxContainer/VBoxContainer2/GridContainer/InsertEffectDefaultOverrideButton
@onready var end_effect_default_override_button: OptionButton = $HBoxContainer/VBoxContainer2/GridContainer/EndEffectDefaultOverrideButton
@onready var background_default_override_button: OptionButton = $HBoxContainer/VBoxContainer2/GridContainer/BackgroundDefaultOverrideButton
@onready var bus_effect_default_override_button: OptionButton = $HBoxContainer/VBoxContainer2/GridContainer/BusEffectDefaultOverrideButton

@onready var audio_log_list: ItemList = %AudioLogList

@onready var insert_effect: AudioStreamPlayer = %InsertEffect
@onready var bg_sound: AudioStreamPlayer = %BgSound
@onready var end_effect: AudioStreamPlayer = %EndEffect
@onready var preview_player: AudioStreamPlayer = %PreviewPlayer


func _ready() -> void:
	pass
#	load_sound_effect_pools()

func load_sound_effect_pools() -> void:
	clear_bus_dir()
	var dir = DirAccess.open(insert_sound_effect_path)	
	var insert_sounds: PackedStringArray = dir.get_files()
	var id = 0
	
	insert_effect_default_override_button.add_item("Default", id)
	id += 1
	for sounds : String in insert_sounds:
		if sounds.contains(".import"):
			continue
		insert_effect_default_override_button.add_item(sounds, id)
		id += 1
	
	id = 0
	dir = DirAccess.open(end_sound_effect_path)
	var end_sounds: PackedStringArray = dir.get_files()
	
	end_effect_default_override_button.add_item("Default", id)
	id += 1
	for sounds in end_sounds:
		if sounds.contains(".import"):
			continue
		end_effect_default_override_button.add_item(sounds, id)
		id += 1
		
	id = 0
	dir = DirAccess.open(background_sound_effect_path)
	var bg_sounds: PackedStringArray = dir.get_files()
	
	background_default_override_button.add_item("Default", id)
	id += 1
	for sounds in bg_sounds:
		if sounds.contains(".import"):
			continue
		background_default_override_button.add_item(sounds, id)
		id += 1
		
	id = 0
	dir = DirAccess.open(bus_effect_path)
	var effect_name: PackedStringArray =  dir.get_files()
	
	bus_effect_default_override_button.add_item("Default", id)
	id += 1
	for e in effect_name:
		if e.contains(".import"):
			continue
		bus_effect_default_override_button.add_item(e, id)
		id += 1

func clear_bus_dir() -> void:
	if bus_effect_default_override_button:
		bus_effect_default_override_button.clear()
		insert_effect_default_override_button.clear()
		background_default_override_button.clear()
		end_effect_default_override_button.clear()

func _on_file_open_pressed() -> void:
	add_audio_log.popup()

func _on_add_audio_log_file_selected(path: String) -> void:
	var new_audio_file = load(path)
	if new_audio_file is AudioStream:
		file_open.text = path.get_file()
		current_log.log_audio = new_audio_file

func _on_audio_log_name_text_changed(new_text: String) -> void:
	current_log.log_name = new_text

func _on_line_edit_text_changed(new_text: String) -> void:
	current_log.speaker_name = new_text

func _on_text_edit_text_changed() -> void:
	current_log.log_text = log_text.text

func _on_picture_button_pressed() -> void:
	add_profile_picture.popup()

func _on_add_profile_picture_file_selected(path: String) -> void:
	var new_profile_picture = load(path)
	if new_profile_picture is Texture:
		profile_picture.set_texture(new_profile_picture)
		current_log.log_portrait = new_profile_picture

func _on_visibility_changed() -> void:
	if visible:
		load_globals(global_audio_path)
		load_sound_effect_pools()
		update_log_list(AUDIO_LOG_LIST.audio_log_list)
	else:
		free_globals()

func free_globals()  -> void:
	GLOBAL_AUDIOLOG_SOUNDS = null

func load_globals(path: String) -> void:
	var globals = load(path)
	GLOBAL_AUDIOLOG_SOUNDS = globals

func _on_new_button_pressed() -> void:
	save_audio_log.current_file = "new_audiolog.tres"
	save_audio_log.popup()

func load_audio_log(_log: AudioLog) -> void:
	audio_log_name.text = _log.log_name
	file_open.text = _log.log_audio.resource_path.get_file()
	profile_picture.texture = _log.log_portrait
	speaker_name.text = _log.speaker_name
	log_text.text = _log.log_text
	bus_effect_default_override_button.select(find_option_index(bus_effect_default_override_button,_log.bus_effect_profile))
	insert_effect_default_override_button.select(find_option_index(insert_effect_default_override_button,_log.insert_audio))
	end_effect_default_override_button.select(find_option_index(end_effect_default_override_button,_log.end_audio))
	background_default_override_button.select(find_option_index(background_default_override_button,_log.background_audio))
	
	current_log = _log
	
func find_option_index(option_button: OptionButton, bus_fx: Resource) -> int:
	if bus_fx:
		for i in option_button.item_count:
			var option_text = option_button.get_item_text(i)
			if option_text == bus_fx.resource_path.get_file():
				return i
	return 0

func _on_open_audiolog_file_selected(path: String) -> void:
	var new_log = load(path)
	if new_log is AudioLog:
		load_audio_log(new_log)
		add_log_to_list(path)

func add_log_to_list(path: String) -> void:
	AUDIO_LOG_LIST.audio_log_list[path.get_file()] = path
	ResourceSaver.save(AUDIO_LOG_LIST,list_path)
	update_log_list(AUDIO_LOG_LIST.audio_log_list)

func update_log_list(log_list: Dictionary) -> void:
	audio_log_list.clear()
	for i in log_list.keys():
		audio_log_list.add_item(i)

func _on_load_button_pressed() -> void:
	open_audiolog.popup()

func _on_insert_effect_default_override_button_item_selected(index: int) -> void:
	if index != 0:
		var insert_audio = load(insert_sound_effect_path+insert_effect_default_override_button.get_item_text(index))
		current_log.insert_audio = insert_audio
	else:
		current_log.insert_audio = null

func _on_end_effect_default_override_button_item_selected(index: int) -> void:
	if index != 0:
		var end_audio = load(end_sound_effect_path+end_effect_default_override_button.get_item_text(index))
		current_log.end_audio = end_audio
	else:
		current_log.end_audio = null
		
func _on_background_default_override_button_item_selected(index: int) -> void:
	if index != 0:
		var bg_audio = load(background_sound_effect_path+background_default_override_button.get_item_text(index))
		current_log.background_audio = bg_audio
	else:
		current_log.background_audio = null

func _on_bus_effect_default_override_button_item_selected(index: int) -> void:
	if index != 0:
		var bus_fx = load(bus_effect_path+bus_effect_default_override_button.get_item_text(index))
		current_log.bus_effect_profile = bus_fx
	else:
		current_log.bus_effect_profile = null

func _on_save_audio_log_file_selected(path: String) -> void:
	audio_log_name.clear()
	file_open.text = "Log Audio"
	profile_picture.texture = PLACE_HOLDER_PROFILE
	speaker_name.clear()
	log_text.clear()
	bus_effect_default_override_button.select(0)
	insert_effect_default_override_button.select(0)
	end_effect_default_override_button.select(0)
	background_default_override_button.select(0)
	current_log = AudioLog.new()
	ResourceSaver.save(current_log,path)
	current_log = ResourceLoader.load(path)
	add_log_to_list(path)

func _on_audio_log_list_item_activated(index: int) -> void:
	var log_to_load = audio_log_list.get_item_text(index)
	var path = AUDIO_LOG_LIST.audio_log_list[log_to_load]
	var audio_log = load(path)
	load_audio_log(audio_log)

func _on_insert_play_button_pressed() -> void:
	if insert_effect_default_override_button.selected == 0:
		return
	if insert_effect.playing:
		insert_effect.stop()
	else:
		var insert_effect_to_player = load(insert_sound_effect_path+insert_effect_default_override_button.get_item_text(insert_effect_default_override_button.selected))
		insert_effect.stream = insert_effect_to_player
		insert_effect.play()
	
func _on_end_play_button_pressed() -> void:
	if end_effect_default_override_button.selected == 0:
		return
	if end_effect.playing:
		end_effect.stop()
	else:
		var end_effect_to_player = load(end_sound_effect_path+end_effect_default_override_button.get_item_text(end_effect_default_override_button.selected))
		end_effect.stream = end_effect_to_player
		end_effect.play()

func _on_bg_play_button_pressed() -> void:
	if background_default_override_button.selected == 0:
		return
	if bg_sound.playing:
		bg_sound.stop()
	else:
		var bg_effect_to_player = load(background_sound_effect_path+background_default_override_button.get_item_text(background_default_override_button.selected))
		bg_sound.stream = bg_effect_to_player
		bg_sound.play()

func _on_play_button_pressed() -> void:
	preview_player.bus = "AudioLog"
	load_log_to_player(current_log)
	insert_effect.play()
	await  insert_effect.finished
	preview_player.play()
	bg_sound.play()

func _on_stop_button_pressed() -> void:
	stop_players()

func stop_players() -> void:
	preview_player.stop()
	insert_effect.stop()
	end_effect.stop()
	bg_sound.stop()

func load_log_to_player(_log: AudioLog) -> void:
	if _log.log_audio:
		preview_player.stream = _log.log_audio
		
	if _log.insert_audio:
		insert_effect.stream = _log.insert_audio
	else:
		insert_effect.stream = GLOBAL_AUDIOLOG_SOUNDS.insert_audio_stream
		
	if _log.end_audio:
		end_effect.stream = _log.end_audio
	else:
		end_effect.stream = GLOBAL_AUDIOLOG_SOUNDS.end_audio_stream
	
	if _log.background_audio:
		bg_sound.stream = _log.background_audio
	else:
		bg_sound.stream = GLOBAL_AUDIOLOG_SOUNDS.background_audio_stream
	
	if _log.bus_effect_profile:
		set_bus_fx(_log.bus_effect_profile)
	else:
		set_bus_fx(GLOBAL_AUDIOLOG_SOUNDS.default_bus_effect_profile)

func set_bus_fx(_bus_fx: BusEffectProfile):
	var bus = AudioServer.get_bus_index("AudioLog")
	# remove effects
	for e in AudioServer.get_bus_effect_count(bus):
		AudioServer.remove_bus_effect(bus, 0)
	#add new effects
	for b in _bus_fx.bus_effects:
		var new_name : String = b.get_class()
		new_name = new_name.replace("AudioEffect", "")
		b.resource_name = new_name
		AudioServer.add_bus_effect(bus,b)

func _on_preview_player_finished() -> void:
	if visible:
		end_effect.play()

func _on_end_effect_finished() -> void:
	if visible:
		#print(visible)
		stop_players()
