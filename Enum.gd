extends Node

enum PLAYERSTATE {
	DEAD,
	DOWNED,
	ALIVE,
	DEBUG,
	SPECTATE
}

##Contains the keys to all custom errors that will be thrown: check ReadMe for key details
enum ERRORS {
	ERR_SERVER_ONLY_ACCESS = 0,
	ERR_CLIENT_ONLY_ACCESS = 1,
	ERR_CAN_NOT_CONNECT_TO_SERVER = 2
}

##Weapons in the range [b]0 - 99[/b] are Pistols, [b]100 - 199[/b] are SMG's, [b]200 - 299[/b] are Rifles, [b]300 - 399[/b] are Shotguns, [b]400 - 499[/b] are Melee
enum WeaponID {
	USG_57 = 0,
	DEAGLE = 1, 
	MP5 = 100,
	P90 = 101,
	AK12 = 200,
	FRF2 = 201, ##(Server will only accept single fire at the moment)
	M1014 = 300, ##Shotguns are temporarily unavaliable due to reworking of weapon system
	SUPER_SHORTY = 301,
	KITCHEN_KNIFE = 400,
	MACHETE = 401,
	PEA_SHOOTER = -1,
	GODS_GUM = -2,
	THE_JACOB_SPECIAL = -3,
	G502_MOUSE = -100,
	THE_7900_GRE = -101
}
