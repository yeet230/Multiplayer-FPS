class_name GodsGum extends WeaponBase

func _init() -> void:
	weaponName = "GodsGum"
	
	magSize = 1000
	loadedCount = 2147483648
	reloadTime = 0.00000000000000000001
	bulletDamage = 10
	fireMode = shootingTypes.AUTOMATIC_FIRE
	fireRate = .000000001
	spread = 100
