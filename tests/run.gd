extends SceneTree


func _initialize() -> void:
	var names: Array[String] = []
	var folder := DirAccess.open("res://tests")
	if folder == null:
		push_error("tests folder missing")
		quit(1)
		return
	folder.list_dir_begin()
	var file_name := folder.get_next()
	while file_name != "":
		if file_name.ends_with("_test.gd"):
			names.append(file_name)
		file_name = folder.get_next()
	folder.list_dir_end()
	names.sort()
	var ok := true
	for test_name in names:
		var script: GDScript = load("res://tests/%s" % test_name)
		var runner = script.new()
		if not runner.test():
			ok = false
			print("failed %s" % test_name)
	if ok:
		print("session ok")
	quit(0 if ok else 1)
