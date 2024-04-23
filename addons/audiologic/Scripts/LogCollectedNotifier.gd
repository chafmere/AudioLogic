extends Control

@onready var wait_timer: Timer = $WaitTimer
@onready var time_out_timer: Timer = $TimeOutTimer
@onready var notify_panel: MarginContainer = $NotifyPanel

signal play_log

var waiting_for_input: bool = false
var wait_time: int = 1
var note_notifier_timeout: int = 5

func _input(event: InputEvent) -> void:
	if waiting_for_input and event.is_action_pressed("audiologic_interact"):
		wait_timer.start(wait_time)
		
	if event.is_action_released("audiologic_interact"):
		wait_timer.stop()

func new_log_collected() -> void:
	waiting_for_input = true
	notify_panel.notify()
	time_out_timer.start(note_notifier_timeout)

func _on_wait_timer_timeout() -> void:
	if Input.is_action_pressed("audiologic_interact"):
		play_log.emit()
		wait_timer.stop()
		time_out_timer.stop()
		notify_panel.end_notify()
		waiting_for_input = false

func _on_time_out_timer_timeout() -> void:
	waiting_for_input = false
	notify_panel.end_notify()
