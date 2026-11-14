extends Node

const SessionState := preload("res://scripts/domain/session_state.gd")

const LEVEL_SELECT_SCENE := "res://Scenes/app/level_select.tscn"
const START_SCENE := "res://Scenes/app/start.tscn"
const STORE_SCENE := "res://Scenes/store/store.tscn"
const SESSION_SCENE := "res://Scenes/app/session.tscn"

var state := SessionState.new()
var web_boot_level := 0


func _ready() -> void:
	web_boot_level = _read_web_level()
	if web_boot_level > 0:
		call_deferred("_boot_web_level")


func _boot_web_level() -> void:
	var level := web_boot_level
	web_boot_level = 0
	begin_level(level)


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
	if not state.finish_checkout():
		return
	if OS.has_feature("web"):
		# Back to the single therapist site.
		JavaScriptBridge.eval("window.location.replace('../')")
		return
	_open(LEVEL_SELECT_SCENE)


func _open(path: String) -> void:
	get_tree().call_deferred("change_scene_to_file", path)


func _read_web_level() -> int:
	if not OS.has_feature("web"):
		return 0
	var raw := str(
		JavaScriptBridge.eval(
			"(window.location && window.location.search) ? window.location.search : ''"
		)
	)
	if raw.is_empty() or raw == "null" or raw == "undefined":
		return 0
	if raw.begins_with("?"):
		raw = raw.substr(1)
	for part in raw.split("&"):
		var pair := part.split("=")
		if pair.size() < 2:
			continue
		if pair[0] != "level":
			continue
		var number := int(pair[1])
		if number >= 1 and number <= 3:
			return number
	return 0
