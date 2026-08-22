class_name PlayerUI extends Control

enum LabelType {
	POSITION,
	KILLS,
	DEATHS,
}

var fadeTween: Tween
var chatInputVisible: bool

var toggleChat: bool = false
var isEnterPressed: bool = false
var isBackPressed: bool = false

@onready var player: = get_parent().get_parent()

@onready var spdLabel: Label = $DebugElements/Labels/RightLabels/Speed
@onready var posLabel: Label = $DebugElements/Labels/RightLabels/Position
@onready var dashLabel: Label = $DebugElements/Labels/RightLabels/Dash
@onready var healthLabel: Label = $DebugElements/Labels/RightLabels/Health
@onready var ammoCountLabel: Label = $DebugElements/Labels/RightLabels/Ammo
@onready var idLabel: Label = $DebugElements/Labels/Left/ID
@onready var activeWeaponLabel: Label = $DebugElements/Labels/Left/ActiveWeapon
@onready var fpsLabel: Label = $DebugElements/Labels/Left/FPSLabel
@onready var noAmmoLabel: Label = $DebugElements/Labels/NoAmmo


@onready var chatInput: LineEdit = $ChatElements/ChatConsole/ChatInput
@onready var chatOutput: RichTextLabel = $ChatElements/ChatConsole/ChatOutput

#@onready var GridSorted: GridContainer = $ScoreBoardBG/CentredBG/GridContainer
@onready var usernameLabelParent: VBoxContainer = $ScoreBoardBG/GridContainer/UsernameVBox
@onready var killsLabelParent: VBoxContainer = $ScoreBoardBG/GridContainer/KillsVBox
@onready var deathsLabelParent: VBoxContainer = $ScoreBoardBG/GridContainer/DeathsVBox

@onready var usernameVBox: VBoxContainer = $ScoreBoardBG/GridContainer/UsernameVBox
@onready var killsVBox: VBoxContainer = $ScoreBoardBG/GridContainer/KillsVBox
@onready var deathsVBox: VBoxContainer = $ScoreBoardBG/GridContainer/DeathsVBox


func tick() -> void:
	if isBackPressed and chatInput.visible:
		_handle_chat_toggle()
	elif isEnterPressed:
		_handle_chat()
	elif toggleChat and !chatInput.is_editing():
		_handle_chat_toggle()
	
	_update_hud()

func _update_hud() -> void:
	_update_health()
	_update_dash()
	_update_position()
	_update_speed()
	if player.weaponManager.weaponData: ##Checks to make sure that the data exist's before reading from it. will crash otherwise
		_update_weapon_equipped()
		_update_bullet_count()


#region Built in function Overides
func _ready() -> void:
	if !is_multiplayer_authority(): return
	idLabel.text = str(get_parent().multiplayer.get_unique_id())
	
	MultiplayerManager.ChatRecived.connect(_update_chatlog)
	MultiplayerManager.SharedDataUpdated.connect(_update_leaderboard)
	
	fade_out()
	chatInputVisible = chatInput.visible

func _gui(event: InputEvent) -> void:
	if event:
		get_viewport().set_input_as_handled()
	print(event)

func _process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	fpsLabel.text = str("FPS: ", Engine.get_frames_per_second())

#endregion


#region Label Update Functions 
func _update_weapon_equipped() -> void:
	var weaponName: String = player.weaponManager.weaponName
	
	activeWeaponLabel.text = str("Weapon: ", weaponName)

func _update_dash() -> void:
	var dCount: int = player.movementController.usedDashCount
	var dAmount: int = player.movementController.maxDashCount
	
	dashLabel.text = str("Dashes Used: ", dCount, "/", dAmount)

func _update_speed() -> void:
	var spd: float = player.velocity.length()
	
	spdLabel.text = str("Speed: ", "%0.2f" % spd, "m/s")

func _update_position() -> void:
	var pos : Vector3 = player.position
	
	posLabel.text = str(
	"x: ", "%0.2f" % pos.x, 
	"  y: ", "%0.2f" % pos.y, 
	"  z: ", "%0.2f" % pos.z )

func _update_bullet_count() -> void:
	var loadedCount = player.weaponManager.loadedCount
	var magSize = player.weaponManager.magSize
	
	loadedCount = clampi(loadedCount, 0, magSize + 1)
	
	ammoCountLabel.text = str("Ammo: ", loadedCount, "/", magSize)
	noAmmoLabel.visible = false if loadedCount > 0 else true

func _update_health() -> void:
	var playerHealth: float = player.curHealth
	var playerMaxHealth: int = player.maxHealth
	healthLabel.text = str(playerHealth, "/", playerMaxHealth)

#func _update_kill_count(amnt : int) -> void:
	#Globals.killCount += amnt
	#killCountLabel.text = str("Kill Count: ", Globals.killCount)


#endregion


#region Chat Functioons

func _update_chatlog(chat : String) -> void:
	fade_in()
	chatOutput.text = str(chatOutput.text + chat + "\n")
	await get_tree().create_timer(10).timeout
	fade_out()

func _handle_chat() -> void:
	var chat: String = chatInput.text
	if !chat.is_empty():
		MultiplayerManager.server_verify_chat.rpc_id(1, chat)
		chatInput.clear()

func _handle_chat_toggle() -> void:
	chatInput.visible = !chatInputVisible
	chatInputVisible = chatInput.visible
	
	if chatInputVisible:
		fade_in(0)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		fade_out()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_viewport().set_input_as_handled()
	chatInput.grab_focus()

func fade_in(time : float = 0.2) -> void:
	if fadeTween: fadeTween.kill()
	
	fadeTween = create_tween()
	fadeTween.tween_property(chatOutput, "modulate:a", 1, time)

func fade_out() -> void:
	if chatInput.visible: return
	if fadeTween: fadeTween.kill()
	
	fadeTween = create_tween()
	fadeTween.tween_property(chatOutput, "modulate:a", 0, 5)

#endregion


#region Scoreboard Functions

func _update_leaderboard(newData : Dictionary) -> void:
	_handle_table_update(newData)

func _handle_table_update(newData: Dictionary) -> void:
	# Clear existing dynamically-created labels
	for child in usernameVBox.get_children():
		child.queue_free()
	
	for child in killsVBox.get_children():
		child.queue_free()
	
	for child in deathsVBox.get_children():
		child.queue_free()
	
	#recreate the Guide Labels
	_recreate_table_names()
	
	
	# Create scoreboard entries
	for playerId in newData:
		var playerData: Dictionary = newData[playerId]
		
		var usernamesLabel: Label = Label.new()
		usernamesLabel.text = str(playerData[MultiplayerManager.PlayerData.USERNAME])
		usernameVBox.add_child(usernamesLabel)
		
		var killsLabel: Label = Label.new()
		killsLabel.text = str(playerData[MultiplayerManager.PlayerData.KILLS])
		killsVBox.add_child(killsLabel)
		
		var deathsLabel: Label = Label.new()
		deathsLabel.text = str(playerData[MultiplayerManager.PlayerData.DEATHS])
		deathsVBox.add_child(deathsLabel)

func _recreate_table_names() -> void:
	var killLabel: Label = Label.new()
	var deathLabel: Label = Label.new()
	var usernameLabel: Label = Label.new()
	
	usernameLabel.text = "Username"
	killLabel.text = "Kills"
	deathLabel.text = "Deaths"
	
	usernameVBox.add_child(usernameLabel)
	killsVBox.add_child(killLabel)
	deathsVBox.add_child(deathLabel)

#endregion
