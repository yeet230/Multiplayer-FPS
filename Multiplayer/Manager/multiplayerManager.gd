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
	SCORE,
	ASSISTS,
	ID,
	LIFE_ID,
	SHADING_MODE,
	
}

var usernameMaxLength: int = 16

var weaponsCount: int
var commandStarter: String ##A Randomly generated string that will be outputted by the server during debugging to allow for quick Actions

# peer_id -> player data
var serverOnlyPlayerData: Dictionary[int, Dictionary] = {}
var sharedPlayerData: Dictionary[int, Dictionary] = {
} 
##Data that will be broadcasted to all types of peers such as killcount, deaths and username
##Currently in debug Process
var usedUsernames: Array[String] = [ 
	"nigger",
	"nigga",
	" ",
	
]


func _ready() -> void:
	if !multiplayer.is_server(): return
	
	weaponsCount = Globals.weaponList.size() - 1
	multiplayer.peer_disconnected.connect(_player_disconnect)
	#multiplayer.peer_connected.connect(_handle_player_joining)
	


#region Server/Client Setup

func _handle_player_joining(peerID : int) -> void:
	_update_sharedPlayerData.rpc_id(peerID, sharedPlayerData)

func start_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(SERVER_PORT)
	
	if err != OK:
		Globals.throw_error(Enum.ERRORS.ERR_FAILED_TO_CREATE_SERVER, "%s" % err)
		#push_error("Failed to create server: %s" % err)
		return
	
	multiplayer.multiplayer_peer = peer
	commandStarter = Tools.create_command_starter()
	
	serverCreated.emit()
	
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
		PlayerData.WARNINGS : 0,
	}
	
	sharedPlayerData[who] = {
		PlayerData.USERNAME : username,
		PlayerData.KILLS : 0,
		PlayerData.DEATHS : 0,
		PlayerData.ASSISTS : 0,
		PlayerData.SCORE : 0,
	}

func _update_player_kills(who : int) -> void:
	sharedPlayerData[who][PlayerData.KILLS] += 1

func _update_player_deaths(who : int) -> void:
	sharedPlayerData[who][PlayerData.DEATHS] += 1

##Randomly generates a username from predefined arrays
func _random_username_gen() -> String:
	var nameStarter: Array[String] = [
		"The Great ",
		"Schitzo ",
		"Schitzophrenic ",
		"SCP-",
		"Sweet and Sour ",
		"Meowing ",
	]
	
	var nameEnds: Array[String] = [
		"Tweaker",
		"Schitzo",
		"Schitzophrenic",
		"Barber",
		"Calculator",
		"Calendar",
		"Mister Maker",
	]
	
	var genUsername: String = nameStarter.pick_random() + nameEnds.pick_random()
	
	return genUsername

##Work in progress: Is meant to check for when a username is a duplicate and then change it until it is not.
func _check_username_for_duplicates(_username: String) -> String:
	var uniqueUsername: String = _username
	print("checking usernames for duplicates")
	for i in usedUsernames:
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
@rpc("authority", "call_remote", "reliable")
func game_over(winningPlayerData : Dictionary) -> void:
	var winningPlayerId: int =  winningPlayerData[PlayerData.ID]
	var won: bool = winningPlayerId == multiplayer.get_unique_id()
	var winningUsername = winningPlayerData[PlayerData.USERNAME]
	
	Globals.clientPlayer.ui.handle_game_over(won, winningUsername)

func server_upgrade_weapon(playerId: int) -> void:
	print("Upgrading Player weapon: ", playerId)
	if !serverOnlyPlayerData.has(playerId):
		push_error("Player does not exist: ", playerId)
		return
	
	if Tools.get_weapon_level(playerId) >= weaponsCount:
		print("Last Weapon Reached by: ", playerId)
		var winningPlayerData: Dictionary = {
			PlayerData.USERNAME : serverOnlyPlayerData[playerId][PlayerData.USERNAME],
			PlayerData.ID : playerId,
		}
		
		game_over.rpc(winningPlayerData)
		
		return
	
	serverOnlyPlayerData[playerId][PlayerData.WEAPON_LEVEL] += 1
	var newWeaponID: Enum.WeaponID = Tools.get_weapon(playerId)
	#_apply_settings_to_player.rpc_id(playerId, playerId, newWeaponID)
	give_weapon.rpc_id(playerId, newWeaponID)


func server_downgrade_weapon(playerId: int) -> void:
	if !serverOnlyPlayerData.has(playerId):
		return
	
	if Tools.get_weapon_level(playerId) <= 0:
		return
	
	serverOnlyPlayerData[playerId][PlayerData.WEAPON_LEVEL] -= 1
	
	var newWeaponID: Enum.WeaponID = Tools.get_weapon(playerId)
	give_weapon.rpc_id(playerId, newWeaponID)


func _handle_player_death(who : int, where : Vector3) -> void:
	if !multiplayer.is_server(): return
	var newHealth: float = Globals.playerStartingHealth
	
	
	_update_player_deaths(who)
	server_downgrade_weapon(who)
	set_player_health(who, newHealth)
	set_player_canShoot(who, true)
	
	
	server_push_death.rpc_id(who, newHealth, where)


func _handle_player_kill(who : int) -> void:
	if !multiplayer.is_server(): return
	
	var curHealth: float = get_player_health(who)
	var newHealth: float = curHealth + 25
	newHealth = clamp(newHealth, 0, 100)
	
	_update_player_kills(who)
	server_upgrade_weapon(who)
	set_player_health(who, newHealth)
	set_player_canShoot(who, true)
	
	server_push_kill.rpc_id(who, newHealth)

