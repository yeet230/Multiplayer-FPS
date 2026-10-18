extends Node3D

@onready var bakedMesh: MeshInstance3D = $CSGBakedMeshInstance3D

func _ready() -> void:
	bakedMesh.visible = true
