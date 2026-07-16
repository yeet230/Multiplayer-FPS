class_name Shotgun extends WeaponBase

func _init() -> void:
	spread = 85.75
	fireRate = .25
	reloadTime = 1.6
	gunInDictionary = "Shotgun"
	shootAmount = 8
	bulletDamage = 12.0
	fireMode = shootingTypes.SHOTGUN_FIRE
	magSize = 6
	loadedCount = Globals.ammo.get(gunInDictionary)
