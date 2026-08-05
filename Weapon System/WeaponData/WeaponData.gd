class_name WeaponData extends Resource
##Key data used by the Server. Do not change otherwise you will be kicked from the lobby

@export_category("Data") 
@export var damage: float
@export var weaponScript: GDScript
@export var ammo: int
@export var weaponName: String
@export var WeaponID: Globals.WeaponID


@export_category("Weapon Settings")
@export var fireMode: WeaponBase.shootingTypes
@export var reloadType: WeaponBase.ReloadStyle
@export var shootDistance: float
@export var reloadSpeed: float
@export var fireRate: float
@export var bulletSpread: float
@export var projectilesPerShot: int
@export var magSize: int
