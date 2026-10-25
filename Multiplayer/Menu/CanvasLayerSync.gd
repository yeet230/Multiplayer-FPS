extends CanvasLayer

@export var mainNode: Control

func _on_multiplayer_menu_visibility_changed() -> void:
	print("VisibilityChanged")
	visible = mainNode.visible
