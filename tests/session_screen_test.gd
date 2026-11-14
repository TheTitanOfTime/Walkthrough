extends RefCounted


func test() -> bool:
	var packed := load("res://Scenes/app/session.tscn") as PackedScene
	if packed == null:
		return false
	var root := packed.instantiate()
	var attached: Script = root.get_script()
	var checkout := root.get_node_or_null("Checkout")
	var ok := attached != null
	ok = ok and attached.resource_path == "res://scripts/app/session_screen.gd"
	ok = ok and checkout != null
	ok = ok and checkout.get_script() != null
	ok = ok and checkout.get_script().resource_path == "res://scripts/store/checkout.gd"
	root.free()
	return ok
