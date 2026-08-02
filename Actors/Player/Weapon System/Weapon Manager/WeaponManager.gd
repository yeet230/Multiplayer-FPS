class_name WeaponManager extends Node3D

enum weaponOptions {
	Pistol,
	Submachine,
	Shotgun,
	fr_f2,
	PeaShooter,
	GodsGum,
	Knife,
}

var weaponUpgrades: Array = [
	Pistol,
	Submachine,
	FR_F2,
	Shotgun,
	Knife
]

var weapons : Array = [
	Pistol,
	Submachine,
	Shotgun,
	FR_F2,
	PeaShooter,
	GodsGum,
	Knife,
]

var weaponAmount = weapons.size() #2 if !Globals.debug else 

var equippedWeapon : WeaponBase
var activeWeapon: int = 0

var playerCamera : Camera3D = get_parent()
@onready var bulletHitScanRayCast: RayCast3D = $BulletHitScanRay

func _ready() -> void:
	if !is_multiplayer_authority(): return
	_equip_new_weapon(weaponUpgrades[activeWeapon].new())

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	if event.is_action_pressed("cycle weapon"):
		cycle_weapon()

func _equip_new_weapon(newWeapon : WeaponBase) -> void:
	if equippedWeapon and equippedWeapon != newWeapon:
		equippedWeapon.queue_free()
	
	equippedWeapon = newWeapon
	equippedWeapon.set_multiplayer_authority(get_multiplayer_authority())
	add_child(equippedWeapon)

func player_trigger_pressed() -> void:
	if equippedWeapon:
		equippedWeapon.trigger_pressed(self)

func player_trigger_released() -> void:
	if equippedWeapon:
		equippedWeapon.trigger_released()

func perform_hitscan(distance : int, weapon : String, dmg : float = 1, spread : float = 100) -> Node3D:
	var accuracy: float = (100.0 - spread)
	var xAccuracy: float = randf_range(-accuracy, accuracy)
	var yAccuracy: float = randf_range(-accuracy, accuracy)
	var targetPos: Vector3 = Vector3(xAccuracy, yAccuracy, -distance)
	
	bulletHitScanRayCast.target_position = targetPos
	bulletHitScanRayCast.force_raycast_update()
	var collidingInstance = bulletHitScanRayCast.get_collider()
	
	if collidingInstance is Player:
		MultiplayerManager.damage_player.rpc_id(1, collidingInstance.name, dmg, weapon)
		return collidingInstance #Retrun Colliding instance
		
	_spawn_bullet_decal()
	return null #Return since bullet did not hit any preffered Instances (they have function "take_damage()")

func _spawn_bullet_decal() -> void:
	var pos: Vector3 = bulletHitScanRayCast.get_collision_point()
	var norm: Vector3 = bulletHitScanRayCast.get_collision_normal()
	MultiplayerManager.spawn_bullet_decal.rpc(pos, norm)
	

func cycle_weapon() -> void:
	if Globals.debug:
		print("hello")
		
		activeWeapon = (activeWeapon + 1) % weaponAmount
		_equip_new_weapon(weapons[activeWeapon].new())
