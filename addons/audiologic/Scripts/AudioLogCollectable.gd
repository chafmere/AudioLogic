extends RigidBody3D
class_name AudioLogCollectable

@export var _log: AudioLog
@export var default_collision_layer: int = 8
@export var use_default_collision_layer: bool = true

func _ready() -> void:
	if use_default_collision_layer:
		set_collision_layer_value(default_collision_layer,true)
	
func _on_detected(_is_detected: bool) -> void:
	pass
		
func _on_collected() -> void:
	AudioLogController.set_logs_collected(_log)
	queue_free()
