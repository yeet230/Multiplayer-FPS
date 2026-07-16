extends Control

func _ready() -> void:
	_auto_mode_set()

func _get_username() -> String:
	var arguments: Dictionary = {}
	for argument in OS.get_cmdline_args():
		if argument.contains("="):
			var keyValue: Array = argument.split("=")
			arguments[keyValue[0].trim_prefix("--")] = keyValue[1]
		else:
			arguments[argument.trim_prefix("--")] = ""
	var u: String = ""
	if "username" in arguments:
		u = arguments.username
	push_warning(u)
	DisplayServer.window_set_title(u)
	return u


func _auto_mode_set() -> void:
	if OS.has_feature("dedicated_server"):
		print("Starting Dedicated Server Automaticlly")
		_on_host_pressed.call_deferred()
	else:
		_on_join_pressed.call_deferred()

func _on_host_pressed() -> void:
	MultiplayerManager.start_server()
	_destroy()
	

func _on_join_pressed() -> void:
	var ip = %IPTextEdit.text
	_set_player_username()
	
	MultiplayerManager.join_server(ip)
	_destroy()


func _destroy() -> void:
	self.queue_free()

func _set_player_username() -> void:
	var username: String = $TextEdit.text
	if username.is_empty():
		username = _get_username()
	Globals.username = username
	
