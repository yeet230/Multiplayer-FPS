class_name Pistol extends WeaponBase

#Change the values created in WeaponBase inside this function
func _init() -> void:
	fireMode = shootingTypes.SEMI_FIRE
	magSize = 20
	loadedCount = Globals.ammo.get("Pistol")
	reloadTime = 2.4
	gunInDictionary = "Pistol"
	meshPositionOffSet = Vector3(0, -.261, -.528)
	meshScale = Vector3(.3, .3, .3)
	meshRotation = 90
	spread = 99
	fireRate = .22
