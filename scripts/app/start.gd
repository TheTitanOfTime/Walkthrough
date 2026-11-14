extends Control


func _ready() -> void:
	var column := ScreenKit.mount(self)
	column.add_child(ScreenKit.heading("Walkthrough"))
	var start := ScreenKit.action_button("Start", true)
	start.pressed.connect(Session.show_level_select)
	column.add_child(start)
	start.grab_focus()
