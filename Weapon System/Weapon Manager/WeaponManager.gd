class_name WeaponManager extends Node3D

var equippedWeapon : Globals.WeaponID

##The style of shooting the gun will have
enum shootingTypes {
	SEMI_FIRE,
	BURST_FIRE,
	AUTOMATIC_FIRE,
	SHOTGUN_FIRE,
	CHARGED_SHOT,
	Meele
}

enum ReloadStyle {
	Mag,
	Slug,
	N_A,
}

var weaponData: WeaponData

var fireMode: shootingTypes ##Choose one of the types in "shootingTypes"
var reloadType: ReloadStyle
var weaponId: Globals.WeaponID

var weaponName: String

var canFire: bool = true
var isBarrelLoaded: bool = true ##Future rework needed for this to be used
var isReloading: bool = false
var isTriggerHeld: bool = false

var maxRange: float = 100 ##How far the weapon can shoot
var magSize: int ##The amount to add when reloading
var loadedCount: int = 123013813 ##Amount of ammo loaded in the weapon at the moment
var shotsFired: int = 0
var projectilesPerShot: int ##How many bullets should be fired. Used for the shotgun and burst fire modes

var fireRate: float ##The fire rate of the weapon should be from 60/desired RPM
var bulletDamage: float  ##How much damage a bullet should do
var reloadSpeed: float ##How long to delay the the update of how many bullets are loaded
var spread: float

##controls var
var isReloadPressed: bool = false
var isShootPressed: bool = false
var isShootReleased: bool = false

var playerCamera : Camera3D = get_parent()
@onready var bulletHitScanRayCast: RayCast3D = $BulletHitScanRay

func _equip_new_weapon(newWeapon : Globals.WeaponID) -> void:
	weaponData = Tools.get_weapon_data(newWeapon)
	print("New weapon Aquired or something")
	load_weapon_data()
	

func _reload() -> void:
	isReloading = true
	await get_tree().create_timer(reloadSpeed).timeout
	isReloading = false
	
	match reloadType:
		ReloadStyle.Slug:
			loadedCount += 1
			if loadedCount < magSize + 1:
				_reload()
		_:
			loadedCount = magSize if (loadedCount <= 0) else (loadedCount + magSize)

func mag_update():
	if isReloadPressed and !isReloading:
		_reload()
	
	loadedCount = clamp(loadedCount, 0, magSize + 1)

func _player_trigger_pressed() -> void:
	isTriggerHeld = true
	shotsFired = 0
	if canFire and (!isReloading and reloadType != ReloadStyle.Slug):
		match fireMode: #Switch statment for different fireing modes
			shootingTypes.SEMI_FIRE:
				_try_semi_fire()
			shootingTypes.AUTOMATIC_FIRE:
				_auto_fire()
			shootingTypes.BURST_FIRE:
				_burst_fire()
			shootingTypes.SHOTGUN_FIRE:
				isReloading = false
				_shotgun_fire()

func _player_trigger_released() -> void:
	isTriggerHeld = false

func perform_hitscan() -> Node3D:
	var accuracy: float = (100.0 - spread)
	var xAccuracy: float = randf_range(-accuracy, accuracy)
	var yAccuracy: float = randf_range(-accuracy, accuracy)
	var targetPos: Vector3 = Vector3(xAccuracy, yAccuracy, -maxRange)
	
	bulletHitScanRayCast.target_position = targetPos
	bulletHitScanRayCast.force_raycast_update()
	var collidingInstance = bulletHitScanRayCast.get_collider()
	
	if collidingInstance is Player:
		MultiplayerManager.server_damage_player.rpc_id(1, collidingInstance.name, bulletDamage, weaponId)
		return collidingInstance #Retrun Colliding instance
		
	_spawn_bullet_decal()
	return null #Return since bullet did not hit any preffered Instances (they have function "take_damage()")

func _spawn_bullet_decal() -> void:
	var pos: Vector3 = bulletHitScanRayCast.get_collision_point()
	var norm: Vector3 = bulletHitScanRayCast.get_collision_normal()
	MultiplayerManager.spawn_bullet_decal.rpc(pos, norm)

func tick() -> void:
	if isShootPressed:
		_player_trigger_pressed()
	elif isShootReleased:
		_player_trigger_released()
	
	mag_update()


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


func fire() -> void:
	canFire = false
	if loadedCount > 0:
		perform_hitscan()
	
	await get_tree().create_timer(fireRate).timeout
	canFire = true
	
	match fireMode:
		shootingTypes.AUTOMATIC_FIRE:
			if isTriggerHeld:
				_auto_fire()
		shootingTypes.BURST_FIRE:
			_burst_fire()

func _try_semi_fire() -> void:
	fire()
	loadedCount -= 1

func _auto_fire() -> void:
	if (isTriggerHeld or canFire) and not isReloading: #Exit/Return if either trigger or canShoot are false
		fire()
		loadedCount -= 1

func _burst_fire() -> void:
	if shotsFired < projectilesPerShot:
		fire()
		shotsFired += 1
		loadedCount -= 1

func _shotgun_fire() -> void:
	while shotsFired < projectilesPerShot:
		fire()
		shotsFired += 1
	loadedCount -= 1
