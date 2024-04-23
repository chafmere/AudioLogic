extends MarginContainer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $Label

func _ready() -> void:
	label.text = "New Log Collected. Hold %s to play" %[InputMap.action_get_events("audiologic_interact")[0].as_text()]

func notify() -> void:
	animation_player.play("notify")

func end_notify() -> void:
	animation_player.play("notify_end")
