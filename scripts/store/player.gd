extends CharacterBody3D

const WALK_SPEED := 5.0
const GRAVITY := 20.0
const LOOK_SENSITIVITY := 0.0025
const EYE_HEIGHT := 1.55


var _camera: Camera3D


func _ready() -> void:
	add_to_group("player")
	_camera = get_node_or_null("Camera3D") as Camera3D
	if _camera == null:
		_camera = Camera3D.new()
		_camera.name = "Camera3D"
		add_child(_camera)
	_camera.position = Vector3(0, EYE_HEIGHT, 0)
	_camera.rotation = Vector3.ZERO
	_camera.current = true
	_hide_third_person_mesh()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _hide_third_person_mesh() -> void:
	for child in get_children():
		if child == _camera or child is CollisionShape3D:
			continue
		if child is Node3D:
			(child as Node3D).visible = false


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


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
			return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * LOOK_SENSITIVITY)
		_camera.rotate_x(-event.relative.y * LOOK_SENSITIVITY)
		_camera.rotation.x = clampf(_camera.rotation.x, deg_to_rad(-89.0), deg_to_rad(89.0))


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
	var mapped := Input.get_vector("left", "right", "forward", "backward")
	if mapped != Vector2.ZERO:
		return mapped
	return axes(
		Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP),
		Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN),
		Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT),
		Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)
	)
