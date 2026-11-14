extends RefCounted


func test() -> bool:
	var level_1 := LevelConfig.load_number(1)
	var level_2 := LevelConfig.load_number(2)
	if level_1 == null or level_2 == null:
		return false
	if not GroceryZone.active_for_level("milk", level_1):
		return false
	if GroceryZone.active_for_level("eggs", level_1):
		return false
	if not GroceryZone.active_for_level("eggs", level_2):
		return false
	var player := Node.new()
	player.name = "Player"
	if not GroceryZone.is_player_body(player):
		return false
	var other := Node.new()
	other.name = "Shopper"
	if GroceryZone.is_player_body(other):
		return false
	return true