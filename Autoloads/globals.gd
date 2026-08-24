extends Node
##Weapons in the range [b]0 - 99[/b] are Pistols, [b]100 - 199[/b] are SMG's, [b]200 - 299[/b] are Rifles, [b]300 - 399[/b] are Shotguns, [b]400 - 499[/b] are Melee
enum WeaponID {
	USG_57 = 0,
	DEAGLE = 1, 
	MP5 = 100,
	P90 = 101,
	AK12 = 200,
	FRF2 = 201, ##(Server will only accept single fire at the moment)
	#M1014 = 300, ##Shotguns are temporarily unavaliable due to reworking of weapon system
	#SUPER_SHORTY = 301,
	KITCHEN_KNIFE = 400,
	MACHETE = 401,
	PEA_SHOOTER = -1,
	GODS_GUM = -2,
	THE_JACOB_SPECIAL = -3,
	G502_MOUSE = -100,
	THE_7900_GRE = -101
	
	
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
	WeaponID.DEAGLE : preload("res://Weapon System/WeaponData/Pistol/Deagle.tres"),
	WeaponID.MP5 : preload("res://Weapon System/WeaponData/SMG/MP5.tres"),
	WeaponID.P90 : preload("res://Weapon System/WeaponData/SMG/P90.tres"),
	WeaponID.AK12 : preload("res://Weapon System/WeaponData/Rifle/AK12.tres"),
	WeaponID.FRF2 : preload("res://Weapon System/WeaponData/Rifle/FR_F2.tres"),
	#WeaponID.M1014 : preload("res://Weapon System/WeaponData/Shotgun/M1014.tres"),
	#WeaponID.SUPER_SHORTY : preload("res://Weapon System/WeaponData/Shotgun/Super_Shorty.tres"),
	WeaponID.KITCHEN_KNIFE : preload("res://Weapon System/WeaponData/Melee/Knife.tres"),
	WeaponID.MACHETE : preload("res://Weapon System/WeaponData/Melee/Machete.tres"),
	WeaponID.PEA_SHOOTER :preload("res://Weapon System/WeaponData/Debug/Pea_Shooter.tres"),
	WeaponID.GODS_GUM : preload("res://Weapon System/WeaponData/Debug/Gods_Gum.tres"),
	WeaponID.THE_JACOB_SPECIAL : preload("res://Weapon System/WeaponData/Debug/TheJacobSpecial.tres"),
	WeaponID.G502_MOUSE : preload("res://Weapon System/WeaponData/Other/G502.tres")
	
}

var weaponList: Array[WeaponID] = [
	WeaponID.USG_57,
	WeaponID.MP5,
	WeaponID.MACHETE,
	WeaponID.THE_JACOB_SPECIAL,
	#WeaponID.M1014,
	WeaponID.P90,
	WeaponID.DEAGLE,
	WeaponID.AK12,
	WeaponID.G502_MOUSE,
	WeaponID.FRF2,
	WeaponID.THE_7900_GRE,
	#WeaponID.SUPER_SHORTY,
	WeaponID.KITCHEN_KNIFE,
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
