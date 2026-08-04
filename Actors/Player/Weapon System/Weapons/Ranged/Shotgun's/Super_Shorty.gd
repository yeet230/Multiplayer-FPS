class_name Super_Shorty extends WeaponBase

func _init() -> void:
	weaponName = "Super Shorty"
	weaponID = Globals.WeaponID.SUPER_SHORTY
	
	reloadMode = reloadStyle.Slug
	reloadTime = 1.55
	fireRate = 60.0 / 1.0
