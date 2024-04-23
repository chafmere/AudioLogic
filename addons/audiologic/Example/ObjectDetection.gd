extends Area3D

var collectable: AudioLogCollectable
@export var default_collision_layer: int = 8
@export var use_defualt_collision: bool = true

func _ready() -> void:
	if use_defualt_collision:
		set_collision_mask_value(default_collision_layer,true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("audiologic_interact"):
		if collectable:
			collectable._on_collected()
			collectable = null

func _on_body_entered(body: Node3D) -> void:
	if body is AudioLogCollectable:
		collectable = body
		collectable._on_detected(true)

func _on_body_exited(body: Node3D) -> void:
	if body is AudioLogCollectable:
		collectable = body
		collectable._on_detected(false)
		collectable = null