#endregion

#region Commands

func _handle_command(text: String, senderID: int) -> void:
	if !Globals.debug: return
	
	print("Command Found")
	var splitCommand: Array[String] = text.split(" ")
	
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
		var newWeaponLevel: int = Globals.weaponList.find(newWeapon)
		
		give_weapon.rpc_id(senderID, newWeapon)
		serverOnlyPlayerData[senderID][PlayerData.WEAPON_LEVEL] = newWeaponLevel
		
		
#endregion


#RPC Functions

#region Server Side Network Functions

func _handle_server_fire(who : int) -> Dictionary:
	var player: Player = get_player_from_name(str(who))
	var results: Dictionary = player.playerNetworkHandler.server_check_hit()
	
	return results 
	

## Client -> Server:
##is called when the player locally hits another player it will confirm the hit, apply damage, call other funtions if it is a kill
@rpc("any_peer", "call_remote", "unreliable_ordered")
func server_verify_hit() -> void:
	if !multiplayer.is_server(): return
	
	print("I have been called")
	
	var senderID: int = multiplayer.get_remote_sender_id()
	if !Batman.get_player_canShoot(senderID): 
		print("Player can not shoot yet: ", Batman.get_player_canShoot(senderID))
		return
	
	var weapon: Enum.WeaponID = Tools.get_weapon(senderID)
	var hitScanResults: Dictionary = _handle_server_fire(senderID)
	if hitScanResults.is_empty(): 
		print("Noone is being hit?")
		return
	
	var shotObject: Node = hitScanResults["collider"]
	var damagedPlayer: Player
	
	if shotObject is Player:
		damagedPlayer = shotObject
		print("Player Found")
	else:
		var shotPos: Vector3 = hitScanResults["position"]
		var shotNorm: Vector3 = hitScanResults["normal"]
		spawn_bullet_decal.rpc(shotPos, shotNorm)
		print("No player found spawnig bullet decal")
		return
	
	var damagedPlayerId: int = int(damagedPlayer.name)
	var verifiedDamage: float = Tools.get_weapon_damage(weapon)
	var waitTime: float = Tools.get_weapon_fireRate(weapon)
	var curPlayerHealth: float = get_player_health(damagedPlayerId)
	var newHealth: float
	
	set_player_canShoot(senderID, false)
	
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
	
	var senderID: int = multiplayer.get_remote_sender_id()
	var usernameLength: int = username.length()
	
	
	
	username = Batman.profanity_check_string(username)
	username.strip_edges()
	username = username.substr(0, min(usernameLength, usernameMaxLength))
	
	if username.is_empty() or username.begins_with(" "):
		username = _random_username_gen()
	
	username = _check_username_for_duplicates(username)
	
	_create_player_data(senderID, username)
	
	var playerWeaponlevel: int = Tools.get_weapon_level(senderID)
	var newWeaponID: Enum.WeaponID = Globals.weaponList[playerWeaponlevel]
	
	give_weapon.rpc_id(senderID, newWeaponID)
	_update_sharedPlayerData.rpc(sharedPlayerData)
	
	if Batman.check_player_health(playerHealth):
		print("Player health is not valid")
		multiplayer.multiplayer_peer.disconnect_peer(senderID)
		return
	
	print("Registered player ", senderID, " as ", username, " Sent sharedPlayerData: ", sharedPlayerData)


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

func _player_disconnect(id : int) -> void:
	if !multiplayer.is_server(): return
	#var
	#
	#for user in serverOnlyPlayerData:
		#if int(user) != id:
	print("Attempting to remove Player ", id)
	var disconnectedUsername: String = Tools.get_username(id)
	
	usedUsernames.erase(disconnectedUsername)
	sharedPlayerData.erase(id)
	serverOnlyPlayerData.erase(id)
	
	_update_sharedPlayerData.rpc(sharedPlayerData)
	print("Player disconnected succsefully")

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
	var damagedPlayer: Player = Globals.clientPlayer
	
	damagedPlayer.curHealth = newHealth


# Server -> Target Client
@rpc("authority", "call_remote", "reliable")
func update_debug_mode(newVal: bool) -> void:
	Globals.debug = newVal


# Server -> Client
@rpc("authority", "call_remote", "reliable")
func teleport_player(newPos: Vector3) -> void:
	var player: Player = Globals.clientPlayer
	player.position = newPos


# Server -> Target Client
@rpc("authority", "call_remote", "reliable")
func give_weapon(what: Enum.WeaponID) -> void:
	var player: Player = Globals.clientPlayer
	player.weaponManager._equip_new_weapon(what)


# Server -> Clients
@rpc("authority", "call_local", "reliable")
func _update_sharedPlayerData(newData : Variant) -> void:
	if multiplayer.is_server(): return
	
	sharedPlayerData = newData
	SharedDataUpdated.emit(sharedPlayerData)


# Client -> Clients
@rpc("authority", "call_local", "unreliable_ordered")
func spawn_bullet_decal(pos: Vector3, norm: Vector3) -> void:
	if multiplayer.is_server(): return
	
	var decal: Node3D = bulletDecalScene.instantiate() as Node3D
	#print("BulletDecal spawned ", multiplayer.get_unique_id())
	var parent: Node3D = get_tree().get_first_node_in_group("Decals")
	if parent == null: return
	
	parent.add_child(decal, true)
	
	decal.global_position = pos
	decal.rotation = norm

#endregion
