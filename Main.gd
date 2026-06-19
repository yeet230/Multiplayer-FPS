extends Node3D

#@export var level = preload("uid://bapqs3cu7phex")

func _ready() -> void:
	MultiplayerManager.serverCreated.connect(_spawn_level)

func _spawn_level(path : String = "res://Mainlevel.tscn") -> void:
	for child in %LevelContainer.get_children():
		%LevelContainer.remove_child(child)
		child.queue_free()
	
	if not path:
		return
		
	
	%LevelContainer.add_child(ResourceLoader.load(path).instantiate())
