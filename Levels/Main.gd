extends Node3D

func _ready() -> void:
	MultiplayerManager.serverCreated.connect(_spawn_level)

func _spawn_level(path : String = "") -> void:
	for child in %LevelContainer.get_children():
		%LevelContainer.remove_child(child)
		child.queue_free()
	path = "res://Levels/Mainlevel.tscn"
	%LevelContainer.add_child(ResourceLoader.load(path).instantiate())
