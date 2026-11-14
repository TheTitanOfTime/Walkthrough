class_name ZoneGate
extends RefCounted


static func keeps(zone_id: String, level: LevelConfig) -> bool:
	return level != null and level.zone_ids.has(zone_id)
