extends SceneTree

const _WARM_SCRIPTS := [
	"res://scripts/domain/level_config.gd",
	"res://scripts/domain/session_state.gd",
	"res://scripts/store/zone_gate.gd",
	"res://scripts/store/checkout_gate.gd",
	"res://scripts/app/screen_kit.gd",
]


func _initialize() -> void:
	for warm_path in _WARM_SCRIPTS:
		load(warm_path)
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
		var path := "res://tests/%s" % test_name
		var script: GDScript = load(path) as GDScript
		if script == null:
			ok = false
			push_error("failed to load %s" % test_name)
			continue
		if not script.can_instantiate():
			ok = false
			push_error("failed to compile %s" % test_name)
			continue
		var runner = script.new()
		if runner == null or not runner.has_method("test") or not runner.test():
			ok = false
			print("failed %s" % test_name)
	if ok:
		print("session ok")
	quit(0 if ok else 1)
