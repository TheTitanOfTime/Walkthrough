extends CharacterBody3D

enum Pace { WAIT, WALK }

const WALK_SPEED := 2.5
const GRAVITY := 20.0
const WAIT_MIN := 0.8
const WAIT_MAX := 2.5

var _agent: NavigationAgent3D
var _nav_map: RID = RID()
var _pace := Pace.WAIT
var _wait_left := 0.4
var _arm := 0


func setup(nav_region: NavigationRegion3D) -> void:
	if nav_region == null:
		return
	_nav_map = nav_region.get_navigation_map()
	_bind_agent_map()


func _ready() -> void:
	_agent = NavigationAgent3D.new()
	_agent.name = "NavigationAgent3D"
	add_child(_agent)
	_agent.avoidance_enabled = false
	_agent.path_desired_distance = 0.5
	_agent.target_desired_distance = 0.6
	_bind_agent_map()
	_wait_left = randf_range(0.2, 0.6)


func _bind_agent_map() -> void:
	if _agent == null or not _nav_map.is_valid():
		return
	_agent.set_navigation_map(_nav_map)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	if _pace == Pace.WAIT:
		_wait_left -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		if _wait_left <= 0.0:
			_pace = Pace.WALK
			_pick_target()
	elif _arm > 0:
		_arm -= 1
	elif _agent.is_navigation_finished():
		_begin_wait()
	else:
		var next := _agent.get_next_path_position()
		var flat := Vector3(next.x - global_position.x, 0.0, next.z - global_position.z)
		if flat.length_squared() < 0.04:
			velocity.x = 0.0
			velocity.z = 0.0
		else:
			var direction := flat.normalized()
			velocity.x = direction.x * WALK_SPEED
			velocity.z = direction.z * WALK_SPEED
	move_and_slide()


func _begin_wait() -> void:
	_pace = Pace.WAIT
	_wait_left = randf_range(WAIT_MIN, WAIT_MAX)
	_arm = 0
	velocity.x = 0.0
	velocity.z = 0.0


func _pick_target() -> void:
	if not _nav_map.is_valid() or NavigationServer3D.map_get_iteration_id(_nav_map) == 0:
		_begin_wait()
		return
	var point := NavigationServer3D.map_get_random_point(_nav_map, 1, true)
	if not point.is_finite():
		_begin_wait()
		return
	_agent.target_position = point
	_arm = 2
