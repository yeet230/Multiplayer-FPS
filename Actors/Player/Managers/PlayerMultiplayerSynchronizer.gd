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
	if !is_multiplayer_authority(): return

	multiplayer.peer_connected.connect(_player_joined)
	
	var curHealth: float = localPlayer.curHealth
	var username: String = Globals.username
	
	var data: Dictionary = {
		MultiplayerManager.PlayerData.HEALTH : curHealth,
		MultiplayerManager.PlayerData.USERNAME : username,
		#MultiplayerManager.PlayerData.
		#MultiplayerManager.PlayerData.
		#MultiplayerManager.PlayerData.
	}
	
	if !multiplayer.is_server():
		MultiplayerManager.server_register_player.rpc_id(1, curHealth, username)
	
	
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
	
	if prevLightState != localPlayer.flashLightOn:
		data[DataTypes.FlashLightState] = localPlayer.flashLightOn
		prevLightState = localPlayer.flashLightOn
	
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
				player.flashLight.visible = data[DataTypes.FlashLightState]

func _player_joined(playerId : int) -> void:
	if multiplayer.is_server(): return
	
	var data : Dictionary 
	
	data[DataTypes.Position] = localPlayer.global_position
	data[DataTypes.Rotation] = localPlayer.rotation
	data[DataTypes.FlashLightState] =localPlayer.flashLightOn 
	
	_update_data.rpc_id(playerId, data)
