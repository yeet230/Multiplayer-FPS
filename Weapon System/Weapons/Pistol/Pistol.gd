class_name Pistol extends WeaponBase

#Change the values created in WeaponBase inside this function
func _init() -> void:
	weaponData = preload("res://Weapon System/WeaponData/Pistol/Pistol.tres")
	
	_setup()
