extends Control

@onready var button_container: VBoxContainer = %ButtonContainer
@onready var subtitles: RichTextLabel = %Subtitles

var wave_progress: float = 0
var spectrum_analyser: AudioEffectInstance
var wave_speed : float = 3
var buttons_array: Array[String]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_for_audio_logs()
	clear_buttons()

func clear_buttons() -> void:
	for b in button_container.get_children():
		b.queue_free()

func check_for_audio_logs() -> void:
	clear_log_data()
	var logs_collected: Dictionary = AudioLogController.logs_collected
	if not logs_collected.is_empty():
		for logs in logs_collected.keys():
			if buttons_array.has(logs):
				continue
			var new_button: Button = Button.new()
			buttons_array.append(logs)
			new_button.text = logs
			new_button.pressed.connect(get_audio_log.bind(new_button.text))
			button_container.add_child(new_button)

func get_audio_log(log_name: String) -> void:
	var audio_log_to_play : AudioLog
	audio_log_to_play = AudioLogController.get_log(log_name)
	load_log(audio_log_to_play)

func load_log(log_to_play: AudioLog) -> void:
	clear_log_data()
	subtitles.add_text(log_to_play.log_text)
	AudioLogController.play_log_in_game(log_to_play)

func clear_log_data() -> void:
	subtitles.clear()
	subtitles.text = ""

func _on_visibility_changed() -> void:
	check_for_audio_logs()
