extends Node3D

const BALL = preload("uid://b0s1t7orvau07")


func _ready() -> void:
	MultiplayerManager.serverCreated.connect(_spawn_level)

func _spawn_level(path : String = "res://Mainlevel.tscn") -> void:
	for child in %LevelContainer.get_children():
		%LevelContainer.remove_child(child)
		child.queue_free()
	
	if not path:
		return
		
	
	%LevelContainer.add_child(ResourceLoader.load(path).instantiate())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ballTest"):
		_spawn_ball()

func _spawn_ball() -> void:
	var balls = BALL.instantiate() as RigidBody3D
	add_child(balls)
	balls.global_position = Vector3.ZERO
	balls.global_position.y += 10
