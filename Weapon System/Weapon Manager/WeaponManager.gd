class_name WeaponManager extends Node3D

var equippedWeapon : WeaponBase
var activeWeapon: int = Globals.weaponLevel

var playerCamera : Camera3D = get_parent()
@onready var bulletHitScanRayCast: RayCast3D = $BulletHitScanRay

func _ready() -> void:
	if !is_multiplayer_authority(): return
	#MultiplayerManager.give_weapon.rpc_id(1)

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	if event.is_action_pressed("cycle weapon"):
		cycle_weapon()

func _equip_new_weapon(newWeapon : GDScript) -> void:
	if equippedWeapon:
		equippedWeapon.queue_free()
	
	#var newWeapon = Globals.get_weapon_script(newWeaponId)
	
	equippedWeapon = newWeapon.new()
	equippedWeapon.set_multiplayer_authority(get_multiplayer_authority())
	add_child(equippedWeapon)

func _player_trigger_pressed() -> void:
	if equippedWeapon:
		equippedWeapon.trigger_pressed(self)

func _player_trigger_released() -> void:
	if equippedWeapon:
		equippedWeapon.trigger_released()

func perform_hitscan(distance : int, weapon : Globals.WeaponID, dmg : float = 1, spread : float = 100) -> Node3D:
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

func tick() -> void:
	if Input.is_action_just_pressed("player_shoot"):
		_player_trigger_pressed()
	elif Input.is_action_just_released("player_shoot"):
		_player_trigger_released()

func update_weapon_level(levelChange: int) -> void:
	activeWeapon += levelChange
	#_equip_new_weapon(101)

func cycle_weapon() -> void:
	if Globals.debug:
		activeWeapon = (activeWeapon + 1) % 10
		#_equip_new_weapon(101)
