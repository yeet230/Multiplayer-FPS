extends Node

signal serverCreated

func start_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(1337)
	multiplayer.multiplayer_peer = peer
	serverCreated.emit()

func join_server(ip : String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 1337)
	multiplayer.multiplayer_peer = peer
