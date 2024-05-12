extends Control

var in_game_menu
#const MENU_DEFAULTS = preload("res://addons/audiologic/MenuTemplates/menu_defaults.tres")

func _ready() -> void:
	if AudioLogController.MENU_DEFAULTS.in_game_menu:
		in_game_menu = AudioLogController.MENU_DEFAULTS.in_game_menu.instantiate()
		add_child(in_game_menu)
		
	else:
		push_error("No In game menu in menu_defaults.tres, please add one.")
	
func on_game_menu_show() -> void:
	show()
	
func on_game_menu_hide() -> void:
	hide()
