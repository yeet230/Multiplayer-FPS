extends Node
##Weapons in the range [b]0 - 99[/b] are Pistols, [b]100 - 199[/b] are SMG's, [b]200 - 299[/b] are Rifles, [b]300 - 399[/b] are Shotguns, [b]400 - 499[/b] are Melee
enum WeaponID {
	PISTOL = 0, ##Done
	MP5 = 100,
	P90 = 101,
	AK12 = 200,
	FRF2 = 201,
	SHOTGUN = 300,
	SUPER_SHORTY = 301,
	KITCHEN_KNIFE = 400,
	MACHETE = 401,
	PEA_SHOOTER = -1,
	GODS_GUM = -2,
	
}

enum PLAYERSTATE {
	DEAD,
	DOWNED,
	ALIVE,
	DEBUG,
	SPECTATE
}

var weaponDictionary : Dictionary[WeaponID, Dictionary] = {
	WeaponID.PISTOL : {
		"ammo" : 21,
		"weaponDamage" : 25,
		"weaponScript" : Pistol
	},
	WeaponID.MP5 : {
		"ammo" : 31,
		"weaponDamage" : 12.5,
		"weaponScript" : MP_5,
	},
	WeaponID.P90 : {
		"ammo" : 51,
		"weaponDamage" : 0,
		"weaponScript" : P_90,
	},
	WeaponID.AK12 : {
		"ammo" : 1,
		"weaponDamage" : 40,
		"weaponScript" : AK_12,
	},
	WeaponID.FRF2 : {
		"ammo" : 24,
		"weaponDamage" : 15,
		"weaponScript" : FR_F2
	},
	WeaponID.SHOTGUN : {
		"ammo" : 6,
		"weaponDamage" : 8,
		"weaponScript" : Shotgun
	},
	WeaponID.SUPER_SHORTY : {
		"ammo" : 3,
		"weaponDamage" : 16,
		"weaponScript" : Super_Shorty
	},
	WeaponID.KITCHEN_KNIFE : {
		"ammo" : 1,
		"weaponDamage" : 50,
		"weaponScript" : Knife
	},
	WeaponID.MACHETE : {
		"ammo" : 1,
		"weaponDamage" : 100,
		"weaponScript" : Machete
	},
	WeaponID.PEA_SHOOTER : {
		"ammo" : 1000,
		"weaponDamage" : 1,
		"weaponScript" : PeaShooter
	},
	WeaponID.GODS_GUM : {
		"ammo" : 1000,
		"weaponDamage" : 10,
		"weaponScript" : GodsGum
	},
}

var weaponLevel: int = 0
var weaponOrder: Array[WeaponID] = [
	WeaponID.PISTOL,
	WeaponID.SHOTGUN,
	WeaponID.MP5,
	WeaponID.P90,
	WeaponID.AK12,
	WeaponID.FRF2,
	WeaponID.SUPER_SHORTY,
	WeaponID.KITCHEN_KNIFE,
	WeaponID.MACHETE
]

var mouseSens: float = 0.002
var playerStartingHealth: float = 100.0

var debug: bool = false

var username: String = ""

func string_to_bool(string : String) -> bool:
	return string.strip_edges().to_lower() == "true"

func get_weapon_damage(weaponID : WeaponID) -> float:
	return weaponDictionary[weaponID]["weaponDamage"]

func get_weapon_ammo(weaponID : WeaponID) -> int:
	return weaponDictionary[weaponID]["ammo"]

func get_weapon_script(weaponID : WeaponID) -> WeaponBase:
	return weaponDictionary[weaponID]["Script"]

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
