extends Node3D

const MAINLEVEL = preload("uid://bapqs3cu7phex")

func _ready() -> void:
	MultiplayerManager.serverCreated.connect(_spawn_level)
	multiplayer.server_disconnected.connect(_destroy_level)

func _spawn_level() -> void:
	_destroy_level()
	
	%LevelContainer.add_child(MAINLEVEL.instantiate())
	
	if multiplayer.is_server(): return
	assert(false, "idk just wanna see what hapopens")

func _destroy_level() -> void:
	for child in %LevelContainer.get_children():
		%LevelContainer.remove_child(child)
		child.queue_free()
