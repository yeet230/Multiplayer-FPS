extends Node

func random_player_spawn() -> Vector3:
	var randomLocation = randi_range(0, Globals.spawnLocations.size() - 1)
	return Globals.spawnLocations[randomLocation]

func string_to_bool(string : String) -> bool:
	return string.strip_edges().to_lower() == "true"

func get_weapon_damage(weaponID : Globals.WeaponID) -> float:
	var weaponData: WeaponData = Globals.weaponDictionary[weaponID]
	return weaponData.damage

func get_weapon_ammo(weaponID : Globals.WeaponID) -> int:
	var weaponData: WeaponData = Globals.weaponDictionary[weaponID]
	return weaponData.loadedCount

func get_weapon_data(weaponID : Globals.WeaponID) -> WeaponData:
	var weaponData: WeaponData = Globals.weaponDictionary[weaponID]
	return weaponData

func set_weapon_ammo(weaponID : Globals.WeaponID, newAmmoCount : int) -> void:
	Globals.weaponDictionary[weaponID].loadedCount = newAmmoCount

func verify_damage(dmg : float, weaponID : Globals.WeaponID) -> float:
	return dmg if get_weapon_damage(weaponID) == dmg else 0.0

func create_command_starter() -> String:
	var possibleChars: Array[String] = ["-", "/", "*", "_", "+", "#", "!", "%", "c"]
	var returnVal: String = ""
	for i in range(2):
		returnVal += possibleChars.pick_random()
	return returnVal
