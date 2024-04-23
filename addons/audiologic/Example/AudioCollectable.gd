extends AudioLogCollectable

@onready var radio_base: MeshInstance3D = $"radio base"
@onready var radio_buttons: MeshInstance3D = $radio_buttons

const HIGHLIGHTER = preload("res://addons/audiologic/Extras/highlighter.tres")

func _on_detected(_is_detected: bool) -> void:
	if _is_detected:
		radio_base.get_active_material(0).set_next_pass(HIGHLIGHTER)
		radio_buttons.get_active_material(0).set_next_pass(HIGHLIGHTER)
	else:
		radio_base.get_active_material(0).next_pass = null
		radio_buttons.get_active_material(0).next_pass = null
