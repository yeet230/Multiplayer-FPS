extends Node

signal serverCreated

const bulletDecalScene = preload("uid://6gbftdo4m7nj")

var players:= {}

#region Server/Client Setup
func start_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(1337)
	multiplayer.multiplayer_peer = peer
	serverCreated.emit()

func join_server(ip : String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 1337)
	multiplayer.multiplayer_peer = peer
#endregion

@rpc("any_peer", "call_local")
func spawn_bullet_decal(pos : Vector3, norm : Vector3) -> void:
	var decal = bulletDecalScene.instantiate() as Node3D
	
	get_tree().get_first_node_in_group("balls").add_child(decal, true)
	decal.global_position = pos
	decal.rotation = norm

func random_username_gen() -> String:
	var randGenUsername: String = ""
	var possibleNames: Array[String] = [
		"The Great Apple",
		"Banana Lover",
		"Homeless",
		"Tweaker",
		"Schitzo",
		"Nameless"
	]
	randGenUsername = possibleNames[randi_range(0, possibleNames.size() - 1)]
	return randGenUsername

@rpc("any_peer")
func register_player(_username: String = "") -> void:
	if !multiplayer.is_server(): return
	
	if _username.is_empty():
		_username = random_username_gen()
	var senderID = multiplayer.get_remote_sender_id() 
	if senderID == 0:
		senderID = 1
	
	players[senderID] = {
		"username": _username,
	}
	push_warning(players)

@rpc("any_peer")
func send_chat(text : String) -> void:
	if !multiplayer.is_server(): return
	
	
	
	if text.begins_with("/"):
		print(text)
	else:
		var senderID = multiplayer.get_remote_sender_id()
		print(players[senderID]["username"], ": ", text)
