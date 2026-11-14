extends RefCounted


func test() -> bool:
	var level_1 := LevelConfig.load_number(1)
	var level_2 := LevelConfig.load_number(2)
	var level_3 := LevelConfig.load_number(3)
	if level_1 == null or level_2 == null or level_3 == null:
		return false
	if ShopperSpawner.desired_count(null) != 0:
		return false
	if ShopperSpawner.desired_count(level_1) != 0:
		return false
	if ShopperSpawner.desired_count(level_2) != 10:
		return false
	if ShopperSpawner.desired_count(level_3) != 20:
		return false
	return true