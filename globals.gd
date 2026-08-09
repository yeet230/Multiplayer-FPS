extends Node
##Weapons in the range [b]0 - 99[/b] are Pistols, [b]100 - 199[/b] are SMG's, [b]200 - 299[/b] are Rifles, [b]300 - 399[/b] are Shotguns, [b]400 - 499[/b] are Melee
enum WeaponID {
	USG_57 = 0, 
	MP5 = 100,
	P90 = 101,
	AK12 = 200,
	FRF2 = 201,
	M1014 = 300,
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

var weaponDictionary : Dictionary[WeaponID, WeaponData] = {
	WeaponID.USG_57 : preload("res://Weapon System/WeaponData/Pistol/5.7USG.tres"),
	WeaponID.MP5 : preload("res://Weapon System/WeaponData/SMG/MP5.tres"),
	WeaponID.P90 : preload("res://Weapon System/WeaponData/SMG/P90.tres"),
	WeaponID.AK12 : preload("res://Weapon System/WeaponData/Rifle/AK12.tres"),
	WeaponID.FRF2 : preload("res://Weapon System/WeaponData/Rifle/FR_F2.tres"),
	WeaponID.M1014 : preload("res://Weapon System/WeaponData/Shotgun/M1014.tres"),
	WeaponID.SUPER_SHORTY : preload("res://Weapon System/WeaponData/Shotgun/Super_Shorty.tres"),
	WeaponID.KITCHEN_KNIFE : preload("res://Weapon System/WeaponData/Melee/Knife.tres"),
	WeaponID.MACHETE : preload("res://Weapon System/WeaponData/Melee/Machete.tres"),
	WeaponID.PEA_SHOOTER :preload("res://Weapon System/WeaponData/Debug/Pea_Shooter.tres"),
	WeaponID.GODS_GUM : preload("res://Weapon System/WeaponData/Debug/Gods_Gum.tres"),
}

var weaponList: Array[WeaponID] = [
	WeaponID.USG_57,
	WeaponID.MP5,
	WeaponID.M1014,
	WeaponID.P90,
	WeaponID.AK12,
	WeaponID.FRF2,
	WeaponID.SUPER_SHORTY,
	WeaponID.KITCHEN_KNIFE,
	WeaponID.MACHETE
]

var bannedList: Array[String] = [
	"System",
]

var weaponLevel: int = 0
var clientPlayer : Player 

var spawnLocations: Array[Vector3] = [
	Vector3(0, 0, 9),
	Vector3(23, 0, 9),
	Vector3(-23, 0, 9),
	Vector3(47, 0, 9),
	Vector3(-47, 0, 9),
	Vector3(95, 0, 9),
	Vector3(-95, 0, 9),
	Vector3(5, 0, -10),
	Vector3(-5, 0, -10),
	Vector3(19, 0, -18),
	Vector3(-9, 0, -18),
	Vector3(-24, 0, -9),
	Vector3(-16, 0, 0),
	Vector3(31.5, 0, -6),
]



var mouseSens: float = 0.002
var playerStartingHealth: float = 100.0

var debug: bool = false

var username: String = ""
