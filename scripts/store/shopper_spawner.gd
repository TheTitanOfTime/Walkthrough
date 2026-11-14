class_name ShopperSpawner
extends Node3D

const LevelConfig := preload("res://scripts/domain/level_config.gd")

@export var shopper_scene: PackedScene

const SHOPPER_SCRIPT := preload("res://scripts/store/shopper.gd")


func _ready() -> void:
	var count := desired_count(Session.state.level)
	var scope: Node = get_tree().current_scene
	if scope == null:
		scope = get_parent()
	var nav := find_navigation(scope)
	for index in count:
		var shopper := _make_shopper(index + 1)
		if nav != null and shopper.has_method("setup"):
			shopper.call("setup", nav)
		add_child(shopper)
		shopper.position = Vector3(randf_range(-3.0, 3.0), 0.0, randf_range(-3.0, 3.0))


static func desired_count(level: LevelConfig) -> int:
	if level == null:
		return 0
	return level.npc_count


static func find_navigation(root: Node) -> NavigationRegion3D:
	if root == null:
		return null
	if root is NavigationRegion3D:
		return root
	for child in root.get_children():
		var found := find_navigation(child)
		if found != null:
			return found
	return null


func _make_shopper(index: int) -> Node3D:
	var body: Node3D = null
	if shopper_scene != null:
		var instanced := shopper_scene.instantiate()
		if instanced is CharacterBody3D:
			body = instanced
		elif instanced != null:
			instanced.free()
	if body == null:
		body = _capsule_body()
	body.remove_from_group("player")
	body.set_script(SHOPPER_SCRIPT)
	body.name = "Shopper%d" % index
	return body


func _capsule_body() -> CharacterBody3D:
	var body := CharacterBody3D.new()
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.6
	shape.shape = capsule
	shape.position = Vector3(0, 0.8, 0)
	body.add_child(shape)
	return body
