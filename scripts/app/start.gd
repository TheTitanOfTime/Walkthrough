extends Control

const ScreenKit := preload("res://scripts/app/screen_kit.gd")


func _ready() -> void:
	var boot_level := _web_level_query()
	if boot_level > 0:
		Session.begin_level(boot_level)
		return
	var column := ScreenKit.mount(self)
	column.add_child(ScreenKit.heading("supermarket"))
	var start := ScreenKit.action_button("Start", true)
	start.pressed.connect(Session.show_level_select)
	column.add_child(start)
	start.grab_focus()


func _web_level_query() -> int:
	if not OS.has_feature("web"):
		return 0
	var raw := str(JavaScriptBridge.eval("window.location.search || ''"))
	if raw.is_empty() or not raw.begins_with("?"):
		return 0
	for part in raw.substr(1).split("&"):
		var pair := part.split("=")
		if pair.size() != 2:
			continue
		if pair[0] != "level":
			continue
		var number := int(pair[1])
		if number >= 1 and number <= 3:
			return number
	return 0
