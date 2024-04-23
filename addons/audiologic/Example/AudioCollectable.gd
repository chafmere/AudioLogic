extends AudioLogCollectable

@onready var disk: MeshInstance3D = $disk
const HIGHLIGHTER = preload("res://addons/audiologic/Example/Example World/highlighter.tres")

func _on_detected(_is_detected: bool) -> void:
	if _is_detected:
		disk.get_active_material(0).set_next_pass(HIGHLIGHTER)
	else:
		disk.get_active_material(0).next_pass = null
