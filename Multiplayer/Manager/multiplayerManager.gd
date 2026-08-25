extends Node

signal serverCreated ##Signal that is emtted when the server succsefully starts
signal ChatRecived(text: String) ##Handlesthe broadcasting of the server verified chats back to the UI
signal SharedDataUpdated(newData : Dictionary) ##Is emmitted fo any script that may need this data

var damageMulti: float = 1.0 ##How much the server should Multiply Damage by

const SERVER_PORT: int = 39285 ##Servers Port
const bulletDecalScene := preload("uid://6gbftdo4m7nj")

##A reference for all types of PlayerData that can exist
enum PlayerData {
	HEALTH,
	USERNAME,
	WEAPON_LEVEL,
	CAN_SHOOT,
	DEATHS,
	KILLS,
	WARNINGS,
}

var weaponsCount: int
var commandStarter: String ##A Randomly generated string that will be outputted by the server during debugging to allow for quick Actions

# peer_id -> player data
var serverOnlyPlayerData: Dictionary[int, Dictionary] = {}
var sharedPlayerData: Dictionary[int, Dictionary] = {} ##Data that will be broadcasted to all types of peers such as killcount, deaths and username
##Currently in debug Process
var usedUsernames: Array[String] = [ 
	"",
	"Tweaker",
]


func _ready() -> void:
	weaponsCount = Globals.weaponList.size() - 1
	multiplayer.peer_connected.connect(_handle_player_joining)


#region Server/Client Setup

func _handle_player_joining(peerID : int) -> void:
	_update_sharedPlayerData.rpc_id(peerID, sharedPlayerData)

func start_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(SERVER_PORT)
	
	if err != OK:
		push_error("Failed to create server: %s" % err)
		return
	
	multiplayer.multiplayer_peer = peer
	commandStarter = Tools.create_command_starter()
	
	serverCreated.emit()
	
	#damageMulti = float(Tools.get_value("damageMulti"))
	#print(damageMulti)
	
	print("Server started on port ", SERVER_PORT)
	print("Command starter: ", commandStarter)

func join_server(ip: String) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, SERVER_PORT)
	
	if err != OK:
		push_error("Failed to connect: %s" % err)
		return
	
	multiplayer.multiplayer_peer = peer

#endregion

#region Utility

##Handles the creation of a new Players data. will add them to serverOnlyPlayerData and sharedPlayerData
func _create_player_data(who : int, username : String) -> void:
	serverOnlyPlayerData[who] = {
		PlayerData.USERNAME : username,
		PlayerData.HEALTH : 100.0,
		PlayerData.WEAPON_LEVEL : 0,
		PlayerData.CAN_SHOOT : true,
		PlayerData.WARNINGS : 0
	}
	
	sharedPlayerData[who] = {
		PlayerData.USERNAME : username,
		PlayerData.KILLS : 0,
		PlayerData.DEATHS : 0,
		
	}

func _update_player_kills(who : int) -> void:
	sharedPlayerData[who][PlayerData.KILLS] += 1

func _update_player_deaths(who : int) -> void:
	sharedPlayerData[who][PlayerData.DEATHS] += 1

##Randomly generates a username from predefined arrays
func _random_username_gen() -> String:
	var nameStarter: Array[String] = [
		"The Great ",
	
	]
	
	var nameEnds: Array[String] = [
		"Tweaker",
		
	]
	
	var genUsername: String = nameStarter.pick_random() + nameEnds.pick_random()
	
	return genUsername

##Work in progress: Is meant to check for when a username is a duplicate and then change it until it is not.
func _check_username_for_duplicates(_username: String) -> String:
	var uniqueUsername: String = _username
	print("checking usernames for duplicates")
	for i in usedUsernames:
		print("here is i:", i)
		while i == uniqueUsername:
			print("username is a duplicate")
			uniqueUsername = _random_username_gen()
			
	usedUsernames.append(uniqueUsername)
	
	return uniqueUsername

func set_player_canShoot(playerId : int, newVal : bool) -> void:
	serverOnlyPlayerData[playerId][PlayerData.CAN_SHOOT] = newVal


func get_player_health(playerId : int) -> float:
	var playerHealth: float = serverOnlyPlayerData[playerId][PlayerData.HEALTH]
	return playerHealth


func set_player_health(who : int, newHealth : float) -> void:
	serverOnlyPlayerData[who][PlayerData.HEALTH] = newHealth


##Use this to get the player object from just their name
func get_player_from_name(nameID: String) -> Player:
	for player in get_tree().get_nodes_in_group("Players"):
		if player.name == nameID:
			return player
	return null

#endregion

#region Server Only Logic

