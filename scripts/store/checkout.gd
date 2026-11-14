extends Node3D

var _column: VBoxContainer
var _count: Label
var _item: Label
var _lines: VBoxContainer
var _prompt: Label
var _pay: Button
var _next: Button
var _step := 0


func _ready() -> void:
	_column = ScreenKit.mount(self)
	_count = ScreenKit.heading("0 of 0")
	_count.add_theme_font_size_override("font_size", 42)
	_column.add_child(_count)
	_item = ScreenKit.note("")
	_column.add_child(_item)
	_lines = VBoxContainer.new()
	_lines.add_theme_constant_override("separation", 6)
	_column.add_child(_lines)
	_prompt = ScreenKit.note("")
	_column.add_child(_prompt)
	_pay = ScreenKit.action_button("Pay", true)
	_pay.pressed.connect(_on_pay)
	_column.add_child(_pay)
	_next = ScreenKit.action_button("Next", true)
	_next.pressed.connect(_on_next)
	_column.add_child(_next)
	Session.state.changed.connect(_refresh)
	_refresh()


func _exit_tree() -> void:
	if Session.state.changed.is_connected(_refresh):
		Session.state.changed.disconnect(_refresh)


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
