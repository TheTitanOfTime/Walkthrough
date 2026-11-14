extends CharacterBody3D


@export var SPEED = 3.0
const JUMP_VELOCITY = 4.5
@export var look_sensitivity = 0.01
@onready var camera = $Camera3D

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# # Handle jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if (event.keycode == Key.KEY_ESCAPE):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		pass
	if event is InputEventMouseButton:
		print(event.button_index)
		if (event.button_index == 1):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			camera.rotate_x(-event.relative.y * look_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
