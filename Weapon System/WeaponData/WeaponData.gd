class_name WeaponData extends Resource
##Key data used by the Server. 
##Do not change otherwise you 
##will be kicked from the lobby

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

@export_category("Data") 
@export var damage: float
@export var ammo: int
@export var weaponName: String
@export var weaponID: WeaponID

@export_category("Weapon Settings")
@export var fireMode: WeaponManager.ShootingType
@export var reloadType: WeaponManager.ReloadStyle
@export var shootDistance: float
@export var reloadSpeed: float
@export var fireRate: float
@export var bulletSpread: float
@export var projectilesPerShot: int
@export var magSize: int

@export_category("Visual Settings")
##Currently not used
@export var mesh: Mesh 
##Currently not used
@export var meshPosition: Vector3
##Currently not used
@export var meshRotation: Vector3
