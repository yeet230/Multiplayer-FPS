extends Node3D

@onready var bakedMesh: MeshInstance3D = $Walls
@onready var decals: Node3D = $Decals
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var omni_light_3d: OmniLight3D = $OmniLight3D

func _ready() -> void:
	bakedMesh.visible = true
	
	if multiplayer.is_server():
		_handle_server_optimization()
	
	


func _handle_server_optimization() -> void:
	omni_light_3d.queue_free()
	world_environment.queue_free()
	decals.queue_free()
	
