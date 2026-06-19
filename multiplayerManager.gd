extends Node

signal serverCreated

func start_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(1337)
	multiplayer.multiplayer_peer = peer
	serverCreated.emit()
	_upnp_setup(1337)

func join_server(ip : String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 1337)
	multiplayer.multiplayer_peer = peer

# Emitted when UPnP port mapping setup is completed (regardless of success or failure).
signal upnp_completed(error)

# Replace this with your own server port number between 1024 and 65535.
const SERVER_PORT = 3928
var thread = null

func _upnp_setup(server_port):
	# UPNP queries take some time.
	var upnp = UPNP.new()
	var err = upnp.discover()

	if err != OK:
		push_error(str(err))
		upnp_completed.emit(err)
		return

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
		upnp_completed.emit(OK)

func _ready():
	thread = Thread.new()
	thread.start(_upnp_setup.bind(SERVER_PORT))

func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	thread.wait_to_finish()
