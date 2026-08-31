class_name WeaponManager extends Node3D
##Handles the firing of weapon's within the game has multiple firing methods and requires a custom Resource to work correctly


@export var mainCamera: Camera3D 

enum ShootingType {
	SEMI_FIRE,
	BURST_FIRE,
	AUTOMATIC_FIRE,
	SHOTGUN_FIRE,
	CHARGED_SHOT,
	MELEE,
}

enum ReloadStyle {
	MAG,
	SLUG,
	N_A,
}

var weaponData: WeaponData

var fireMode: ShootingType
var reloadType: ReloadStyle
var weaponId: Globals.WeaponID
var weaponName: String

var maxRange: float = 100.0
var magSize: int = 0
var loadedCount: int = 0
var projectilesPerShot: int = 1

var fireRate: float = 0.1
var bulletDamage: float = 10.0
var reloadSpeed: float = 1.0
var spread: float = 0.0

var canFire := true
var isReloading := false
var isTriggerHeld := false
var burstShotsRemaining := 0

var isReloadPressed := false
var isShootPressed := false
var isShootReleased := false

@onready var bulletHitScanRayCast: RayCast3D = $BulletHitScanRay
@onready var reloadTimer: Timer = $ReloadTimer
@onready var shootTimer: Timer = $ShootTimer



func _ready() -> void:
	reloadTimer.timeout.connect(_on_reload_timer_timeout)
	shootTimer.timeout.connect(_on_shoot_timer_timeout)


func _equip_new_weapon(newWeapon: Globals.WeaponID) -> void:
	weaponData = Tools.get_weapon_data(newWeapon)
	load_weapon_data()


func load_weapon_data() -> void:
	bulletDamage = weaponData.damage
	loadedCount = weaponData.ammo
	magSize = weaponData.magSize
	weaponName = weaponData.weaponName
	weaponId = weaponData.WeaponID

	fireMode = weaponData.fireMode
	reloadType = weaponData.reloadType
	maxRange = weaponData.shootDistance
	reloadSpeed = weaponData.reloadSpeed
	fireRate = weaponData.fireRate
	spread = weaponData.bulletSpread
	projectilesPerShot = weaponData.projectilesPerShot


func tick() -> void:
	if isShootPressed:
		_player_trigger_pressed()
	elif isShootReleased:
		_player_trigger_released()
	elif isReloadPressed:
		start_reload()

#region Input

func _player_trigger_pressed() -> void:
	isTriggerHeld = true
	
	# Interrupt shell-by-shell reload if we have at least one shell loaded.
	if isReloading and loadedCount > 0:
		cancel_reload()
	
	try_fire()

func _player_trigger_released() -> void:
	isTriggerHeld = false

#endregion 

func try_fire() -> void:
	if !canFire: return
	if isReloading: return
	if loadedCount <= 0: return
	
	match fireMode:
		ShootingType.SEMI_FIRE:
			fire_single_shot()
		ShootingType.AUTOMATIC_FIRE:
			fire_single_shot()
		ShootingType.BURST_FIRE:
			burstShotsRemaining = projectilesPerShot
			fire_burst_shot()
		
		ShootingType.SHOTGUN_FIRE:
			fire_shotgun()


func fire_single_shot() -> void:
	loadedCount -= 1
	perform_hitscan()
	begin_fire_cooldown()


func fire_shotgun() -> void:
	loadedCount -= 1

	for i in range(projectilesPerShot):
		perform_hitscan()

	begin_fire_cooldown()


func fire_burst_shot() -> void:
	if burstShotsRemaining <= 0: return
	if loadedCount <= 0: return
	
	loadedCount -= 1
	burstShotsRemaining -= 1
	
	perform_hitscan()
	begin_fire_cooldown()


func begin_fire_cooldown() -> void:
	canFire = false
	shootTimer.start(fireRate)


func _on_shoot_timer_timeout() -> void:
	canFire = true
	
	match fireMode:
		ShootingType.AUTOMATIC_FIRE:
			if isTriggerHeld:
				try_fire()
			
		ShootingType.BURST_FIRE:
			if burstShotsRemaining > 0:
				fire_burst_shot()

#region Reload Handling
func start_reload() -> void:
	if isReloading: return
	if loadedCount >= magSize: return
	
	isReloading = true
	reloadTimer.start(reloadSpeed)

func cancel_reload() -> void:
	isReloading = false
	reloadTimer.stop()

func _on_reload_timer_timeout() -> void:
	match reloadType:
		ReloadStyle.MAG:
			loadedCount += magSize
			isReloading = false
			
		ReloadStyle.SLUG:
			loadedCount += 1
			
			if loadedCount < magSize:
				reloadTimer.start(reloadSpeed)
			else:
				isReloading = false
		
		ReloadStyle.N_A:
			isReloading = false
			
	loadedCount = clamp(loadedCount, 0, magSize + 1)
#endregion

func perform_hitscan() -> float:
	var accuracy: float = (100.0 - spread)
	var xAccuracy: float = randf_range(-accuracy, accuracy)
	var yAccuracy: float = randf_range(-accuracy, accuracy)
	var targetPos: Vector3 = Vector3(xAccuracy, yAccuracy, -maxRange)
	
	bulletHitScanRayCast.target_position = targetPos
	bulletHitScanRayCast.force_raycast_update()
	
	var collider: Node3D = bulletHitScanRayCast.get_collider()
	
	#print("Client From: ", global_position)
	#print("Client To: ", targetPos)
	#print("Client HitPoint: ", bulletHitScanRayCast.get_collision_point())
	
	if collider is Player:
		MultiplayerManager.server_handle_hit.rpc_id(1, weaponId, collider.name)
		return 1
	
	if bulletHitScanRayCast.is_colliding():
		_spawn_bullet_decal()
	
	return 0

func _spawn_bullet_decal() -> void:
	MultiplayerManager.spawn_bullet_decal.rpc(
		bulletHitScanRayCast.get_collision_point(),
		bulletHitScanRayCast.get_collision_normal()
	)

func _handle_recoil() -> void:
	pass

func _add_recoil() -> void:
	pass

func _handle_recoil_reset() -> void:
	pass
