extends Control


func _ready() -> void:
	var column := ScreenKit.mount(self)
	column.add_child(ScreenKit.heading("Choose a level"))
	var first: Button = null
	for level in LevelConfig.load_all():
		var button := ScreenKit.action_button(level.button_text(), false)
		button.custom_minimum_size = Vector2(520, 148)
		button.pressed.connect(_choose.bind(level.level_number))
		column.add_child(button)
		if first == null:
			first = button
	if first != null:
		first.grab_focus()


func _choose(level_number: int) -> void:
	Session.begin_level(level_number)
