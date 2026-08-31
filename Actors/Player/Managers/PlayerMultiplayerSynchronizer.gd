class_name PlayerMultiplayerSynchroniser extends Node
##Syncs properties required for player functionality aswell as handling as to whether they should be synced eg if they have changed since last frame. 
##It will sync Position, Rotation and Flashlight


func _ready() -> void:
	multiplayer.peer_connected.connect(_player_joined)

enum DataTypes {
	Position,
	Rotation,
	FlashLightState,
	
}

@export var localPlayer: Player = get_parent()
var prevPos: Vector3 = Vector3.ZERO
var prevRot: Vector3 = Vector3.ZERO

func tick() -> void:
	var id: String = localPlayer.name
	var data : Dictionary = {}
	
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

@rpc("any_peer", "call_local", "unreliable")
func _handle_multiplayer_flashlight_update(nameID : String, newMode : bool) -> void:
	var player: Player = MultiplayerManager.get_player_from_name(nameID)
	if !player: return
	player.flashLight.visible = newMode

func _player_joined(playerId : int) -> void:
	pass
