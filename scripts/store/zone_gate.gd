class_name ZoneGate
extends RefCounted

const LevelConfig := preload("res://scripts/domain/level_config.gd")


static func keeps(zone_id: String, level: LevelConfig) -> bool:
	return level != null and level.zone_ids.has(zone_id)
