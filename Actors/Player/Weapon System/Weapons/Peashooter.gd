class_name PeaShooter extends WeaponBase

func _init() -> void:
	weaponName = "PeaShooter"
	
	bulletDamage = .1
	fireMode = shootingTypes.SEMI_FIRE
	magSize = 10000
