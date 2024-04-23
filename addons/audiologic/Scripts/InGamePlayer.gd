extends Control

@onready var Profile: Control  = get_child(0)

func _on_audio_log_controller_log_ended() -> void:
	Profile.hide_player()

func _on_audio_log_controller_log_started(_log: AudioLog) -> void:
	Profile.show_player(_log)
