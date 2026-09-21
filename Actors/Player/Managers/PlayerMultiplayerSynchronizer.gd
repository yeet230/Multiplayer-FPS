class_name PlayerMultiplayerSynchroniser extends Node
##Syncs properties required for player functionality aswell as handling as to whether they should be synced eg if they have changed since last frame. 
##It will sync Position, Rotation and Flashlight

enum DataTypes {
	Position,
	Rotation,
	FlashLightState,
	
}

@export var localPlayer: Player = get_parent()

var prevPos: Vector3 = Vector3.ZERO
var prevRot: Vector3 = Vector3.ZERO
var prevLightState: bool

func _ready() -> void:
	multiplayer.peer_connected.connect(_player_joined)
	#prevLightState = localPlayer.flashLight.visible

func tick() -> void:
	var id: String = localPlayer.name
	var data : Dictionary
	
	if prevPos != localPlayer.global_position:
		data[DataTypes.Position] = localPlayer.global_position
		prevPos = localPlayer.global_position
	
	if prevRot != localPlayer.rotation:
		data[DataTypes.Rotation] = localPlayer.rotation
		prevRot = localPlayer.rotation
	
	if !data.is_empty():
		_update_data.rpc(data)

@rpc("any_peer", "call_remote", "reliable")
func _update_data(data : Dictionary) -> void:
	var who : String = str(multiplayer.get_remote_sender_id())
	var player: Player = MultiplayerManager.get_player_from_name(who)
	for i in data:
		match i:
			DataTypes.Position:
				player.global_position = data[DataTypes.Position]
			DataTypes.Rotation:
				player.rotation = data[DataTypes.Rotation]
			DataTypes.FlashLightState:
				pass

func _player_joined(playerId : int) -> void:
	if multiplayer.is_server(): return
	
	var data : Dictionary 
	
	data[DataTypes.Position] = localPlayer.global_position
	data[DataTypes.Rotation] = localPlayer.rotation
	#data[DataTypes.FlashLightState].append(localPlayer.flashLight.visible)
	
	_update_data.rpc_id(playerId, data)
