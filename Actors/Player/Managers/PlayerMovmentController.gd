class_name PlayerMovementController extends Node

@export_category("Ground Movement Settings")
@export var runSpd: float = 9.0 ##How fast the player can move when the runKey is pressed
@export var walkSpd: float = 6.0 ##how fast the player moves normally
@export var groundDecel: float = 5.0 ##
@export var groundFriction: float = 2.5 ##how muchg friction is applied when the player stops adding input
@export var groundAcel: float = 6.0 ##

@export_category("Air Movement Settings")
@export var JumpHeight: float = 9 ##How high the player can jump in meteres
@export var airAccel: float = 1.0 ##How much the player can add to their momentum while in the air
@export var airMoveSpd: float = 35.0 ##the limit to how much momentum the player can have in the air. The player will stop gaining momentum past this point in this script, external factors may change this
@export var airCap: float = 7.85 ##Helps cap the speed so moving in a diagnoal line does not goes stupidly fast

@export_category("Dash Settings")
@export var maxDashCount: int = 3  ##How many times the Player can dash after leaving contact with the floor.
@export var dashMulti: float = 1.5  ##The multiplier of runSpd to get the dash Spd.

var wishDir: Vector3 = Vector3.ZERO

var canDash: bool = true ##Store weather the player can dash or not
var isCrouched: bool = false

var usedDashCount: int = 0

var grav: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var player: Player = get_parent()

func tick(delta: float)-> void:
	var moveDir = Input.get_vector("left", "right", "forward", "backward")
	wishDir = player.global_transform.basis * Vector3(moveDir.x, 0.0, moveDir.y)
	
	if player.is_on_floor():
		_handle_jumping()
		_dash_reset()
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
		_handle_dash()
	
	player.move_and_slide()

func  _handle_ground_physics(delta : float) -> void:
	var cur_spd_in_dir: float = player.velocity.dot(wishDir)
	var add_spd_till_cap: float = _get_move_speed() - cur_spd_in_dir
	
	if add_spd_till_cap > 0:
		var accel_spd: float = groundAcel * delta * _get_move_speed()
		accel_spd = min(accel_spd, add_spd_till_cap)
		player.velocity += accel_spd * wishDir
	
	var control: float = max(player.velocity.length(), groundDecel)
	var drop = control * groundFriction * delta
	var new_spd: float = max(player.velocity.length() - drop, 0.0)
	if player.velocity.length() > 0:
		new_spd /= player.velocity.length()
	
	player.velocity *= new_spd

func _handle_air_physics(delta : float) -> void:
	player.velocity.y -= grav * delta # Apply gravity
	
	var cur_spd_in_wish_dir: float = player.velocity.dot(wishDir)
	var capped_spd = min((airMoveSpd * wishDir).length(), airCap)
	var add_spd_till_cap: float = capped_spd - cur_spd_in_wish_dir
	
	if add_spd_till_cap > 0:
		var accelSpd = airAccel * airMoveSpd * delta
		accelSpd = min(accelSpd, add_spd_till_cap)
		player.velocity += accelSpd * wishDir

func _handle_jumping() -> void:
	if Input.is_action_pressed("jump"):
		player.velocity.y = JumpHeight

func _handle_dash() -> void:
	if _can_dash():
		usedDashCount += 1
		var dashDir: Vector3 = -player.visionManager.get_camera().global_transform.basis.z
		dashDir += wishDir
		dashDir.y = dashDir.y * .01
		dashDir = dashDir.normalized() #normalize the velocity so the player does not go faster when going diagional
		player.velocity += dashDir * (runSpd * dashMulti) #Apply the Velocity

func _get_move_speed() -> float:
	if Input.is_action_pressed("crouch"):
		return walkSpd * 0.8
	elif Input.is_action_pressed("sprint"):
		return runSpd
	return walkSpd

func _can_dash() -> bool:
	return Input.is_action_just_pressed("dash") and (usedDashCount < maxDashCount)

func _dash_reset() -> void:
	usedDashCount = 0
