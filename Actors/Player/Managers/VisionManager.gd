class_name VisionManager extends Node3D

const CROUCH_TRANSLATE: float = .7 ##How much to change the players height by

@export var camerasList: Array[Camera3D] ##An array of cameras to be used in the game for debugging purposes. Always have the first person camera be 0, the first entry in the array

var isCrouched: bool = false
var lookSens: float = Globals.mouseSens
var activeCamera: int = 0

@onready var _originalCapsuleHeight: float = $"../Body".shape.height
@onready var player: Player = get_parent()
@onready var head: Node3D = $Head
@onready var weaponManager: WeaponManager = $Head/Camera3D/WeaponManager

func _ready() -> void:
	%Body.shape = %Body.shape.duplicate()
	print(%Body.shape)

func get_camera() -> Camera3D:
	return camerasList[activeCamera]

func change_camera() -> void:
	for _cam in camerasList:
		_cam.current = false
	activeCamera = (activeCamera + 1) % camerasList.size()
	camerasList[activeCamera].current = true #Set the ne camera to be active

func tick(delta : float) -> void:
	_handle_weapons()
	_handle_crouch(delta)

func _look_around(relative: Vector2, sensitivity : float) -> void:
	player.rotate_y(-relative.x * sensitivity)
	camerasList[activeCamera].rotate_x(-relative.y * sensitivity)
	camerasList[activeCamera].rotation_degrees.x = clampf(camerasList[activeCamera].rotation_degrees.x, -90, 90)

func _handle_crouch(delta : float) -> void:
	isCrouched = _decide_crouch()
	_crouch(delta)

func _crouch(delta : float) -> void:
	var _headMoveSpd: int = 7 ##How fast head of the player will move in m/s
	head.position.y = move_toward(head.position.y, (-CROUCH_TRANSLATE if isCrouched else 0.0), _headMoveSpd * delta) #Make the Camera Smoothly transition
	var newHeight = _originalCapsuleHeight - CROUCH_TRANSLATE if isCrouched else _originalCapsuleHeight #Change the size of the collision shape
	
	player.collisionShape.position.y = player.collisionShape.shape.height / 2 #Move the collision shape so it stays at the right base level

func _decide_crouch() -> bool:
	if Input.is_action_pressed("crouch"):
		return true
	elif player.test_move(player.global_transform, Vector3(0, CROUCH_TRANSLATE, 0)) and isCrouched:
		return true
	return false

func _handle_weapons() -> void:
	if Input.is_action_just_pressed("player_shoot"):
		weaponManager.player_trigger_pressed()
	elif Input.is_action_just_released("player_shoot"):
		weaponManager.player_trigger_released()

func controller_look_around(relative : Vector2) -> void:
	_look_around(relative, Globals.controllerSens)

func mouse_look_around(relative : Vector2) -> void:
	_look_around(relative, Globals.mouseSens)
