class_name PlayerNetworkHandler extends Node
##Syncs properties required for player functionality aswell as handling as to whether they should be synced eg if they have changed since last frame. 
##It will sync Position, Rotation and Flashlight

enum DataTypes {
	Position,
	Player_Body_Rotation,
	Flashlight_State,
	Player_Head_X_Rotation,
}

@export var localPlayer: Player = get_parent()

var prevPos: Vector3 = Vector3.ZERO
var prevBodyRot: Vector3 = Vector3.ZERO
var prevHeadXRot: float = 0
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
	#var id: String = localPlayer.name
	var data : Dictionary
	
	if prevPos != localPlayer.global_position:
		data[DataTypes.Position] = localPlayer.global_position
		prevPos = localPlayer.global_position
	
	if prevBodyRot != localPlayer.rotation:
		data[DataTypes.Player_Body_Rotation] = localPlayer.rotation
		prevBodyRot = localPlayer.rotation
	
	if prevLightState != localPlayer.flashLightOn:
		data[DataTypes.Flashlight_State] = localPlayer.flashLightOn
		prevLightState = localPlayer.flashLightOn
	
	if prevHeadXRot != localPlayer.visionManager.get_camera().rotation.x:
		data[DataTypes.Player_Head_X_Rotation] = localPlayer.visionManager.get_camera().rotation.x
		prevLightState = localPlayer.visionManager.get_camera().rotation.x
	
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
			DataTypes.Player_Body_Rotation:
				player.rotation = data[DataTypes.Player_Body_Rotation]
			DataTypes.Flashlight_State:
				player.flashLight.visible = data[DataTypes.Flashlight_State]
			DataTypes.Player_Head_X_Rotation:
				player.visionManager.get_camera().rotation.x = data[DataTypes.Player_Head_X_Rotation]

##
func server_check_hit() -> Dictionary:
	var playerId: int = int(localPlayer.name)
	var weapon: int = Tools.get_weapon(playerId)
	var activeCamera: Camera3D = localPlayer.visionManager.get_camera()
	var from: Vector3 = localPlayer.get_camera_position()
	var dist: float = Tools.get_weapon_range(weapon)
	var to: Vector3 = from + (-activeCamera.global_transform.basis.z * dist)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to, 2 | 1)
	var spaceState: PhysicsDirectSpaceState3D = activeCamera.get_world_3d().direct_space_state
	var results: Dictionary = spaceState.intersect_ray(query)
	
	return results


func _player_joined(playerId : int) -> void:
	if multiplayer.is_server(): return
	
	var data : Dictionary 
	
	data[DataTypes.Position] = localPlayer.global_position
	data[DataTypes.Player_Body_Rotation] = localPlayer.rotation
	data[DataTypes.Flashlight_State] = localPlayer.flashLightOn 
	
	_update_data.rpc_id(playerId, data)
