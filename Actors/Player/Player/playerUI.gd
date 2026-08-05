class_name PlayerUI extends Control

var fade_tween: Tween
var chatInputVisible: bool

@onready var spdLabel: Label = $Labels/RightLabels/Speed
@onready var posLabel: Label = $Labels/RightLabels/Position
@onready var dashLabel: Label = $Labels/RightLabels/Dash
@onready var healthLabel: Label = $Labels/RightLabels/Health
@onready var ammoCountLabel: Label = $Labels/RightLabels/Ammo
@onready var idLabel: Label = $Labels/Left/ID
@onready var activeWeaponLabel: Label = $Labels/Left/ActiveWeapon
@onready var fpsLabel: Label = $Labels/Left/FPSLabel
@onready var player: = get_parent().get_parent()
@onready var noAmmoLabel: Label = $Labels/NoAmmo
@onready var chatInput: LineEdit = $ChatConsole/ChatInput
@onready var chatOutput: RichTextLabel = $ChatConsole/ChatOutput

#region Built in function Overides
func _ready() -> void:
	if !is_multiplayer_authority(): return
	idLabel.text = str(get_parent().multiplayer.get_unique_id())
	
	MultiplayerManager.ChatRecived.connect(_update_chatlog)
	
	fade_out()
	chatInputVisible = chatInput.visible

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle chat") and !chatInput.is_editing():
		_handle_chat_toggle()
		chatInput.grab_focus()
	elif event.is_action_pressed("ui_accept"):
		_handle_chat()


func _process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	fpsLabel.text = str("FPS: ", Engine.get_frames_per_second())

#endregion

#region Custom Local functions 
func _update_weapon_equipped() -> void:
	var weaponName: String = player.weaponManager.equippedWeapon.weaponName
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
	var loadedCount = player.weaponManager.equippedWeapon.loadedCount
	var magSize = player.weaponManager.equippedWeapon.magSize
	
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

#endregion

func tick() -> void:
	_update_health()
	_update_dash()
	_update_position()
	_update_speed()
	if player.weaponManager.equippedWeapon:
		_update_weapon_equipped()
		_update_bullet_count()

func fade_in(time : float = 0.2) -> void:
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(chatOutput, "modulate:a", 1, time)

func fade_out() -> void:
	if chatInput.visible: return
	
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(chatOutput, "modulate:a", 0, 5)
