extends Node
signal ping_update(ping : String)

var ping: String = "Ping: N/A"

var weaponDictionary : Dictionary = {}

func _ready() -> void:
	weaponDictionary = {
	Enum.WeaponID.USG_57 : preload("res://Weapon System/WeaponData/Pistol/5.7USG.tres"),
	Enum.WeaponID.DEAGLE : preload("res://Weapon System/WeaponData/Pistol/Deagle.tres"),
	Enum.WeaponID.MP5 : preload("res://Weapon System/WeaponData/SMG/MP5.tres"),
	Enum.WeaponID.P90 : preload("res://Weapon System/WeaponData/SMG/P90.tres"),
	Enum.WeaponID.AK12 : preload("res://Weapon System/WeaponData/Rifle/AK12.tres"),
	Enum.WeaponID.FRF2 : preload("res://Weapon System/WeaponData/Rifle/FR_F2.tres"),
	Enum.WeaponID.M1014 : preload("res://Weapon System/WeaponData/Shotgun/M1014.tres"),
	Enum.WeaponID.SUPER_SHORTY : preload("res://Weapon System/WeaponData/Shotgun/Super_Shorty.tres"),
	Enum.WeaponID.KITCHEN_KNIFE : preload("res://Weapon System/WeaponData/Melee/Knife.tres"),
	Enum.WeaponID.MACHETE : preload("res://Weapon System/WeaponData/Melee/Machete.tres"),
	Enum.WeaponID.PEA_SHOOTER :preload("res://Weapon System/WeaponData/Debug/Pea_Shooter.tres"),
	Enum.WeaponID.GODS_GUM : preload("res://Weapon System/WeaponData/Debug/Gods_Gum.tres"),
	Enum.WeaponID.THE_JACOB_SPECIAL : preload("res://Weapon System/WeaponData/Debug/TheJacobSpecial.tres"),
	Enum.WeaponID.G502_MOUSE : preload("res://Weapon System/WeaponData/Other/G502.tres")
}



var weaponList: Array[Enum.WeaponID] = [
	Enum.WeaponID.USG_57,
	Enum.WeaponID.MP5,
	Enum.WeaponID.MACHETE,
	Enum.WeaponID.THE_JACOB_SPECIAL,
	Enum.WeaponID.M1014,
	Enum.WeaponID.P90,
	Enum.WeaponID.DEAGLE,
	Enum.WeaponID.AK12,
	Enum.WeaponID.G502_MOUSE,
	Enum.WeaponID.FRF2,
	Enum.WeaponID.THE_7900_GRE,
	Enum.WeaponID.SUPER_SHORTY,
	Enum.WeaponID.KITCHEN_KNIFE,
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
