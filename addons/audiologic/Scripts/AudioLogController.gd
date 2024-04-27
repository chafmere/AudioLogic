extends Control
class_name AudioLogManager

const AUDIO_LOG_BUS_LAYOUT = preload("res://addons/audiologic/AudioLogController/audio_log_bus_layout.tres")

@onready var audio_log_player: AudioStreamPlayer = $AudioNodes/AudioLogPlayer
@onready var insert_effect: AudioStreamPlayer = $AudioNodes/InsertEffect
@onready var background_effect: AudioStreamPlayer = $AudioNodes/BackgroundEffect
@onready var end_effect: AudioStreamPlayer = $AudioNodes/EndEffect

@onready var audio_nodes: Control = $AudioNodes
@onready var log_collected_notifier: Control = $LogCollectedNotifier

var logs_collected: Dictionary = {}
var latest_log: String
var using_in_game_player: bool = false

signal new_log
signal log_started(_log: AudioLog)
signal log_ended

func _ready() -> void:
	init_bus_layout()
	audio_log_player.finished.connect(log_completed)
	new_log.connect(log_collected_notifier.new_log_collected)

func set_logs_collected(_log: AudioLog) -> void:
	if _log:
		if _log.log_name =="":
			push_error("No Name on audio log, this log cannot be found")
			return
		if not _log.log_audio:
			push_error("No Audio on Audio log, Abort adding the log")
			return
			
		logs_collected[_log.log_name] = _log
		latest_log = _log.log_name
		new_log.emit()
	else:
		push_error("No Audio Log on collectable")
	
func get_log(_name:String)->AudioLog:
	return logs_collected[_name]

func init_bus_layout() -> void:
	audio_log_player.set_bus("AudioLog")
	insert_effect.set_bus("AudioLogBackground")
	background_effect.set_bus("AudioLogBackground")
	end_effect.set_bus("AudioLogBackground")

func play_log_in_game(_log: AudioLog) -> void:
	allocate_log_sounds(_log)
	log_started.emit(_log)
	using_in_game_player = true
	insert_effect.play()
	await  insert_effect.finished
	audio_log_player.play()
	background_effect.play()

func play_log_in_menu(_log: AudioLog) -> void:
	allocate_log_sounds(_log)
	insert_effect.play()
	await  insert_effect.finished
	audio_log_player.play()
	background_effect.play()

func log_completed() -> void:
	if using_in_game_player:
		log_ended.emit()
		using_in_game_player = false
		
	for s in audio_nodes.get_children():
		s.stop()
	end_effect.play()

func _on_log_collected_notifier_play_log() -> void:
	play_log_in_game(logs_collected[latest_log])

func allocate_log_sounds(_log: AudioLog) -> void:
	if _log.insert_audio:
		insert_effect.stream  = _log.insert_audio
	if _log.log_audio:
		audio_log_player.stream  = _log.log_audio
	if _log.end_auido:
		end_effect.stream = _log.end_auido
