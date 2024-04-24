extends CanvasLayer

@onready var example_menu: Control = $ExampleMenu

var is_paused: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		is_paused = !is_paused
		get_tree().set_pause(is_paused)
		example_menu.visible = is_paused
		example_menu.check_for_audio_logs()
		
		if is_paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
