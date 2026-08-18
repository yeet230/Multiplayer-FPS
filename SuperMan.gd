extends Node

func get_player_canShoot(playerId : int) -> bool:
	if !multiplayer.is_server(): return false 
	
	var canShoot = MultiplayerManager.serverOnlyPlayerData[playerId][MultiplayerManager.PlayerData.CAN_SHOOT]
	return canShoot

func get_player_warnings() -> void:
	pass

func flag_player(who : int) -> void:
	print("Player May be Cheating. Marking them for Suspicion: ", str(who))
	#if 


func verify_damage(dmg : float, weaponID : Globals.WeaponID) -> float:
	return dmg if Tools.get_weapon_damage(weaponID) == dmg else 0.0
