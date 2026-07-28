extends Node

enum PLAYERSTATE {
	DEAD,
	DOWNED,
	ALIVE,
	DEBUG,
	SPECTATE
}

var weaponDictionary : Dictionary[String, Dictionary] = {
	"Pistol" : {
		"ammo" : 21,
		"weaponDamage" : 25,
		
	},
	"Submachine" : {
		"ammo" : 31,
		"weaponDamage" : 12.
		
	},
	"Shotgun" : {
		"ammo" : 6,
		"weaponDamage" : 8
		
	},
	"FR F2" : {
		"ammo" : 24,
		"weaponDamage" : 15
		
	},
	"PeaShooter" : {
		"ammo" : 1000,
		"weaponDamage" : 1,
		
	},
	"GodsGum" : {
		"ammo" : 1000,
		"weaponDamage" : 10,
	},
	"Kitchen Knife" : {
		"ammo" : 1,
		"weaponDamage" : 50,
	}
}

var mouseSens: float = 0.002

var debug: bool = true

var username: String = ""

func _ready() -> void:
	if !is_multiplayer_authority():
		
		
		pass

func get_weapon_damage(weaponName : String) -> float:
	return weaponDictionary[weaponName]["weaponDamage"]

func get_weapon_ammo(weaponName : String) -> int:
	return weaponDictionary[weaponName]["ammo"]

func set_weapon_ammo(weaponName : String, newAmmoCount : int) -> void:
	weaponDictionary[weaponName]["ammo"] = newAmmoCount
