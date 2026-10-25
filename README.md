How to Use:
	Make sure under Debug tab make atleast 2 instances run with the first having "dedicated_server" under feature tags
	use username=username to set the players username automaticlly. ignore the brackets


-Balence Idea:
	Make the flashlight turn on and off when the player moves eg moving comes with the tradeoff of being seen.
	change the light to instead be an omni light that does not cause shadows from the player model




-ERRORS
	0 = ERR_SERVER_ONLY_ACCESS: 	This error will be thrown when a client runs code that is meant to be server only
	1 = ERR_CLIENT_ONLY_CODE:   	Similar to ERR_SERVER_ONLY_ACCESS but is intended to protect client only code rather than server only code.
	2 = ERR_CAN_NOT_CONNECT_TO_SERVER: Error thrown when a client can not connect to a server likly because of invalid setup or user input when joining a game.




-Ideas
	- make the joining system better byu making user's join then handle any other data required such as username and loadout/perks


-Needs Refining
	[] - [Damage Viginette found at](Actors/Player/Player/playerUI.gd)
