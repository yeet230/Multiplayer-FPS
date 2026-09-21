extends Node


var ping: String = "Ping: N/A"

enum PLAYERSTATE {
	DEAD,
	DOWNED,
	ALIVE,
	DEBUG,
	SPECTATE
}

var weaponDictionary : Dictionary[WeaponData.WeaponID, WeaponData] = {
	WeaponData.WeaponID.USG_57 : preload("res://Weapon System/WeaponData/Pistol/5.7USG.tres"),
	WeaponData.WeaponID.DEAGLE : preload("res://Weapon System/WeaponData/Pistol/Deagle.tres"),
	WeaponData.WeaponID.MP5 : preload("res://Weapon System/WeaponData/SMG/MP5.tres"),
	WeaponData.WeaponID.P90 : preload("res://Weapon System/WeaponData/SMG/P90.tres"),
	WeaponData.WeaponID.AK12 : preload("res://Weapon System/WeaponData/Rifle/AK12.tres"),
	WeaponData.WeaponID.FRF2 : preload("res://Weapon System/WeaponData/Rifle/FR_F2.tres"),
	#WeaponData.WeaponID.M1014 : preload("res://Weapon System/WeaponData/Shotgun/M1014.tres"),
	#WeaponData.WeaponID.SUPER_SHORTY : preload("res://Weapon System/WeaponData/Shotgun/Super_Shorty.tres"),
	WeaponData.WeaponID.KITCHEN_KNIFE : preload("res://Weapon System/WeaponData/Melee/Knife.tres"),
	WeaponData.WeaponID.MACHETE : preload("res://Weapon System/WeaponData/Melee/Machete.tres"),
	WeaponData.WeaponID.PEA_SHOOTER : preload("res://Weapon System/WeaponData/Debug/Pea_Shooter.tres"),
	WeaponData.WeaponID.GODS_GUM : preload("res://Weapon System/WeaponData/Debug/Gods_Gum.tres"),
	WeaponData.WeaponID.THE_JACOB_SPECIAL : preload("res://Weapon System/WeaponData/Debug/TheJacobSpecial.tres"),
	WeaponData.WeaponID.G502_MOUSE : preload("res://Weapon System/WeaponData/Other/G502.tres")
	
}

var weaponList: Array[WeaponData.WeaponID] = [
	WeaponData.WeaponID.USG_57,
	WeaponData.WeaponID.MP5,
	WeaponData.WeaponID.MACHETE,
	WeaponData.WeaponID.THE_JACOB_SPECIAL,
	#WeaponData.WeaponID.M1014,
	WeaponData.WeaponID.P90,
	WeaponData.WeaponID.DEAGLE,
	WeaponData.WeaponID.AK12,
	WeaponData.WeaponID.G502_MOUSE,
	WeaponData.WeaponID.FRF2,
	WeaponData.WeaponID.THE_7900_GRE,
	#WeaponData.WeaponID.SUPER_SHORTY,
	WeaponData.WeaponID.KITCHEN_KNIFE,
]

var bannedList: Array[String] = [
	"Server",
	"System",
	"Admin",
	"theo"
]

var weaponLevel: int = 0
var clientPlayer : Player 

var spawnLocations: Array[Vector3] = [
	Vector3(-15, 0, -3),
	Vector3(-32, 0, 4),
	Vector3(24.5, 5, 10),
	Vector3(24.5, 0, -4.5),
	Vector3(31.5, 0, 2.5),
	Vector3(96, 0, 9.5),
	Vector3(-96, 0, 9.5),
	Vector3(5.5, 0, 1),
	Vector3(-5.5, 0, 1),
	Vector3(16.5, 0, 9.5),
	Vector3(5.5, 5, 2.5),
	Vector3(4.5, 5, -17.5),
	Vector3(60, 0, -17),
	Vector3(31.5, 0, -6),
	Vector3(24.5, 5, 39.5),
	Vector3(38, 0, -17),
]

var mouseSens: float = 0.002
var playerStartingHealth: float = 100.0

var debug: bool = false

var username: String = ""
