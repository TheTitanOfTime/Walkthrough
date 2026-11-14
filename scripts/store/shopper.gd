extends CharacterBody3D

const WALK_SPEED := 2.5
const GRAVITY := 20.0
const WAIT_MIN := 0.8
const WAIT_MAX := 2.5

var _agent: NavigationAgent3D
var _nav_map: RID = RID()
var _wait_left := 0.0
var _waiting := false


func setup(nav_region: NavigationRegion3D) -> void:
	if nav_region != null:
		_nav_map = nav_region.get_navigation_map()


func _ready() -> void:
	_agent = NavigationAgent3D.new()
	add_child(_agent)
	_agent.avoidance_enabled = false
	await get_tree().physics_frame
	_agent.target_position = global_position
	_pick_target()


func _physics_process(delta: float) -> void:
	if _waiting:
		_wait_left -= delta
		velocity = Vector3.ZERO
		if _wait_left <= 0.0:
			_waiting = false
			_pick_target()
		move_and_slide()
		return
	if _agent.is_navigation_finished():
		_start_wait()
		move_and_slide()
		return
	var next := _agent.get_next_path_position()
	var flat := Vector3(next.x - global_position.x, 0.0, next.z - global_position.z)
	if flat.length_squared() < 0.01:
		move_and_slide()
		return
	var direction := flat.normalized()
	velocity.x = direction.x * WALK_SPEED
	velocity.z = direction.z * WALK_SPEED
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	move_and_slide()


func _start_wait() -> void:
	_waiting = true
	_wait_left = randf_range(WAIT_MIN, WAIT_MAX)
	velocity = Vector3.ZERO


func _pick_target() -> void:
	if _nav_map == RID():
		return
	var point := NavigationServer3D.map_get_random_point(_nav_map, 1, true)
	if point == Vector3.ZERO:
		return
	_agent.target_position = point