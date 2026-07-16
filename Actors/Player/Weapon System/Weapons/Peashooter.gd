class_name PeaShooter extends WeaponBase

func _init() -> void:
	bulletDamage = .1
	fireMode = shootingTypes.SEMI_FIRE
	magSize = 10000
	loadedCount = Globals.ammo.get("PeaShooter")
