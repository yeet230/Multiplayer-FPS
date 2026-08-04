class_name MP_5 extends WeaponBase

func _init() -> void:
	weaponName = "MP5"
	
	fireMode = shootingTypes.AUTOMATIC_FIRE
	magSize = 30
	bulletDamage = 12.5
	reloadTime = 2.9
	mesh = null
	spread = 97.5
	fireRate = 60.0 / 800.0
