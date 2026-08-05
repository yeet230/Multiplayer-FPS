class_name WeaponBase extends Node

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

var mesh
var meshPositionOffSet: Vector3
var meshScale: Vector3

var maxRange: float = 100 ##How far the weapon can shoot
var magSize: int ##The amount to add when reloading
var loadedCount: int ##Amount of ammo loaded in the weapon at the moment
var shotsFired: int = 0
var projectilesPerShot: int ##How many bullets should be fired. Used for the shotgun and burst fire modes

var fireRate: float ##The fire rate of the weapon should be from 60/desired RPM
var bulletDamage: float  ##How much damage a bullet should do
var reloadSpeed: float ##How long to delay the the update of how many bullets are loaded
var meshRotation: float = 90.0
var spread: float

func _ready() -> void:
	if !is_multiplayer_authority(): 
		return
	
	_setup()
	
	if mesh != null:
		mesh.position = meshPositionOffSet
		mesh.scale = meshScale
		mesh.rotation_degrees.y = meshRotation
		add_child(mesh)

func fire(manager : WeaponManager):
	canFire = false
	if loadedCount > 0:
		manager.perform_hitscan(maxRange, weaponId, bulletDamage, spread)
	
	await get_tree().create_timer(fireRate).timeout
	canFire = true
	
	match fireMode:
		shootingTypes.AUTOMATIC_FIRE:
			if isTriggerHeld:
				_auto_fire(manager)
		shootingTypes.BURST_FIRE:
			_burst_fire(manager)

func _process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	mag_update()
	
	#if is_queued_for_deletion(): #is redundant as weapon ammo is set in mag update
		#Globals.set_weapon_ammo(weaponID, loadedCount)


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
	if Input.is_action_just_pressed("reload") and !isReloading:
		_reload()
	
	loadedCount = clamp(loadedCount, 0, magSize + 1)
	
	Globals.set_weapon_ammo(weaponId, loadedCount)

func trigger_pressed(manager : WeaponManager) -> void:
	isTriggerHeld = true
	shotsFired = 0
	if canFire and !isReloading:
		match fireMode: #Switch statment for different fireing modes
			shootingTypes.SEMI_FIRE:
				_try_semi_fire(manager)
			shootingTypes.AUTOMATIC_FIRE:
				_auto_fire(manager)
			shootingTypes.BURST_FIRE:
				_burst_fire(manager)
			shootingTypes.SHOTGUN_FIRE:
				_shotgun_fire(manager)

func trigger_released() -> void:
	isTriggerHeld = false

func _try_semi_fire(manager) -> void:
	fire(manager)
	loadedCount -= 1

func _auto_fire(manager : WeaponManager) -> void:
	if (isTriggerHeld or canFire) and not isReloading: #Exit/Return if either trigger or canShoot are false
		fire(manager)
		loadedCount -= 1

func _burst_fire(manager : WeaponManager) -> void:
	if shotsFired < projectilesPerShot:
		fire(manager)
		shotsFired += 1
		loadedCount -= 1

func _shotgun_fire(manager : WeaponManager) -> void:
	while shotsFired < projectilesPerShot:
		fire(manager)
		shotsFired += 1
	loadedCount -= 1

func _setup() -> void:
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
	
	print(fireMode, bulletDamage, loadedCount)
	
	
	
	
	
	
