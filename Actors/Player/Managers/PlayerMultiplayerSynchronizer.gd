class_name PlayerMultiplayerSynchroniser extends Node

enum DataTypes {
	Position,
	Rotation,
	
}

@export var localPlayer: Player = get_parent()

var prevPos: Vector3 = Vector3.ZERO
var prevRot: Vector3 = Vector3.ZERO


func tick() -> void:
	
	var id: String = localPlayer.name
	var data :Dictionary= {}
	
	if prevPos != localPlayer.global_position:
		data[DataTypes.Position] = localPlayer.global_position
		prevPos = localPlayer.global_position
	
	if prevRot != localPlayer.rotation:
		data[DataTypes.Rotation] = localPlayer.rotation
		prevRot = localPlayer.rotation
	
	if !data.is_empty():
		_update_data.rpc(id, data)
	
	

@rpc("any_peer", "call_remote", "reliable")
func _update_data(who : String, data : Dictionary) -> void:
	
	var player: Player = MultiplayerManager.get_player_from_name(who)
	
	if data.has(DataTypes.Position):
		player.global_position = data[DataTypes.Position]
	if data.has(DataTypes.Rotation):
		player.rotation = data[DataTypes.Rotation]
