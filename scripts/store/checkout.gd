extends Node3D

const ScreenKit := preload("res://scripts/app/screen_kit.gd")
const SessionState := preload("res://scripts/domain/session_state.gd")
const LevelConfig := preload("res://scripts/domain/level_config.gd")
const CheckoutGate := preload("res://scripts/store/checkout_gate.gd")

var _column: VBoxContainer
var _count: Label
var _item: Label
var _lines: VBoxContainer
var _prompt: Label
var _pay: Button
var _next: Button
var _close: Button
var _hud_panel: Control
var _reopen: Button
var _hud_mode := false
var _step := 0


func _ready() -> void:
	# Full paper screen only on the session stand-in. In the 3D store, use a corner HUD.
	if get_parent() is Control:
		_column = ScreenKit.mount(self)
	else:
		_hud_mode = true
		var hud: Dictionary = ScreenKit.mount_hud(self)
		_column = hud["column"]
		_hud_panel = hud["panel"]
		_reopen = hud["reopen"]
		_reopen.pressed.connect(_show_hud)
		_close = ScreenKit.action_button("Close", false)
		_close.custom_minimum_size = Vector2(300, 48)
		_close.add_theme_font_size_override("font_size", 20)
		_close.pressed.connect(_hide_hud)
		_column.add_child(_close)
	_count = ScreenKit.heading("0 of 0")
	_count.add_theme_font_size_override("font_size", 36)
	_column.add_child(_count)
	_item = ScreenKit.note("")
	_column.add_child(_item)
	_lines = VBoxContainer.new()
	_lines.add_theme_constant_override("separation", 6)
	_column.add_child(_lines)
	_prompt = ScreenKit.note("")
	_column.add_child(_prompt)
	_pay = ScreenKit.action_button("Pay", true)
	_pay.custom_minimum_size = Vector2(300, 64)
	_pay.pressed.connect(_on_pay)
	_column.add_child(_pay)
	_next = ScreenKit.action_button("Next", true)
	_next.custom_minimum_size = Vector2(300, 64)
	_next.pressed.connect(_on_next)
	_column.add_child(_next)
	Session.state.changed.connect(_refresh)
	_refresh()
	# Panel starts open so the patient can read the list; walk with Tab then click.
	if _hud_mode:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if not _hud_mode:
		return
	# Tab toggles the list. Esc stays with the player mouse capture.
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		if _hud_panel != null and _hud_panel.visible:
			_hide_hud()
		else:
			_show_hud()
		get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	if Session.state.changed.is_connected(_refresh):
		Session.state.changed.disconnect(_refresh)


func _hide_hud() -> void:
	if not _hud_mode:
		return
	if _hud_panel != null:
		_hud_panel.visible = false
	if _reopen != null:
		_reopen.visible = true
		_reopen.text = _count.text if _count != null and not _count.text.is_empty() else "List"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _show_hud() -> void:
	if not _hud_mode:
		return
	if _hud_panel != null:
		_hud_panel.visible = true
	if _reopen != null:
		_reopen.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _refresh() -> void:
	var current := Session.state
	var level := current.level
	if level == null:
		_count.text = ""
		_item.text = ""
		_prompt.text = ""
		_pay.visible = false
		_next.visible = false
		return
	_count.text = "%d of %d" % [current.collected.size(), level.zone_ids.size()]
	_item.text = current.last_label()
	_fill_lines(current, level)
	var cashier := level.checkout == LevelConfig.CheckoutKind.CASHIER
	_pay.visible = not cashier
	_next.visible = cashier
	var ready := CheckoutGate.allows(current)
	_pay.disabled = not ready
	_next.disabled = _step >= 3 or (_step == 0 and not ready)
	_prompt.text = _prompt_text(current, cashier, ready)
	if _hud_mode and _reopen != null and _reopen.visible:
		_reopen.text = _count.text


func _fill_lines(current: SessionState, level: LevelConfig) -> void:
	for child in _lines.get_children():
		_lines.remove_child(child)
		child.free()
	for zone_id in level.zone_ids:
		var line := ScreenKit.note("")
		var state_word := "Collected" if current.collected.has(zone_id) else "Still to get"
		line.text = "%s. %s" % [LevelConfig.label_for(zone_id), state_word]
		_lines.add_child(line)


func _prompt_text(current: SessionState, cashier: bool, ready: bool) -> String:
	if _step == 1:
		return "Hello"
	if _step == 2:
		return ", ".join(_collected_labels(current))
	if _step == 3:
		return "Goodbye"
	if ready:
		if cashier:
			return "Next starts the checkout."
		return "Pay finishes the checkout."
	var left := current.remaining()
	if left == 1:
		return "1 remaining"
	return "%d remaining" % left


func _collected_labels(current: SessionState) -> PackedStringArray:
	var labels := PackedStringArray()
	if current.level == null:
		return labels
	for zone_id in current.level.zone_ids:
		if current.collected.has(zone_id):
			labels.append(LevelConfig.label_for(zone_id))
	return labels


func _on_pay() -> void:
	if not Session.try_begin_checkout():
		_refresh()
		return
	Session.complete_checkout()


func _on_next() -> void:
	if _step == 0:
		if not Session.try_begin_checkout():
			_refresh()
			return
		_step = 1
		_refresh()
		return
	if _step == 1:
		_step = 2
		_refresh()
		return
	if _step == 2:
		_step = 3
		_refresh()
		get_tree().create_timer(0.8).timeout.connect(Session.complete_checkout)
