class_name LatencyTracker extends Node

signal ping_updated(current_ping_ms: int)

@export var ping_interval: float = 1.0
@export var pingLabel: Label
var current_ping: float = 0
var ping_timer: Timer

func _ready() -> void:
	if not multiplayer.is_server():
		ping_timer = Timer.new()
		ping_timer.wait_time = ping_interval
		ping_timer.autostart = true
		ping_timer.timeout.connect(_send_ping)
		add_child(ping_timer)

func _send_ping() -> void:
	var sentTime = Time.get_ticks_msec() / 1000.0
	server_echo_ping.rpc_id(1, sentTime)

@rpc("any_peer", "call_remote", "unreliable")
func server_echo_ping(client_time: int) -> void:
	if not multiplayer.is_server(): return
	var sender_id = multiplayer.get_remote_sender_id()
	# Instantly bounce timestamp back to sender
	client_receive_ping.rpc_id(sender_id, client_time)

@rpc("authority", "call_remote", "unreliable")
func client_receive_ping(original_timestamp: int) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	current_ping = now - original_timestamp
	ping_updated.emit(current_ping)
	print("[TELEMETRY] Current Ping: %.3f ms" % current_ping)
