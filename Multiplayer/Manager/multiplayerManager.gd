extends Node

signal serverCreated
signal ChatRecived(text : String)

# Replace this with your own server port number between 1024 and 65535.
const SERVER_PORT = 3928

const bulletDecalScene = preload("uid://6gbftdo4m7nj")

var players:= {}

#region Server/Client Setup
func start_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	serverCreated.emit()

func join_server(ip : String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, SERVER_PORT)
	multiplayer.multiplayer_peer = peer
#endregion

func _random_username_gen() -> String:
	var randGenUsername: String = ""
	var possibleNames: Array[String] = [
		"The Great Tweaker",
		"Homeless Banana Lover",
		"Homeless Tweaker",
		"Gay Theo",
		"Homeless Schitzo",
		"Nameless Tweaker"
	]
	randGenUsername = possibleNames[randi_range(0, possibleNames.size() - 1)]
	return randGenUsername

func _profanity_check_string(text : String) -> String:
	var string = text
	
	if text.containsn("nigga") or text.containsn("nigger"):
		string = "I am a rascist"
	return string

func get_player_from_name(nameID : String) -> Player:
	var playerArray = get_tree().get_nodes_in_group("Players")
	for plyer in playerArray:
		if plyer.name == nameID:
			return plyer
	return null

func verify_damage(dmg : float, weapon : String) -> float:
	return dmg if Globals.get_weapon_damage(weapon) == dmg else -10.0

func _handle_command(text : String, senderID : int) -> void:
	var splitCommand: PackedStringArray = text.split(" ")
	if text.contains("-/debug"):
		if splitCommand.size() < 3:
			push_error("Invalid Command: expected -/debug = <val = !current> ; But got ", text)
			return
			
		var newVal: bool = Globals.string_to_bool(splitCommand[2])
		update_debug_mode.rpc_id(int(senderID), newVal)
	
	elif text.contains("-/tp"):
		if splitCommand.size() < 4:
			push_error("Invalid Command: extpected -/tp <x> <y> <z> ; But got", text)
			return
		
		var x: float = float(splitCommand[1])
		var y: float = float(splitCommand[2])
		var z: float = float(splitCommand[3])
		var newPos: Vector3 = Vector3(x, y, z)
		teleport_player.rpc_id(int(senderID), newPos, senderID)
		

func _check_username_for_duplicates(username : String) -> String:
	print(players.size())
	return "    "
	

#region Server Side Network Functions
@rpc("any_peer", "call_remote", "unreliable_ordered")
func damage_player(nameID : String, dmg : float, weapon : String) -> void:
	if !multiplayer.is_server(): return
	
	var damage: float = verify_damage(dmg, weapon)
	if damage == dmg:
		damage_player_client.rpc_id(int(nameID), damage, nameID)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func register_player(username: String = "",) -> void:
	if !multiplayer.is_server(): return
	
	username = _profanity_check_string(username)
	username = _check_username_for_duplicates(username)
	
	if username.is_empty() or username.begins_with(" "):
		username = _random_username_gen()
		
	var senderID = multiplayer.get_remote_sender_id() 
	if senderID == 0:
		senderID = 1
		
	players[senderID] = {
		"username": username,
	}
	#push_warning(players)

@rpc("any_peer", "call_remote", "reliable")
func server_verify_chat(text : String) -> void:
#endregion
	if !multiplayer.is_server(): return
	var senderID: int = multiplayer.get_remote_sender_id()
	
	
	if text.begins_with("-/"):
		_handle_command(text, senderID)
		return
	
	var chat: String = _profanity_check_string(text)
	var username: String = str(players[senderID]["username"])
	
	_server_send_chat.rpc(username, chat)

#region Client Side Network Functions
@rpc("authority", "call_local", "reliable")
func _server_send_chat(username : String, text : String) -> void:
	var chat: String = str(username, ": ", text)
	ChatRecived.emit(chat)

@rpc("authority", "call_remote", "unreliable_ordered")
func damage_player_client(dmg : float, nameID : String) -> void:
	var plyer: Player = get_player_from_name(nameID)
	plyer.curHealth -= dmg
	

@rpc("any_peer", "call_local", "unreliable_ordered")
func spawn_bullet_decal(pos : Vector3, norm : Vector3) -> void:
	var decal = bulletDecalScene.instantiate() as Node3D
	get_tree().get_first_node_in_group("balls").add_child(decal, true)
	decal.global_position = pos
	decal.rotation = norm

@rpc("authority", "call_local", "unreliable")
func update_debug_mode(newVal : bool) -> void:
	Globals.debug = newVal

@rpc("authority", "call_local", "unreliable")
func teleport_player(newPos : Vector3, playerID : int) -> void:
	var plyer: Player = get_player_from_name(str(playerID))
	plyer.position = newPos
#endregion
