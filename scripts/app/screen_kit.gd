class_name ScreenKit
extends RefCounted

const PAPER := Color("f3ecdf")
const INK := Color("1d1a16")
const MUTED := Color("5e584e")
const ACTION := Color("2c5b4d")
const ACTION_INK := Color("f7f3ea")
const QUIET := Color("efe6d6")
const QUIET_INK := Color("1d1a16")


static func mount(host: Node) -> VBoxContainer:
	var layer := CanvasLayer.new()
	layer.layer = 20
	host.add_child(layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.offset_left = 0
	root.offset_top = 0
	root.offset_right = 0
	root.offset_bottom = 0
	layer.add_child(root)

	var background := ColorRect.new()
	background.color = PAPER
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	root.add_child(center)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	column.custom_minimum_size = Vector2(520, 0)
	center.add_child(column)
	return column


## Store HUD: corner panel plus a reopen chip when the panel is closed.
## Returns { "column", "panel", "reopen" }.
static func mount_hud(host: Node) -> Dictionary:
	var layer := CanvasLayer.new()
	layer.layer = 20
	host.add_child(layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var margin := MarginContainer.new()
	margin.name = "HudPanel"
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.anchor_right = 0.0
	margin.anchor_bottom = 0.0
	margin.offset_left = 16
	margin.offset_top = 16
	margin.offset_right = 400
	margin.offset_bottom = 560
	margin.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(margin)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(PAPER, 0.92)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	margin.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	column.custom_minimum_size = Vector2(340, 0)
	panel.add_child(column)

	var reopen := action_button("List", false)
	reopen.name = "ReopenHud"
	reopen.custom_minimum_size = Vector2(120, 48)
	reopen.add_theme_font_size_override("font_size", 20)
	reopen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	reopen.position = Vector2(16, 16)
	reopen.visible = false
	root.add_child(reopen)

	return {"column": column, "panel": margin, "reopen": reopen}


static func heading(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 56)
	label.add_theme_color_override("font_color", INK)
	return label


static func note(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(520, 0)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", MUTED)
	return label


static func action_button(text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.custom_minimum_size = Vector2(520, 76)
	button.add_theme_font_size_override("font_size", 26)
	var fill := ACTION if primary else QUIET
	var ink := ACTION_INK if primary else QUIET_INK
	button.add_theme_stylebox_override("normal", _box(fill))
	button.add_theme_stylebox_override("hover", _box(fill.lightened(0.08)))
	button.add_theme_stylebox_override("pressed", _box(fill.darkened(0.08)))
	button.add_theme_stylebox_override("disabled", _box(Color("e4dccb")))
	button.add_theme_stylebox_override("focus", _box(fill, true))
	button.add_theme_color_override("font_color", ink)
	button.add_theme_color_override("font_disabled_color", MUTED)
	button.add_theme_color_override("font_hover_color", ink)
	button.add_theme_color_override("font_pressed_color", ink)
	button.add_theme_color_override("font_focus_color", ink)
	return button


static func _box(fill: Color, focused: bool = false) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.corner_radius_top_left = 10
	box.corner_radius_top_right = 10
	box.corner_radius_bottom_left = 10
	box.corner_radius_bottom_right = 10
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 12
	box.content_margin_bottom = 12
	if focused:
		box.border_color = INK
		box.set_border_width_all(2)
	return box
