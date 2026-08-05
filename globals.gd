extends Node
##Weapons in the range [b]0 - 99[/b] are Pistols, [b]100 - 199[/b] are SMG's, [b]200 - 299[/b] are Rifles, [b]300 - 399[/b] are Shotguns, [b]400 - 499[/b] are Melee
enum WeaponID {
	PISTOL = 0, 
	MP5 = 100,
	#P90 = 101,
	#AK12 = 200,
	#FRF2 = 201,
	#M1014 = 300,
	#SUPER_SHORTY = 301,
	#KITCHEN_KNIFE = 400,
	#MACHETE = 401,
	#PEA_SHOOTER = -1,
	#GODS_GUM = -2,
	
}

enum PLAYERSTATE {
	DEAD,
	DOWNED,
	ALIVE,
	DEBUG,
	SPECTATE
}

var weaponDictionary : Dictionary[WeaponID, WeaponData] = {
	WeaponID.PISTOL : preload("res://Weapon System/WeaponData/Pistol/Pistol.tres"),
	WeaponID.MP5 : preload("res://Weapon System/WeaponData/SMG/MP5.tres"),
	#WeaponID.P90 : preload("res://Weapon System/WeaponData/SMG/P90.tres"),
	#WeaponID.AK12 : preload("res://Weapon System/WeaponData/Rifle/AK12.tres"),
	#WeaponID.FRF2 : preload("res://Weapon System/WeaponData/Rifle/FR_F2.tres"),
	#WeaponID.M1014 : preload("res://Weapon System/WeaponData/Shotgun/M1014.tres"),
	#WeaponID.SUPER_SHORTY : preload("res://Weapon System/WeaponData/Shotgun/Super_Shorty.tres"),
	#WeaponID.KITCHEN_KNIFE : preload("res://Weapon System/WeaponData/Melee/Knife.tres"),
	#WeaponID.MACHETE : preload("res://Weapon System/WeaponData/Melee/Machete.tres"),
	#WeaponID.PEA_SHOOTER :preload("res://Weapon System/WeaponData/Debug/Pea_Shooter.tres"),
	#WeaponID.GODS_GUM : preload("res://Weapon System/WeaponData/Debug/Gods_Gum.tres"),
}

var weaponLevel: int = 0
var weaponList: Array[WeaponID] = [
	WeaponID.PISTOL,
	WeaponID.MP5,
	#WeaponID.M1014,
	#WeaponID.P90,
	#WeaponID.AK12,
	#WeaponID.FRF2,
	#WeaponID.SUPER_SHORTY,
	#WeaponID.KITCHEN_KNIFE,
	#WeaponID.MACHETE
]

var mouseSens: float = 0.002
var playerStartingHealth: float = 100.0

var debug: bool = false

var username: String = ""

func string_to_bool(string : String) -> bool:
	return string.strip_edges().to_lower() == "true"

func get_weapon_damage(weaponID : WeaponID) -> float:
	var weaponData: WeaponData = weaponDictionary[weaponID]
	return weaponData.damage

func get_weapon_ammo(weaponID : WeaponID) -> int:
	return weaponDictionary[weaponID]["ammo"]

func get_weapon_script(weaponID : WeaponID) -> GDScript:
	var weaponData: WeaponData = weaponDictionary[weaponID]
	return weaponData.weaponScript

func set_weapon_ammo(weaponID : WeaponID, newAmmoCount : int) -> void:
	weaponDictionary[weaponID]["ammo"] = newAmmoCount

func verify_damage(dmg : float, weaponID : WeaponID) -> float:
	return dmg if Globals.get_weapon_damage(weaponID) == dmg else 0.0

func create_command_starter() -> String:
	var possibleChars: Array[String] = ["-", "/", "*", "_", "+", "#", "!", "%", "c"]
	var returnVal: String
	for i in range(2):
		returnVal += possibleChars.pick_random()
	return returnVal
