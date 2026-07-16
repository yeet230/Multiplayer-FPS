class_name Player extends CharacterBody3D

@export var maxHealth: int = 100

var curHealth: float = 0

@onready var movementController: PlayerMovementController = %PlayerMovmentController
@onready var visionManager: VisionManager = $VisionManager
@onready var collisionShape: CollisionShape3D = $Body



func _ready() -> void:
	if !is_multiplayer_authority(): return
	
	curHealth = maxHealth
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var username: String = Globals.username
	if !multiplayer.is_server():
		MultiplayerManager.rpc_id(1, "register_player", username)
	
	_instantiate_UI()
	

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		visionManager.mouse_look_around(event.relative)
	elif event is InputEventAction:
		if event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	movementController.tick(delta)
	visionManager.tick(delta)
	
	_update_hud()

func _instantiate_UI() -> void:
	var uiScene = preload("res://Actors/Player/playerUI.tscn")
	var UI = uiScene.instantiate()
	UI.set_multiplayer_authority(get_multiplayer_authority())
	self.add_child(UI)

func _update_hud() -> void:
	Globals.Speed.emit(self.velocity.length())
	Globals.Position.emit(global_position)
	Globals.Dash.emit(movementController.usedDashCount, movementController.maxDashCount)

@rpc("any_peer")
func take_damage(dmg : float) -> void:
	print("Ouch that hurt ", dmg)
	curHealth -= dmg
	Globals.Health.emit(curHealth, maxHealth)
	if curHealth <= 0:
		print("Bleh")
	
	
