class_name FR_F2 extends WeaponBase

func _init() -> void:
	fireMode = shootingTypes.BURST_FIRE
	gunInDictionary = "FR F2"
	spread = 98.0
	magSize = 24
	loadedCount = Globals.ammo.get(gunInDictionary)
	reloadTime = 3.10
	fireRate = 60.0/980.0
