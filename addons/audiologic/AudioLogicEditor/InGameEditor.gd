@tool
extends Control

const MENU_DEFAULTS = preload("res://addons/audiologic/AudioLogController/menu_defaults.tres")
const AVAILABLE_MENU_LIST = preload("res://addons/audiologic/AudioLogicEditor/menu_list.tres")

var menu_list_path: String = "res://addons/audiologic/AudioLogicEditor/menu_list.tres"

var current_preview

@onready var game_menu_list: ItemList = %GameMenuList
@onready var player_preview: Control = %PlayerPreview
@onready var add_scene_file_dialog: FileDialog = $AddSceneFileDialog


func _ready() -> void:
	add_menu_to_list(MENU_DEFAULTS.in_game_player.resource_path)

func add_menu_to_list(path: String) -> void:
	AVAILABLE_MENU_LIST.in_game_list[path.get_file()] = path
	ResourceSaver.save(AVAILABLE_MENU_LIST,menu_list_path)
	update_game_menu_list(AVAILABLE_MENU_LIST.in_game_list)

func update_game_menu_list(_list: Dictionary) -> void:
	game_menu_list.clear()
	for i in _list.keys():
		game_menu_list.add_item(i)

func _on_visibility_changed() -> void:
	update_game_menu_list(AVAILABLE_MENU_LIST.in_game_list)
	add_game_menu_to_preview(MENU_DEFAULTS.in_game_player.resource_path)
	
func add_game_menu_to_preview(menu_path: String) -> void:
	var menu_to_load = load(menu_path)

	if scene_to_validate(menu_path) == OK:
		if current_preview:
			current_preview.free()
			
		var new_menu : Control = menu_to_load.instantiate()
		player_preview.add_child(new_menu)
		new_menu.set_owner(player_preview)
		new_menu.visible = true
		current_preview = new_menu
		print(new_menu.visible)
		MENU_DEFAULTS.in_game_player = menu_to_load

func scene_to_validate(new_scene_path: String)->Error:
	var new_scene: PackedScene = load(new_scene_path)
	var scene : SceneState = new_scene.get_state()
	var scene_type: String = scene.get_node_type(0)
	if ClassDB.is_parent_class(scene_type,"Control"):
		return OK
	else:
		return ERR_INVALID_DATA

func _on_add_button_pressed() -> void:
	add_scene_file_dialog.popup()

func _on_add_game_scene_file_selected(path: String) -> void:
	if scene_to_validate(path) == OK:
		add_menu_to_list(path)
	else:
		push_error("Scene not a control node. Cannot load preview")

func _on_menu_list_item_selected(index: int) -> void:
	var menu_name = game_menu_list.get_item_text(index)
	var path = AVAILABLE_MENU_LIST.in_game_list[menu_name]
	add_game_menu_to_preview(path)

