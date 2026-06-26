class_name Player extends CharacterBody3D

@onready var movementController: PlayerMovementController = $PlayerMovmentController
@onready var visionManager: VisionManager = $VisionManager
@onready var collisionShape: CollisionShape3D = $Body

func _ready() -> void:
	if !is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var username: String = Globals.username
	if multiplayer.is_server():
		MultiplayerManager.register_player(username)
	else:
		MultiplayerManager.rpc_id(1, "register_player", username)

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		visionManager.mouse_look_around(event.relative)

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	movementController.tick(delta)
	visionManager.tick(delta)
	
	_update_hud()



func _update_hud() -> void:
	Globals.Speed.emit(self.velocity.length())
	Globals.Position.emit(global_position)
	Globals.Dash.emit(movementController.usedDashCount, movementController.maxDashCount)
