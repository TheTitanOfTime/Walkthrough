extends RefCounted

const LevelConfig := preload("res://scripts/domain/level_config.gd")
const GroceryZone := preload("res://scripts/store/grocery_zone.gd")


func test() -> bool:
	var level_1 := LevelConfig.load_number(1)
	var level_2 := LevelConfig.load_number(2)
	var level_3 := LevelConfig.load_number(3)
	if level_1 == null or level_2 == null or level_3 == null:
		return false
	if not GroceryZone.active_for_level("milk", level_1):
		return false
	if GroceryZone.active_for_level("eggs", level_1):
		return false
	if not GroceryZone.active_for_level("eggs", level_2):
		return false
	if not GroceryZone.active_for_level("rice", level_3):
		return false
	var player := Node.new()
	player.name = "Player"
	var shopper := Node.new()
	shopper.name = "Shopper"
	var grouped := Node.new()
	grouped.name = "Body"
	grouped.add_to_group("player")
	var ok := GroceryZone.wants_collect("milk", level_1, player)
	ok = ok and not GroceryZone.wants_collect("eggs", level_1, player)
	ok = ok and GroceryZone.wants_collect("rice", level_3, player)
	ok = ok and not GroceryZone.wants_collect("milk", level_1, shopper)
	ok = ok and GroceryZone.wants_collect("milk", level_1, grouped)
	ok = ok and not GroceryZone.wants_collect("soap", level_1, player)
	player.free()
	shopper.free()
	grouped.free()
	return ok
