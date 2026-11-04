extends Node

const MAIN_MENU := "res://Scene/main_menu.tscn"

const LEVELS: Array[String] = [
	"res://Scene/level_1.tscn",
	"res://Scene/level_2.tscn",
	"res://Scene/level_3.tscn",
]

var current_level_index: int = 0


func start_game() -> void:
	current_level_index = 0
	_load_current_level()


func next_level() -> void:
	current_level_index += 1
	if current_level_index >= LEVELS.size():
		go_to_main_menu()
	else:
		_load_current_level()


func go_to_main_menu() -> void:
	current_level_index = 0
	get_tree().change_scene_to_file.call_deferred(MAIN_MENU)


func _load_current_level() -> void:
	get_tree().change_scene_to_file.call_deferred(LEVELS[current_level_index])