func server_upgrade_weapon(playerId: int) -> void:
	print("Upgrading Player weapon: ", playerId)
	if !serverOnlyPlayerData.has(playerId):
		push_error("Player does not exist: ", playerId)
		return
	
	if Tools.get_weapon_level(playerId) >= weaponsCount:
		print("Last Weapon Reached by: ", playerId)
		return
	
	serverOnlyPlayerData[playerId][PlayerData.WEAPON_LEVEL] += 1
	var newWeaponID: Globals.WeaponID = Tools.get_weapon(playerId)
	#_apply_settings_to_player.rpc_id(playerId, playerId, newWeaponID)
	give_weapon.rpc_id(playerId, newWeaponID)


func server_downgrade_weapon(playerId: int) -> void:
	if !serverOnlyPlayerData.has(playerId):
		return
	
	if Tools.get_weapon_level(playerId) <= 0:
		return
	
	serverOnlyPlayerData[playerId][PlayerData.WEAPON_LEVEL] -= 1
	
	var newWeaponID: Globals.WeaponID = Tools.get_weapon(playerId)
	give_weapon.rpc_id(playerId, newWeaponID)


func _handle_player_death(who : int, where : Vector3) -> void:
	if !multiplayer.is_server(): return
	var newHealth: float = Globals.playerStartingHealth
	
	_update_player_deaths(who)
	server_downgrade_weapon(who)
	set_player_health(who, newHealth)
	
	server_push_death.rpc_id(who, newHealth, where)


func _handle_player_kill(who : int) -> void:
	if !multiplayer.is_server(): return
	
	var curHealth: float = get_player_health(who)
	var newHealth: float = curHealth + 25
	newHealth = clamp(newHealth, 0, 100)
	
	_update_player_kills(who)
	server_upgrade_weapon(who)
	set_player_health(who, newHealth)
	
	server_push_kill.rpc_id(who, newHealth)

#endregion

#region Commands

func _handle_command(text: String, senderID: int) -> void:
	print("Command Found")
	var splitCommand := text.split(" ")
	
	if text.begins_with(commandStarter + "debug"):
		var newVal: bool = !Globals.debug
		if splitCommand.size() > 3:
			push_error("Invalid command: expected ", commandStarter, "debug = <bool>")
			return
		elif splitCommand.size() == 3:
			newVal = Tools.string_to_bool(splitCommand[2])
		
		update_debug_mode.rpc_id(senderID, newVal)
		print("Player: ", senderID, " has Enabled Debug Mode" if newVal else " Has Disabled Debug Mode")
	
	elif text.begins_with(commandStarter + "tp"):
		if splitCommand.size() < 4:
			push_error("Invalid command: expected ", commandStarter, "tp <x> <y> <z>")
			return
	
		var newPos := Vector3(
			float(splitCommand[1]),
			float(splitCommand[2]),
			float(splitCommand[3])
		)
	
		teleport_player.rpc_id(senderID, newPos)
	
	elif text.begins_with(commandStarter + "give"):
		if splitCommand.size() != 2:
			push_error("Invalid command: expected ", commandStarter, "set_weapon <WeaponID>")
			return
		
		var newWeapon: int = int(splitCommand[1])
		print(newWeapon)
		give_weapon.rpc_id(senderID, newWeapon)
		
#endregion


#RPC Functions

#region Server Side Network Functions

func _handle_server_fire(who : int, weapon : Globals.WeaponID) -> Dictionary:
	var player: Player = get_player_from_name(str(who))
	var from: Vector3 = player.get_camera_position()
	var dist: float = Tools.get_weapon_damage(weapon)
	var to: Vector3 = from + (-player.global_transform.basis.z * dist)
	var query: = PhysicsRayQueryParameters3D.create(from, to, 2 | 1)
	var spaceState: = player.get_world_3d().direct_space_state
	var results: Dictionary = spaceState.intersect_ray(query)
	
	print(results, "				", spaceState)
	
	if results.is_empty():
		push_error("Result is Empty (Hit has been denied): ", results)
	
	
	return results 


