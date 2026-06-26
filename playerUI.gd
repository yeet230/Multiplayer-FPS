extends Control

@onready var spdLabel: Label = $RightLabels/Speed
@onready var posLabel: Label = $RightLabels/Position
@onready var dashLabel: Label = $RightLabels/Dash
@onready var healthLabel: Label = $RightLabels/Health
@onready var ammoCountLabel: Label = $RightLabels/Ammo
@onready var idLabel: Label = $Left/ID
@onready var activeWeaponLabel: Label = $Left/ActiveWeapon
@onready var fpsLabel: Label = $Left/FPSLabel

func _ready() -> void:
	if !is_multiplayer_authority(): queue_free()
	visible = is_multiplayer_authority()
	Globals.Position.connect(_update_position)
	Globals.Dash.connect(_update_dash)
	Globals.Speed.connect(_update_speed)
	Globals.Health.connect(_update_health)
	Globals.UpdateAmmo.connect(_update_bullet_count)
	#Globals.UpdateKillCount.connect(_update_)
	Globals.ActiveWeapon.connect(_weapon_changed)
	idLabel.text = str(get_parent().multiplayer.get_unique_id())


func _weapon_changed(newWeapon : String) -> void:
	activeWeaponLabel.text = str("Current Weapon: ", newWeapon)

func _update_dash(dCount : int, dAmount) -> void:
	dashLabel.text = str("Dashes Used: ", dCount, "/", dAmount)

func _update_speed(Spd: float):
	#if !is_multiplayer_authority(): return
	spdLabel.text = str("Speed: ", "%0.2f" % Spd, "m/s")

func _update_position(pos : Vector3):
	posLabel.text = str(
	"x: ", "%0.2f" % pos.x, 
	"  y: ", "%0.2f" % pos.y, 
	"  z: ", "%0.2f" % pos.z )

func _update_bullet_count(loadedCount: int, magSize : int) -> void:
	ammoCountLabel.text = str("Ammo: ", loadedCount, "/", (magSize+1))
	#if loadedCount == 0:
		#noAmmoLabel.visible = true
	#else:
		#noAmmoLabel.visible = false

func _process(_delta: float) -> void:
	fpsLabel.text = str("FPS: ", Engine.get_frames_per_second())
	
func _update_health(health : float, maxHealth : int):
	healthLabel.text = str(health, "/", maxHealth)

#func _update_kill_count(amnt : int) -> void:
	#Globals.killCount += amnt
	#killCountLabel.text = str("Kill Count: ", Globals.killCount)
	#print(Globals.killCount)
