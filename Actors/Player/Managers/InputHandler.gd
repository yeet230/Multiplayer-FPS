class_name PlayerInptHandler extends Node

@export var player: Player = get_parent()

var isJumpPressed: bool = false
var isSprintPressed: bool = false
var isCrouchPressed: bool = false
var isDashPressed: bool = false
var moveDir: Vector2

var toggleChat: bool = false
var isEnterPressed: bool = false
var isBackPressed: bool = false

var isShootPressed: bool = false
var isReloadPressed: bool = false
var isShootReleased: bool = false

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		player.visionManager.mouse_look_around(event.relative)
	
	elif event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.is_action_pressed("flash light"):
			player.handle_flashlight()
			

func tick() -> void:
	_update_input_values()
	_push_updated_input_values()

func _update_input_values() -> void:
	isJumpPressed = Input.is_action_pressed("jump")
	isCrouchPressed = Input.is_action_pressed("crouch")
	isSprintPressed = Input.is_action_pressed("sprint")
	isDashPressed = Input.is_action_just_pressed("dash")
	moveDir = Input.get_vector("left", "right", "forward", "backward")
	
	isShootPressed = Input.is_action_pressed("player_shoot")
	isShootReleased = Input.is_action_just_released("player_shoot")
	isReloadPressed = Input.is_action_just_pressed("reload")
	
	toggleChat = Input.is_action_just_pressed("toggle chat")
	isEnterPressed = Input.is_action_just_pressed("ui_accept")
	isBackPressed = Input.is_action_just_pressed("ui_cancel")

func _push_updated_input_values() -> void:
	player.movementController.isCrouchPressed = isCrouchPressed
	player.movementController.isSprintPressed = isSprintPressed
	player.movementController.isDashPressed = isDashPressed
	player.movementController.isJumpPressed = isJumpPressed
	player.movementController.moveDir = moveDir
	
	player.weaponManager.isReloadPressed = isReloadPressed
	player.weaponManager.isShootPressed = isShootPressed
	player.weaponManager.isShootReleased = isShootReleased
	
	player.ui.isBackPressed = isBackPressed
	player.ui.isEnterPressed = isEnterPressed
	player.ui.toggleChat = toggleChat
