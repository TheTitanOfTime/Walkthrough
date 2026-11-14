class_name ShopperSpawner
extends Node3D

const LevelConfig := preload("res://scripts/domain/level_config.gd")

@export var shopper_scene: PackedScene
@export var aisle_clearance := 0.9
@export var spawn_attempts := 40

const SHOPPER_SCRIPT := preload("res://scripts/store/shopper.gd")
const APPEARANCE := preload(
	"res://Assets/kenney_mini-shop_2.1/Models/GLB format/character-employee.glb"
)
const SHELF_NAME_HINTS := [
	"shelf",
	"tall_shelf",
	"boxes",
	"meat_case",
	"display-bread",
	"cash-register",
	"Walls",
]


func _ready() -> void:
	call_deferred("_spawn_when_ready")


func _spawn_when_ready() -> void:
	var level := Session.state.level
	var count := desired_count(level)
	if count <= 0:
		return
	var scope: Node = get_tree().current_scene
	if scope == null:
		scope = get_parent()
	var nav := find_navigation(scope)
	await _wait_for_navigation(nav)
	var blocked := collect_blocked_points(scope)
	for index in count:
		var shopper := _make_shopper(index + 1)
		add_child(shopper)
		if nav != null and shopper.has_method("setup"):
			shopper.call("setup", nav)
		shopper.global_position = pick_spawn_point(nav, blocked, global_position)


func _wait_for_navigation(nav: NavigationRegion3D) -> void:
	if nav == null:
		return
	for _attempt in 12:
		var map := nav.get_navigation_map()
		if map.is_valid() and NavigationServer3D.map_get_iteration_id(map) > 0:
			return
		await get_tree().physics_frame


static func desired_count(level: LevelConfig) -> int:
	if level == null:
		return 0
	return level.npc_count


static func find_navigation(root: Node) -> NavigationRegion3D:
	if root == null:
		return null
	if root is NavigationRegion3D and root.name == "Navigation":
		return root
	for child in root.get_children():
		var found := find_navigation(child)
		if found != null:
			return found
	return null


static func looks_like_shelf(node: Node) -> bool:
	var lowered := String(node.name).to_lower()
	for hint in SHELF_NAME_HINTS:
		if lowered.contains(hint.to_lower()):
			return true
	return false


static func collect_blocked_points(root: Node) -> PackedVector3Array:
	var points := PackedVector3Array()
	_collect_blocked(root, points)
	return points


static func _collect_blocked(node: Node, points: PackedVector3Array) -> void:
	if node is Node3D and looks_like_shelf(node):
		points.append((node as Node3D).global_position)
	for child in node.get_children():
		_collect_blocked(child, points)


static func is_clear_of_shelves(point: Vector3, blocked: PackedVector3Array, clearance: float) -> bool:
	var clearance_sq := clearance * clearance
	for shelf_point in blocked:
		var delta := Vector3(point.x - shelf_point.x, 0.0, point.z - shelf_point.z)
		if delta.length_squared() < clearance_sq:
			return false
	return true


func pick_spawn_point(nav: NavigationRegion3D, blocked: PackedVector3Array, fallback: Vector3) -> Vector3:
	if nav != null:
		var map := nav.get_navigation_map()
		if map.is_valid() and NavigationServer3D.map_get_iteration_id(map) > 0:
			for _attempt in spawn_attempts:
				var candidate: Vector3 = NavigationServer3D.map_get_random_point(map, 1, false)
				if candidate.is_finite() and is_clear_of_shelves(candidate, blocked, aisle_clearance):
					return candidate
	for _attempt in spawn_attempts:
		var local := Vector3(randf_range(-4.5, 4.5), 0.0, randf_range(1.5, 10.5))
		var world := fallback + local
		if is_clear_of_shelves(world, blocked, aisle_clearance):
			return world
	return fallback + Vector3(randf_range(-2.0, 2.0), 0.0, randf_range(2.0, 4.0))


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
	var look := APPEARANCE.instantiate()
	look.name = "Appearance"
	body.add_child(look)
	return body
