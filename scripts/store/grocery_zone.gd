class_name GroceryZone
extends Area3D

@export var zone_id: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	Session.state.changed.connect(_sync_level)
	_sync_level()


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
	if not is_player_body(body):
		return
	Session.state.collect(zone_id)