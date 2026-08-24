extends Node

func random_player_spawn() -> Vector3:
	var randomLocation = randi_range(0, Globals.spawnLocations.size() - 1)
	return Globals.spawnLocations[randomLocation]

func string_to_bool(string : String) -> bool:
	return string.strip_edges().to_lower() == "true"

#region WeaponData related
func get_weapon_damage(weaponId : Globals.WeaponID) -> float:
	var weaponData: WeaponData = Globals.weaponDictionary[weaponId]
	return weaponData.damage

func set_weapon_ammo(weaponID : Globals.WeaponID, newAmmoCount : int) -> void:
	Globals.weaponDictionary[weaponID].loadedCount = newAmmoCount

func get_weapon_ammo(weaponId : Globals.WeaponID) -> int:
	var weaponData: WeaponData = Globals.weaponDictionary[weaponId]
	return weaponData.loadedCount

func get_weapon_data(weaponId : Globals.WeaponID) -> WeaponData:
	var weaponData: WeaponData = Globals.weaponDictionary[weaponId]
	return weaponData
#endregion

func get_weapon_level(who: int) -> int:
	var level: int = MultiplayerManager.PlayerData.WEAPON_LEVEL
	var weaponLevel: int = MultiplayerManager.serverOnlyPlayerData[who][level]
	return weaponLevel

func get_weapon(who : int) -> Globals.WeaponID:
	var weaponLevel: int = get_weapon_level(who)
	var weaponId: Globals.WeaponID = Globals.weaponList[weaponLevel]
	return weaponId

func create_command_starter() -> String:
	var possibleChars: Array[String] = ["-", "/", "*", "_", "+", "#", "!", "%", "c"]
	var returnVal: String = ""
	for i in range(2):
		returnVal += possibleChars.pick_random()
	return returnVal

func get_weapon_fireRate(weaponId : Globals.WeaponID) -> float:
	var weaponData: WeaponData = Globals.weaponDictionary[weaponId]
	return weaponData.fireRate

func get_value(value : String) -> String:
	var arguments: Dictionary = {}
	for argument in OS.get_cmdline_args():
		if argument.contains("="):
			var keyValue: Array = argument.split("=")
			arguments[keyValue[0].trim_prefix("--")] = keyValue[1]
		else:
			arguments[argument.trim_prefix("--")] = ""
	var u: String = ""
	if value in arguments:
		u = arguments.username
	push_warning(u)
	DisplayServer.window_set_title(u)
	#print("variable arguments printed: ", arguments, "			OS.get_args: ", OS.get_cmdline_args())
	return u
