class_name Shotgun extends WeaponBase

func _init() -> void:
	weaponName = "Shotgun"
	
	spread = 85.75
	fireRate = .25
	reloadTime = 1.6
	shootAmount = 8
	bulletDamage = 12.0
	fireMode = shootingTypes.SHOTGUN_FIRE
	magSize = 6
	loadedCount = Globals.ammo.get(weaponName)
