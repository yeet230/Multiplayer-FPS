extends Node

signal serverCreated
const BALL = preload("uid://b0s1t7orvau07")

var players:= {}

func start_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(1337)
	multiplayer.multiplayer_peer = peer
	serverCreated.emit()

func join_server(ip : String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 1337)
	multiplayer.multiplayer_peer = peer

@rpc("any_peer")
func spawn_ball(position : Vector3) -> void:
	if !multiplayer.is_server(): return
	
	var balls = BALL.instantiate() as RigidBody3D
	get_tree().get_first_node_in_group("balls").add_child(balls, true)
	balls.global_position = Vector3.ZERO
	balls.global_position.y += 10
	print("After add:", balls.get_path())


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
	print(players)

@rpc("any_peer")
func send_chat(text : String) -> void:
	if !multiplayer.is_server(): return
	
	var senderID = multiplayer.get_remote_sender_id()
	print(players[senderID]["username"], ":    ",text)
