extends Control

const ScreenKit := preload("res://scripts/app/screen_kit.gd")


func _ready() -> void:
	# Web demo: therapist site picks the level. The game only boots a store from ?level=N.
	if OS.has_feature("web"):
		if Session.web_boot_level > 0:
			return
		JavaScriptBridge.eval("window.location.replace('../')")
		return
	# Editor / desktop: keep Start → level select for local testing.
	var column := ScreenKit.mount(self)
	column.add_child(ScreenKit.heading("supermarket"))
	var start := ScreenKit.action_button("Start", true)
	start.pressed.connect(Session.show_level_select)
	column.add_child(start)
	start.grab_focus()
