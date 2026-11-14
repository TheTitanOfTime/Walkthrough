extends RefCounted


func test() -> bool:
	var level_1 := LevelConfig.load_number(1)
	var level_2 := LevelConfig.load_number(2)
	var level_3 := LevelConfig.load_number(3)
	if level_1 == null or level_2 == null or level_3 == null:
		return false
	if not ZoneGate.keeps("milk", level_1) or ZoneGate.keeps("eggs", level_1):
		return false
	if not ZoneGate.keeps("eggs", level_2) or ZoneGate.keeps("rice", level_2):
		return false
	if not ZoneGate.keeps("rice", level_3):
		return false
	return level_1.zone_ids.size() == 3 and level_2.zone_ids.size() == 4 and level_3.zone_ids.size() == 5
