class_name GroceryZone
extends Area3D

const LevelConfig := preload("res://scripts/domain/level_config.gd")
const ZoneGate := preload("res://scripts/store/zone_gate.gd")

@export var zone_id: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	Session.state.changed.connect(_sync_level)
	_ensure_marker()
	_sync_level()


func _ensure_marker() -> void:
	if has_node("Marker"):
		return
	var mesh := MeshInstance3D.new()
	mesh.name = "Marker"
	var box := BoxMesh.new()
	box.size = Vector3(1.2, 1.4, 1.2)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.55, 0.35, 0.45)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material_override = mat
	add_child(mesh)


func _exit_tree() -> void:
	if Session.state.changed.is_connected(_sync_level):
		Session.state.changed.disconnect(_sync_level)


static func active_for_level(zone_id: String, level: LevelConfig) -> bool:
	return ZoneGate.keeps(zone_id, level)


static func is_player_body(body: Node) -> bool:
	if body == null:
		return false
	if body.name == "Player":
		return true
	return body.is_in_group("player")


static func wants_collect(zone_id: String, level: LevelConfig, body: Node) -> bool:
	return is_player_body(body) and active_for_level(zone_id, level)


func _sync_level() -> void:
	var active := active_for_level(zone_id, Session.state.level)
	visible = active
	monitoring = active
	monitorable = active
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = not active
		elif child is MeshInstance3D:
			child.visible = active


func _on_body_entered(body: Node3D) -> void:
	if wants_collect(zone_id, Session.state.level, body):
		Session.state.collect(zone_id)