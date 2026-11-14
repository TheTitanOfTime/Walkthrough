extends CharacterBody3D

const WALK_SPEED := 5.0
const GRAVITY := 20.0
const CAMERA_OFFSET := Vector3(0, 1.7, 4.0)
const LOOK_HEIGHT := 1.2

var _camera: Camera3D


func _ready() -> void:
	add_to_group("player")
	_camera = get_node_or_null("Camera3D") as Camera3D
	if _camera == null:
		_camera = Camera3D.new()
		_camera.name = "Camera3D"
		add_child(_camera)
	_camera.current = true
	_lock_camera()


func _physics_process(delta: float) -> void:
	var move := _read_move()
	if move != Vector2.ZERO:
		var direction := (transform.basis * Vector3(move.x, 0, move.y)).normalized()
		velocity.x = direction.x * WALK_SPEED
		velocity.z = direction.z * WALK_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0.0, WALK_SPEED)
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	_lock_camera()


func _lock_camera() -> void:
	_camera.position = CAMERA_OFFSET
	var target := global_position + Vector3(0, LOOK_HEIGHT, 0)
	if _camera.global_position.distance_squared_to(target) > 0.01:
		_camera.look_at(target, Vector3.UP)


static func axes(forward: bool, back: bool, left: bool, right: bool) -> Vector2:
	var input := Vector2.ZERO
	if forward:
		input.y -= 1
	if back:
		input.y += 1
	if left:
		input.x -= 1
	if right:
		input.x += 1
	if input.length_squared() > 1.0:
		input = input.normalized()
	return input


func _read_move() -> Vector2:
	return axes(
		Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP),
		Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN),
		Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT),
		Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)
	)
