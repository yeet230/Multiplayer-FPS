class_name WeaponData extends Resource
##Key data used by the Server. Do not change otherwise you will be kicked from the lobby

@export_category("Data") 
@export var damage: float
@export var ammo: int
@export var weaponName: String
@export var WeaponID: Globals.WeaponID

@export_category("Weapon Settings")
@export var fireMode: WeaponManager.shootingTypes
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
