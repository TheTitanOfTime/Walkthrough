extends Control

const ScreenKit := preload("res://scripts/app/screen_kit.gd")
const LevelConfig := preload("res://scripts/domain/level_config.gd")
const SESSION_SCENE := "res://Scenes/app/session.tscn"

var _collect_row: HBoxContainer


func _ready() -> void:
	if scene_file_path != SESSION_SCENE:
		return
	var layer := CanvasLayer.new()
	layer.layer = 30
	add_child(layer)
	var bar := MarginContainer.new()
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.anchor_top = 1.0
	bar.anchor_bottom = 1.0
	bar.offset_top = -120.0
	bar.add_theme_constant_override("margin_left", 16)
	bar.add_theme_constant_override("margin_right", 16)
	bar.add_theme_constant_override("margin_bottom", 16)
	layer.add_child(bar)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(center)
	_collect_row = HBoxContainer.new()
	_collect_row.add_theme_constant_override("separation", 8)
	center.add_child(_collect_row)
	Session.state.changed.connect(_rebuild_collect)
	_rebuild_collect()


func _exit_tree() -> void:
	if Session.state.changed.is_connected(_rebuild_collect):
		Session.state.changed.disconnect(_rebuild_collect)


func _rebuild_collect() -> void:
	if _collect_row == null:
		return
	for child in _collect_row.get_children():
		_collect_row.remove_child(child)
		child.queue_free()
	var level := Session.state.level
	if level == null:
		return
	for zone_id in level.zone_ids:
		var button := ScreenKit.action_button("Enter %s" % LevelConfig.label_for(zone_id), false)
		button.custom_minimum_size = Vector2(168, 64)
		button.add_theme_font_size_override("font_size", 18)
		var id := zone_id
		button.pressed.connect(func() -> void:
			Session.state.collect(id)
		)
		_collect_row.add_child(button)
