class_name Player extends CharacterBody3D

@export var maxHealth: int = 100

var curHealth: float = 0
var ui: PlayerUI

@onready var movementController: PlayerMovementController = %PlayerMovmentController
@onready var visionManager: VisionManager = $VisionManager
@onready var collisionShape: CollisionShape3D = $Body
@onready var flashLight: SpotLight3D = $VisionManager/Head/Camera3D/SpotLight3D
@onready var animPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if !is_multiplayer_authority(): return
	
	curHealth = maxHealth
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var username: String = Globals.username
	if !multiplayer.is_server():
		MultiplayerManager.register_player.rpc_id(1, username)
	
	_instantiate_UI()
	

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		visionManager.mouse_look_around(event.relative)
	elif event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.is_action_pressed("flash light"):
			flashLight.visible = !flashLight.visible #Set the new flashlight state
			_handle_multiplayer_flashlight_update.rpc(name, flashLight.visible) #update other players of the action

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	movementController.tick(delta)
	visionManager.tick(delta)
	ui.tick()
	
	_update_hud()

func _instantiate_UI() -> void:
	var uiScene = preload("res://Actors/Player/PlayerUI.tscn")
	ui = uiScene.instantiate()
	ui.set_multiplayer_authority(get_multiplayer_authority())
	self.add_child(ui)

func _update_hud() -> void:
	Globals.Speed.emit(self.velocity.length())
	Globals.Position.emit(global_position)
	Globals.Dash.emit(movementController.usedDashCount, movementController.maxDashCount)

@rpc("any_peer", "call_local", "unreliable_ordered")
func take_damage(dmg : float) -> void:
	#print("Ouch that hurt ", dmg)
	curHealth -= dmg
	
	if curHealth <= 0.0:
		position = get_parent().random_player_spawn()
		curHealth = maxHealth
		
	Globals.Health.emit(curHealth, maxHealth)
	

@rpc("any_peer", "call_local", "unreliable")
func _handle_multiplayer_flashlight_update(nameID : String, newMode : bool) -> void:
	var player: Player = MultiplayerManager.get_player_from_name(nameID)
	if !player: return
	player.flashLight.visible = newMode
