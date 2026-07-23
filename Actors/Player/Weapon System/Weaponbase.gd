class_name WeaponBase extends Node

##The style of shooting the gun will have
enum shootingTypes {
	SEMI_FIRE,
	BURST_FIRE,
	AUTOMATIC_FIRE,
	SHOTGUN_FIRE
}

var triggerHeld: bool = false
var canShoot: bool= true
var isReloading: bool = false

var weaponName: String
var mesh
var meshPositionOffSet: Vector3 = Vector3(.462, -.307, -.458)
var meshScale: Vector3 = Vector3(.5, .5, .5)

var fireMode: shootingTypes ##Choose one of the types in "shootingTypes"

var distance: int = 100 ##How far the weapon can shoot
var magSize: int = 69 ##The amount to add when reloading/its mag size
var loadedCount: int = magSize + 1 ##the amount that is loaded into the weapon
var firedShots: int = 0
var shootAmount: int = 3

var fireRate: float = 60.0 / 900.0 ##The fire rate of the gun base of 60/900
var bulletDamage: float = 25.0  ##How much damage a bullet should do
var reloadTime: float = 2.0 ##How long to delay the the update of how many bullets are loaded
var meshRotation: float = 90.0
var spread: float = 95.0

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
	canShoot = false
	if loadedCount > 0:
		manager.perform_hitscan(distance, weaponName, bulletDamage, spread)
	
	await get_tree().create_timer(fireRate).timeout
	canShoot = true
	
	match fireMode:
		shootingTypes.AUTOMATIC_FIRE:
			if triggerHeld:
				_auto_fire(manager)
		shootingTypes.BURST_FIRE:
			_burst_fire(manager)

func _process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	
	mag_update()
	if is_queued_for_deletion():
		Globals.ammo[weaponName] = loadedCount

func _reload() -> void:
	isReloading = true
	await get_tree().create_timer(reloadTime).timeout
	isReloading = false
	
	match fireMode:
		shootingTypes.SHOTGUN_FIRE:
			loadedCount += 1
			if loadedCount < magSize + 1:
				_reload()
		_:
			loadedCount = magSize if (loadedCount <= 0) else (loadedCount + magSize)

func mag_update():
	if Input.is_action_just_pressed("reload") and !isReloading:
		_reload()
	
	loadedCount = clamp(loadedCount, 0, magSize + 1)
	Globals.UpdateAmmo.emit(loadedCount, magSize)
	
	Globals.weaponDictionary[weaponName]["ammo"] = loadedCount

func trigger_pressed(manager : WeaponManager) -> void:
	triggerHeld = true
	firedShots = 0
	if canShoot and !isReloading:
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
	triggerHeld = false

func _try_semi_fire(manager) -> void:
	fire(manager)
	loadedCount -= 1

func _auto_fire(manager : WeaponManager) -> void:
	if (triggerHeld or canShoot) and not isReloading: #Exit/Return if either trigger or canShoot are false
		fire(manager)
		loadedCount -= 1

func _burst_fire(manager : WeaponManager) -> void:
	if firedShots < shootAmount:
		fire(manager)
		firedShots += 1
		loadedCount -= 1

func _shotgun_fire(manager : WeaponManager) -> void:
	while firedShots < shootAmount:
		fire(manager)
		firedShots += 1
	loadedCount -= 1

func _setup() -> void:
	loadedCount = Globals.weaponDictionary[weaponName]["ammo"]
	bulletDamage = Globals.weaponDictionary[weaponName]["weaponDamage"]
	
	Globals.ActiveWeapon.emit(weaponName)
	Globals.UpdateAmmo.emit(loadedCount, magSize)
	
