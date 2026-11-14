extends RefCounted

const ShopperSpawner = preload("res://scripts/store/shopper_spawner.gd")


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
		push_error("desired_count level_3")
		return false
	return _finds_navigation_not_cashier()


func _finds_navigation_not_cashier() -> bool:
	var root := Node3D.new()
	var cashier := Node3D.new()
	cashier.name = "Cashier"
	root.add_child(cashier)
	var decoy := Node3D.new()
	decoy.name = "Navigation"
	root.add_child(decoy)
	var nav := NavigationRegion3D.new()
	nav.name = "Navigation"
	root.add_child(nav)
	print("children ", root.get_child_count(), " ", root.get_children())
	var found := ShopperSpawner.find_navigation(root)
	var cashier_nav := ShopperSpawner.find_navigation(cashier)
	var ok := found == nav and cashier_nav == null
	if not ok:
		print(
			"shopper nav debug found=%s nav=%s eq=%s cashier_nav=%s"
			% [found, nav, found == nav, cashier_nav]
		)
	root.free()
	return ok
