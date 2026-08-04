class_name FR_F2 extends WeaponBase

func _init() -> void:
	weaponName = "FR F2"
	
	fireMode = shootingTypes.BURST_FIRE
	spread = 98.0
	magSize = 24
	reloadTime = 3.10
	fireRate = 60.0/980.0
	bulletDamage = 10.0
