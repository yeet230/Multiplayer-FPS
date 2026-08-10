class_name Player extends CharacterBody3D

@export var maxHealth: float = Globals.playerStartingHealth

var curHealth: float = 0
var ui: PlayerUI

@onready var playerInputHandler: PlayerInptHandler = $PlayerInptHandler
@onready var movementController: PlayerMovementController = %PlayerMovmentController
@onready var visionManager: VisionManager = $VisionManager
@onready var weaponManager: WeaponManager = $VisionManager/Head/Camera3D/WeaponManager
@onready var collisionShape: CollisionShape3D = $BodyCollision
@onready var flashLight: SpotLight3D = $VisionManager/Head/Camera3D/MainLight
@onready var animPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if !is_multiplayer_authority(): return
	
	curHealth = maxHealth
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var username: String = Globals.username
	if !multiplayer.is_server():
		MultiplayerManager.server_register_player.rpc_id(1, curHealth, username)
	
	_instantiate_UI()
	multiplayer.peer_connected.connect(_peer_connected_sync)
	Globals.clientPlayer = self

func _process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	ui.tick()
	

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	playerInputHandler.tick()
	
	movementController.tick(delta)
	visionManager.tick(delta)
	weaponManager.tick()
	
	

func _instantiate_UI() -> void:
	var uiScene = preload("res://Actors/Player/playerUI.tscn")
	ui = uiScene.instantiate()
	ui.set_multiplayer_authority(get_multiplayer_authority())
	$PlayerUI.add_child(ui)

func handle_flashlight() -> void:
	flashLight.visible = !flashLight.visible #Set the new flashlight state
	_handle_multiplayer_flashlight_update.rpc(name, flashLight.visible) #update other players of the action

func _peer_connected_sync(id: int) -> void:
	_handle_multiplayer_flashlight_update.rpc_id(id, name, flashLight.visible)

@rpc("any_peer", "call_local", "unreliable")
func _handle_multiplayer_flashlight_update(nameID : String, newMode : bool) -> void:
	var player: Player = MultiplayerManager.get_player_from_name(nameID)
	if !player: return
	player.flashLight.visible = newMode
