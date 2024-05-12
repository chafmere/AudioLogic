@tool
extends Control

const MENU_DEFAULTS = preload("res://addons/audiologic/AudioLogController/menu_defaults.tres")
const AVAILABLE_MENU_LIST = preload("res://addons/audiologic/AudioLogicEditor/menu_list.tres")

var menu_list_path: String = "res://addons/audiologic/AudioLogicEditor/menu_list.tres"

var current_preview

@onready var load_button: Button = %LoadButton
@onready var menu_list: ItemList = %MenuList
@onready var menu_preview: MarginContainer = %MenuPreview
@onready var load_menu_scene: FileDialog = %LoadMenuScene

func _ready() -> void:
	add_menu_to_list(MENU_DEFAULTS.in_game_menu.resource_path)

func add_menu_to_list(path: String) -> void:
	AVAILABLE_MENU_LIST.menu_list[path.get_file()] = path
	ResourceSaver.save(AVAILABLE_MENU_LIST,menu_list_path)
	update_menu_list(AVAILABLE_MENU_LIST.menu_list)

func update_menu_list(_list: Dictionary) -> void:
	menu_list.clear()
	for i in _list.keys():
		menu_list.add_item(i)

func _on_visibility_changed() -> void:
	update_menu_list(AVAILABLE_MENU_LIST.menu_list)
	add_menu_to_preview(MENU_DEFAULTS.in_game_menu.resource_path)
	
func add_menu_to_preview(menu_path: String) -> void:
	var menu_to_load = load(menu_path)
	if scene_to_validate(menu_path) == OK:
		if current_preview:
			current_preview.free()
		var new_menu = menu_to_load.instantiate()
		menu_preview.add_child(new_menu)
		new_menu.set_owner(menu_preview)
		current_preview = new_menu
		MENU_DEFAULTS.in_game_menu = menu_to_load

func scene_to_validate(new_scene_path: String)->Error:
	var new_scene = load(new_scene_path)
	var scene = new_scene.get_state()
	var scene_type = scene.get_node_type(0)

	if scene_type == "Control":
		return OK
	else:
		return ERR_INVALID_DATA

func _on_load_button_pressed() -> void:
	load_menu_scene.popup()

func _on_load_menu_scene_file_selected(path: String) -> void:
	if scene_to_validate(path) == OK:
		add_menu_to_list(path)
	else:
		push_error("Scene not a control node. Cannot load preview")

func _on_menu_list_item_selected(index: int) -> void:
	var menu_name = menu_list.get_item_text(index)
	var path = AVAILABLE_MENU_LIST.menu_list[menu_name]
	add_menu_to_preview(path)

