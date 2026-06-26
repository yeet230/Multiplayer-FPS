extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENS: float = 0.002

func _ready() -> void:
	if !is_multiplayer_authority(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if multiplayer.is_server():
		MultiplayerManager.register_player("Host")
	else:
		MultiplayerManager.rpc_id(1, "register_player")

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()


func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	elif event is InputEventMouseMotion:
		look_around(event.relative)
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("ballTest"):
		spawn_ball()
	elif event.is_action_pressed("ui_accept"):
		handle_chat()

func handle_chat() -> void:
	if multiplayer.is_server():
		MultiplayerManager.send_chat("Hello World from host")
	else:
		MultiplayerManager.rpc_id(1, "send_chat", "Hello world from client")

func spawn_ball() -> void:
	if multiplayer.is_server():
		MultiplayerManager.spawn_ball(global_position)
	else:
		MultiplayerManager.spawn_ball.rpc_id(1, global_position)


func look_around(relative : Vector2) -> void:
	rotate_y(-relative.x * SENS)
	$Camera3D.rotate_x(-relative.y * SENS)
	$Camera3D.rotation_degrees.x = clampf($Camera3D.rotation_degrees.x, -90.0, 90.0)
