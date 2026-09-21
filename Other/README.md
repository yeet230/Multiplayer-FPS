Make sure under Debug tab make atleast 2 instances run with the first having "dedicated_server" under feature tags
use username=(Value) to set the players username


[] Check MultiplayerManager.gd and rework parts to ensure only one RPC is called to the Player
[] Lower the shoot distance of SMG to be lower than Pistols 25m?
[] Create the other weapons and also fix and remove parts of the old weapon System


-Balence Idea:
	Make the lfashlight turn on and off when the player moves eg moving comes with the tradeoff of being seen.
	change the light to instead be an omni light that does not cause shadows from the player model




-ERRORS
	0 = ERR_SERVER_ONLY_ACCESS: 	This error will be thrown when a client runs code that is meant to be server only
	1 = ERR_CLIENT_ONLY_CODE:   	Similar to ERR_SERVER_ONLY_ACCESS but is intended to protect client only code rather than server only code.
	2 = ERR_CAN_NOT_CONNECT_TO_SERVER: Error thrown when a client can not connect to a server likly because of invalid setup or user input when joining a game.
