class_name Player extends CharacterBody3D

@export var maxHealth: float = Globals.playerStartingHealth

var playerEnabledLight: bool = true
var flashLightOn: bool
var curHealth: float = Globals.playerStartingHealth
var ui: PlayerUI

const NEW_STANDARD_MATERIAL_3D = preload("uid://b1501ncct6v6k")

@onready var playerInputHandler: PlayerInptHandler = $PlayerInptHandler
@onready var movementController: PlayerMovementController = %PlayerMovmentController
@onready var visionManager: VisionManager = $VisionManager
@onready var weaponManager: WeaponManager = $VisionManager/Head/MainCam/WeaponManager
@onready var collisionShape: CollisionShape3D = $BodyCollision
@onready var flashLight: SpotLight3D = $VisionManager/Head/MainCam/MainLight
@onready var animPlayer: AnimationPlayer = $AnimationPlayer
@onready var mainCam: Camera3D = $VisionManager/Head/MainCam
@onready var playerNetworkHandler: PlayerNetworkHandler = $PlayerMultiplayerSynchroniser
@onready var bodyMesh: MeshInstance3D = %BodyMesh

func _ready() -> void:
	bodyMesh.mesh.surface_set_material(0, NEW_STANDARD_MATERIAL_3D)
	
	if !is_multiplayer_authority(): return
	multiplayer.peer_connected.connect(_peer_connected_sync)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_instantiate_UI()
	
	
	flashLightOn = flashLight.visible
	curHealth = maxHealth
	Globals.clientPlayer = self		## Feel free to change this. The server will be fine. 😇

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	playerInputHandler.tick()
	_handle_flashlight()
	
	movementController.tick(delta)
	visionManager.tick(delta)
	weaponManager.tick()
	playerNetworkHandler.tick()
	ui.tick()
	

func _instantiate_UI() -> void:
	var uiScene = preload("res://Actors/Player/playerUI.tscn")
	ui = uiScene.instantiate()
	ui.set_multiplayer_authority(get_multiplayer_authority())
	$PlayerUI.add_child(ui)

@rpc("any_peer", "call_local", "unreliable")
func _handle_multiplayer_flashlight_update(newMode : bool) -> void:
	var playerId: int = multiplayer.get_remote_sender_id()
	var player: Player = MultiplayerManager.get_player_from_name(str(playerId))
	if !player: return
	player.flashLight.visible = newMode

func _handle_flashlight() -> void:
	flashLight.visible = true if self.velocity != Vector3.ZERO or playerEnabledLight else false #Set the flashlight state
	flashLightOn = flashLight.visible

func _peer_connected_sync(id: int) -> void:
	_handle_multiplayer_flashlight_update.rpc_id(id, flashLight.visible)

func get_camera_position() -> Vector3:
	var returnPos: Vector3 = mainCam.global_position
	return returnPos
