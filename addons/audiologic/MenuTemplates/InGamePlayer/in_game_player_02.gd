extends MarginContainer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var profile_picture: TextureRect = $BackgroundPanel/ProfilePicture
@onready var name_label: Label = $BackgroundPanel/NameLabel


func _ready() -> void:
	AudioLogController.log_started.connect(show_player)
	AudioLogController.log_ended.connect(hide_player)

func show_player(_log: AudioLog) -> void:
	animation_player.play("playing_start")
	
	if _log.log_portrait:
		profile_picture.texture = _log.log_portrait
	name_label.text = _log.speaker_name
	
func hide_player() -> void:
	animation_player.play("playing_end")
