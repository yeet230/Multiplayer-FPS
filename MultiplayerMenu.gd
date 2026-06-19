extends Control



func _on_host_pressed() -> void:
	MultiplayerManager.start_server()
	print(IP.get_local_addresses())


func _on_join_pressed() -> void:
	var ip = %IPTextEdit.text
	MultiplayerManager.join_server(ip)
