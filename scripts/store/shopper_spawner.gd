class_name ShopperSpawner
extends Node3D

@export var shopper_scene: PackedScene

const SHOPPER_SCRIPT := preload("res://scripts/store/shopper.gd")


func _ready() -> void:
	var count := desired_count(Session.state.level)
	var nav := find_navigation(get_tree().root)
	for _i in count:
		var shopper := _make_shopper()
		add_child(shopper)
		shopper.position = Vector3(randf_range(-3.0, 3.0), 0.0, randf_range(-3.0, 3.0))
		if nav != null and shopper.has_method("setup"):
			shopper.call("setup", nav)


static func desired_count(level: LevelConfig) -> int:
	if level == null:
		return 0
	return level.npc_count


static func find_navigation(root: Node) -> NavigationRegion3D:
	return root.find_child("Navigation", true, false) as NavigationRegion3D


func _make_shopper() -> Node3D:
	if shopper_scene != null:
		return shopper_scene.instantiate() as Node3D
	var body := CharacterBody3D.new()
	body.name = "Shopper"
	body.set_script(SHOPPER_SCRIPT)
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.6
	shape.shape = capsule
	shape.position = Vector3(0, 0.8, 0)
	body.add_child(shape)
	return body