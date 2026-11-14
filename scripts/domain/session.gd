extends Node

const LEVEL_SELECT_SCENE := "res://Scenes/app/level_select.tscn"
const START_SCENE := "res://Scenes/app/start.tscn"
const STORE_SCENE := "res://Scenes/store/store.tscn"
const SESSION_SCENE := "res://Scenes/app/session.tscn"

var state := SessionState.new()


func show_level_select() -> void:
	state.phase = SessionState.Phase.LEVEL_SELECT
	state.changed.emit()
	_open(LEVEL_SELECT_SCENE)


func begin_level(level_number: int) -> void:
	if not state.start_level(level_number):
		return
	if ResourceLoader.exists(STORE_SCENE):
		_open(STORE_SCENE)
	else:
		_open(SESSION_SCENE)


func try_begin_checkout() -> bool:
	return state.begin_checkout()


func complete_checkout() -> void:
	if state.finish_checkout():
		_open(LEVEL_SELECT_SCENE)


func _open(path: String) -> void:
	get_tree().change_scene_to_file(path)
