class_name VisionManager extends Node3D

const CROUCH_TRANSLATE: float = .7 ##How much to change the players height by
const HEADBOB_MOVE_AMOUNT: float = .06
const HEADBOB_FREQUENCY: float = 2.4
var headbob_time: float = 0.0

@export var camerasList: Array[Camera3D] ##An array of cameras to be used in the game for debugging purposes. Always have the first person camera be 0, the first entry in the array
@export var player: Player

var isCrouchPressed: bool = false
var isCrouched: bool = false
var lookSens: float = Globals.mouseSens
var activeCamera: int = 0

@onready var head: Node3D = $Head

func get_camera() -> Camera3D:
	return camerasList[activeCamera]

func change_camera() -> void:
	for _cam in camerasList:
		_cam.current = false
	activeCamera = (activeCamera + 1) % camerasList.size()
	camerasList[activeCamera].current = true #Set the ne camera to be active

func tick(delta : float) -> void:
	if !is_multiplayer_authority(): return
	#_handle_crouch(delta)
	
	if player.is_on_floor():
		_headbob_effect(delta)

var prevState: bool
func _handle_crouch(_delta : float) -> void:
	isCrouched = _decide_crouch()
	
	#var _headMoveSpd: int = 7 ##How fast head of the player will move in m/s
	#head.position.y = move_toward(head.position.y, (-CROUCH_TRANSLATE if isCrouched else 0.0), _headMoveSpd * delta) #Make the Camera Smoothly transition
	#player.collisionShape.position.y = player.collisionShape.shape.height / 2 #Move the collision shape so it stays at the right base level
	
	if isCrouched != prevState:
		_multiplayer_crouch_update.rpc(player.name, isCrouched)
	
	prevState = isCrouched
	

func _decide_crouch() -> bool:
	if isCrouchPressed: ##Done
		return true
	elif player.test_move(player.global_transform, Vector3(0, CROUCH_TRANSLATE, 0)) and isCrouched:
		return true
	return false

func _look_around(relative: Vector2, sensitivity : float) -> void:
	player.rotate_y(-relative.x * sensitivity)
	camerasList[activeCamera].rotate_x(-relative.y * sensitivity)
	camerasList[activeCamera].rotation_degrees.x = clampf(camerasList[activeCamera].rotation_degrees.x, -90, 90)

func _headbob_effect(delta : float):
	headbob_time += delta * player.velocity.length()
	camerasList[activeCamera].transform.origin = Vector3(
		cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
		sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
		0
	)

func controller_look_around(relative : Vector2) -> void:
	_look_around(relative, Globals.controllerSens)

func mouse_look_around(relative : Vector2) -> void:
	_look_around(relative, Globals.mouseSens)

@rpc("authority", "call_remote", "unreliable")
func _multiplayer_crouch_update(nameID : String, newState : bool) -> void:
	var multiPlayer: Player = MultiplayerManager.get_player_from_name(nameID)
	if newState:
		multiPlayer.animPlayer.play("Crouch")
	else:
		multiPlayer.animPlayer.play("Stand")
