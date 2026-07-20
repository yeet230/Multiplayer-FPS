extends Node

signal Position(pos : Vector3)
signal Dash(usedCount : int, maxCount : int)
signal Speed(spd) ##Shows the speed of the player in m/s as a number
signal Health(health : float, MaxHealth : int) ##Used to show the players health as [b](curHealth / MaxHealth)[/b]
signal UpdateAmmo(loadedCount: int, magSize : int)
signal UpdateKillCount(amount : int)
signal ActiveWeapon(newWeapon : String)

enum PLAYERSTATE {
	DEAD,
	DOWNED,
	ALIVE,
	DEBUG,
	SPECTATE
}

var ammo : Dictionary[String, int] = {
	"Pistol" : 21,
	"Submachine" : 31,
	"Shotgun" : 6,
	"FR F2" : 24,
	"PeaShooter" : 1001,
	"GodsGum" : 10000
}

var mouseSens: float = 0.002

var debug: bool = true

var username: String = ""

func _ready() -> void:
	if !is_multiplayer_authority():
		Position.emit(Vector3.ZERO)
		Dash.emit(0, 0)
		Speed.emit(0.0)
		Health.emit(0)
		UpdateAmmo.emit(0, 0)
		UpdateKillCount.emit(0)
		ActiveWeapon.emit("")