## Client -> Server:
##is called when the player locally hits another player it will confirm the hit, apply damage, call other funtions if it is a kill
@rpc("any_peer", "call_remote", "unreliable_ordered")
func server_handle_hit(weapon : Globals.WeaponID, damagedPlayer : String) -> void:
	
	if !multiplayer.is_server(): return
	
	var senderID: int = multiplayer.get_remote_sender_id()
	var damagedPlayerId: int = int(damagedPlayer)
	var verifiedDamage: float = Tools.get_weapon_damage(weapon)
	var waitTime: float = Tools.get_weapon_fireRate(weapon)
	var curPlayerHealth: float = get_player_health(damagedPlayerId)
	var newHealth: float
	
	#_handle_server_fire(weapon, senderID)
	
	if !Batman.get_player_canShoot(senderID): return
	set_player_canShoot(senderID, false)
	print("Damage Player >:l")
	
	
	print(serverOnlyPlayerData)
	print("Damage: ", verifiedDamage)
	
	newHealth = curPlayerHealth - (verifiedDamage * damageMulti)
	set_player_health(damagedPlayerId, newHealth)
	
	if newHealth <= 0:
		print("Player: ", damagedPlayerId, " To: ", senderID)
		var newPos: Vector3 = Tools.random_player_spawn()
		_handle_player_kill(senderID)
		_handle_player_death(damagedPlayerId, newPos)
		_update_sharedPlayerData.rpc(sharedPlayerData)
	else:
		update_player_client_health.rpc_id(damagedPlayerId, newHealth)
	
	await get_tree().create_timer(waitTime).timeout
	
	set_player_canShoot(senderID, true)


## Client -> Server:
##Is called when a player joins the server, it handles the creation of relative data, aswell as ensuring the username is valid
@rpc("any_peer", "call_remote", "reliable")
func server_register_player(playerHealth: float, username: String = "") -> void:
	if !multiplayer.is_server(): return
	
	var senderID := multiplayer.get_remote_sender_id()
	
	username = Batman.profanity_check_string(username)
	
	if username.is_empty() or username.begins_with(" "):
		username = _random_username_gen()
	
	username = _check_username_for_duplicates(username)
	
	_create_player_data(senderID, username)
	
	var playerWeaponlevel: int = Tools.get_weapon_level(senderID)
	var newWeaponID: Globals.WeaponID = Globals.weaponList[playerWeaponlevel]
	
	give_weapon.rpc_id(senderID, 0)
	
	print("Registered player ", senderID, " as ", username)


## Client -> Server:
##The server will verify the chat sent. check for profanity, make sure it is a real message, handle the command if it is one
@rpc("any_peer", "call_remote", "reliable")
func server_verify_chat(text: String) -> void:
	if !multiplayer.is_server():
		return
	
	var senderID: int = multiplayer.get_remote_sender_id()
	
	if text.begins_with(commandStarter):
		_handle_command(text, senderID)
		return
	
	var chat: String = Batman.profanity_check_string(text)
	var username: String = str(serverOnlyPlayerData[senderID][PlayerData.USERNAME])
	
	_server_send_chat.rpc(username, chat)

#endregion

#region Client Side Network Functions

# Server -> Clients:
@rpc("authority", "call_remote", "reliable")
func _server_send_chat(username: String, text: String) -> void:
	ChatRecived.emit("%s: %s" % [username, text])


# Server -> Target Client:
@rpc("authority", "call_remote", "unreliable")
func server_push_death(newHealth : float, where : Vector3) -> void:
	teleport_player(where)
	update_player_client_health(newHealth)


# Server -> Target Client
@rpc("authority", "call_remote", "unreliable")
func server_push_kill(newHealth : float) -> void:
	update_player_client_health(newHealth)


# Server -> Target Client
@rpc("authority", "call_remote", "unreliable_ordered")
func update_player_client_health(newHealth: float) -> void:
	var damagedPlayer := Globals.clientPlayer
	
	damagedPlayer.curHealth = newHealth


# Server -> Target Client
@rpc("authority", "call_remote", "reliable")
func update_debug_mode(newVal: bool) -> void:
	Globals.debug = newVal


# Server -> Client
@rpc("authority", "call_remote", "reliable")
func teleport_player(newPos: Vector3) -> void:
	var player := Globals.clientPlayer
	player.position = newPos


# Server -> Target Client
@rpc("authority", "call_remote", "reliable")
func give_weapon(what: Globals.WeaponID) -> void:
	var player: Player = Globals.clientPlayer
	player.weaponManager._equip_new_weapon(what)

# Server -> Clients
@rpc("authority", "call_local", "reliable")
func _update_sharedPlayerData(newData : Variant, key : int = 0) -> void:
	if multiplayer.is_server(): return
	
	sharedPlayerData = newData
	SharedDataUpdated.emit(sharedPlayerData)


# Client -> Clients
@rpc("any_peer", "call_local", "unreliable_ordered")
func spawn_bullet_decal(pos: Vector3, norm: Vector3) -> void:
	if multiplayer.is_server(): return
	
	var decal := bulletDecalScene.instantiate() as Node3D
	print("BulletDecal spawned ", multiplayer.get_unique_id())
	var parent := get_tree().get_first_node_in_group("balls")
	if parent == null:
		return
	
	parent.add_child(decal, true)
	
	decal.global_position = pos
	decal.rotation = norm

#endregion
