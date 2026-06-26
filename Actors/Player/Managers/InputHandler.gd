class_name InputHandler extends Node

var moveDir: Vector2 = Vector2.ZERO

var jump: bool = false
var dash: bool = false
var isRunning: bool = false
var isCrouched: bool = false

func tick() -> void:
	moveDir = Input.get_vector("left", "right", "forward", "backward")
	jump = Input.is_action_pressed("jump")
	isRunning = Input.is_action_just_pressed("sprint")
	isCrouched = Input.is_action_just_pressed("crouch")
	dash  = Input.is_action_just_pressed("dash")
