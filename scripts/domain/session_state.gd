class_name SessionState
extends RefCounted

const LevelConfig := preload("res://scripts/domain/level_config.gd")

signal changed

enum Phase { START, LEVEL_SELECT, SHOPPING, CHECKOUT }

var phase: Phase = Phase.START
var level: LevelConfig
var collected: Dictionary = {}


func start_level(level_number: int) -> bool:
	var next := LevelConfig.load_number(level_number)
	if next == null:
		return false
	level = next
	collected = {}
	phase = Phase.SHOPPING
	changed.emit()
	return true


func collect(zone_id: String) -> bool:
	if level == null or not level.zone_ids.has(zone_id):
		return false
	if collected.has(zone_id):
		return false
	collected[zone_id] = true
	changed.emit()
	return true


func required_complete() -> bool:
	if level == null:
		return false
	return collected.size() == level.zone_ids.size()


func begin_checkout() -> bool:
	if not required_complete():
		return false
	phase = Phase.CHECKOUT
	changed.emit()
	return true


func finish_checkout() -> bool:
	if phase != Phase.CHECKOUT:
		return false
	collected = {}
	phase = Phase.LEVEL_SELECT
	changed.emit()
	return true


func remaining() -> int:
	if level == null:
		return 0
	return level.zone_ids.size() - collected.size()


func last_label() -> String:
	var label := ""
	for zone_id in collected:
		label = LevelConfig.label_for(str(zone_id))
	return label
