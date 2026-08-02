extends Control

@onready var usernameInput: LineEdit = %UsernameInput
@onready var ipInput: LineEdit = %IPInput
@onready var playMenu: TabContainer = $PlayTabContainer
@onready var mainMenu: VBoxContainer = $MainMenu
@onready var settingsMenu: TabContainer = $SettingsTabContainer

func _ready() -> void:
	_auto_mode_set()
	print(IP.get_local_addresses())

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

func _input(event: InputEvent) -> void:
	if event.is_action("ballTest"):
		print("Returning to MainMenu")
		mainMenu.show()
		playMenu.hide()
		settingsMenu.hide()

func _auto_mode_set() -> void:
	if OS.has_feature("dedicated_server"):
		print("Starting Dedicated Server Automaticllyaurhsafif")
		_on_host_pressed.call_deferred()
	#else:
		#_on_join_pressed.call_deferred()

func _on_host_pressed() -> void:
	MultiplayerManager.start_server()
	_destroy()

func _on_join_pressed() -> void:
	var ip = ipInput.text
	_set_player_username()
	
	MultiplayerManager.join_server(ip)
	_destroy()

func _destroy() -> void:
	self.queue_free()

func _set_player_username() -> void:
	var username: String 
	if OS.has_feature("debug"):
		username = _get_username()
	username = usernameInput.text
	Globals.username = username

func _on_play_pressed() -> void:
	playMenu.show()
	playMenu.grab_focus()
	mainMenu.hide()

func _on_settings_pressed() -> void:
	settingsMenu.show()
	mainMenu.hide()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		3:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
