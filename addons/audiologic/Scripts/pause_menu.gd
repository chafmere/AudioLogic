extends CanvasLayer

#@onready var example_menu: Control = $ExampleMenu

var is_paused: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		is_paused = !is_paused
		get_tree().set_pause(is_paused)
		AudioLogController.show_menu(is_paused)
		
		if is_paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
