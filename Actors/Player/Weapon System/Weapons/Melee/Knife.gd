class_name Knife extends WeaponBase

func _init() -> void:
	weaponName = "Kitchen Knife"
	
	reloadMode = reloadStyle.Mag
	reloadTime = 1.0
	fireMode = shootingTypes.AUTOMATIC_FIRE
	fireRate = 0.01
	magSize = 10000000000000
	spread = 100.0
	distance = 2
	
	
