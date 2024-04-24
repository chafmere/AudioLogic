extends MarginContainer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var profile_picture: TextureRect = $VBoxContainer/ProfilePicture
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var wave: ColorRect = $VBoxContainer/Wave


var spectrum_analyser: AudioEffectInstance
var wave_progress: float = .5
var wave_speed : float = 3

func show_player(_log: AudioLog) -> void:
	wave_progress = wave.get_material().get_shader_parameter("progress")
	
	var audiolog_bus_index: int = AudioServer.get_bus_index("AudioLogic")
	var new_spectrum_analyser : AudioEffect = AudioEffectSpectrumAnalyzer.new()
	AudioServer.add_bus_effect(audiolog_bus_index,new_spectrum_analyser,0)
	spectrum_analyser = AudioServer.get_bus_effect_instance(audiolog_bus_index,0)
	
	animation_player.play("playing_start")
	
	if _log.log_portrait:
		profile_picture.texture = _log.log_portrait
	name_label.text = _log.speaker_name
	
func hide_player() -> void:
	animation_player.play("playing_end")

func  _process(_delta: float) -> void:
	
	if spectrum_analyser:
		var f: Vector2 = spectrum_analyser.get_magnitude_for_frequency_range(0,10000)
		wave_progress = move_toward(wave_progress,clamp(f.x*100, .7,1),_delta*wave_speed)
		wave.get_material().set_shader_parameter("progress",wave_progress)
		print(wave_progress)
