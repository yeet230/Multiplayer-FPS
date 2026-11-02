extends CanvasLayer

@export var mainNode: Control

func _on_multiplayer_menu_visibility_changed() -> void:
	visible = mainNode.visible
