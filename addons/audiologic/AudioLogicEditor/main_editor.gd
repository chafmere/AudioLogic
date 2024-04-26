@tool
extends Control

@onready var buttons: VBoxContainer = %Buttons

@onready var auditor_editor: Control = %AuditorEditor
@onready var menu_editor: Control = %MenuEditor
@onready var in_game_editor: Control = %InGameEditor
@onready var audio_log_creator: Control = %AudioLogCreator
@onready var editor: Panel = %Editor



func  _ready() -> void:
	for b: Button in buttons.get_children():
		b.pressed.connect(menu_selected.bind(b.name))
		
func menu_selected(_button_name: String) -> void:
	match _button_name:
		"AuditorEditorButton":
			hide_editors()
			auditor_editor.show()
		"MenuEditorButton":
			hide_editors()
			menu_editor.show()
		"InGameEditorButton":
			hide_editors()
			in_game_editor.show()
		"AudioLogCreatorButton":
			hide_editors()
			audio_log_creator.show()
	
func hide_editors() -> void:
	for e in editor.get_children():
		e.hide()
