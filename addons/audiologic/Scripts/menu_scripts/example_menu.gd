extends Control

@onready var button_container: VBoxContainer = %ButtonContainer
@onready var subtitles: RichTextLabel = %Subtitles
@onready var portrait: TextureRect = %Portrait
@onready var speaker_name: Label = %SpeakerName
@onready var wave_form: ColorRect = %WaveForm

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
	portrait.set_texture(log_to_play.log_portrait)
	speaker_name.set_text(log_to_play.speaker_name)
	AudioLogController.play_log_in_game(log_to_play)
	add_sprectrum_analyser()
	
func add_sprectrum_analyser() -> void:
	var audiolog_bus_index: int = AudioServer.get_bus_index("AudioLogic")
	var new_spectrum_analyser : AudioEffect = AudioEffectSpectrumAnalyzer.new()
	AudioServer.add_bus_effect(audiolog_bus_index,new_spectrum_analyser,0)
	spectrum_analyser = AudioServer.get_bus_effect_instance(audiolog_bus_index,0)
	
func  _process(_delta: float) -> void:
	if spectrum_analyser:
		var f: Vector2 = spectrum_analyser.get_magnitude_for_frequency_range(0,10000)
		wave_progress = move_toward(wave_progress,clamp(f.x*100, .3,1),_delta*wave_speed)
		wave_form.get_material().set_shader_parameter("progress",wave_progress)

func clear_log_data() -> void:
	subtitles.clear()
	subtitles.text = ""
	portrait.set_texture(null)
	speaker_name.set_text("")

func _on_visibility_changed() -> void:
	check_for_audio_logs()
