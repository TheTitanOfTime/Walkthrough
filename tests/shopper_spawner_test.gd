extends RefCounted

const LevelConfig := preload("res://scripts/domain/level_config.gd")
const ShopperSpawner := preload("res://scripts/store/shopper_spawner.gd")


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
	var shelf := Node3D.new()
	shelf.name = "tall_shelf2"
	var cashier := Node3D.new()
	cashier.name = "Cashier"
	var names_ok := ShopperSpawner.looks_like_shelf(shelf) and not ShopperSpawner.looks_like_shelf(cashier)
	shelf.free()
	cashier.free()
	if not names_ok:
		return false
	var blocked := PackedVector3Array([Vector3(0, 0, 0)])
	if ShopperSpawner.is_clear_of_shelves(Vector3(0.2, 0, 0), blocked, 0.9):
		return false
	if not ShopperSpawner.is_clear_of_shelves(Vector3(3, 0, 3), blocked, 0.9):
		return false
	return _finds_navigation_not_cashier()


func _finds_navigation_not_cashier() -> bool:
	var root := Node3D.new()
	var cashier := Node3D.new()
	cashier.name = "Cashier"
	root.add_child(cashier)
	# Wrong type under Cashier. Sibling same-name decoys force Godot to rename the real region.
	var decoy := Node3D.new()
	decoy.name = "Navigation"
	cashier.add_child(decoy)
	var nav := NavigationRegion3D.new()
	nav.name = "Navigation"
	root.add_child(nav)
	var found := ShopperSpawner.find_navigation(root)
	var ok := found == nav and ShopperSpawner.find_navigation(cashier) == null
	root.free()
	return ok
