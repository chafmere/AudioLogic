extends Control

var in_game_player

func _ready() -> void:
	if AudioLogController.MENU_DEFAULTS.in_game_player:
		in_game_player = AudioLogController.MENU_DEFAULTS.in_game_player.instantiate()
		add_child(in_game_player)
	else:
		push_error("No In Game Player Set in menu Defaults. Add one.")
