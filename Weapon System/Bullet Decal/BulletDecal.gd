extends MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		var timer = Timer.new()
		timer.timeout.connect(_on_timer_timeout)
		add_child(timer)
		timer.start(6.0)
	


func _on_timer_timeout() -> void:
	if multiplayer.is_server():
		_destroy.rpc()
		

@rpc("authority", "call_local")
func _destroy() -> void:
	self.queue_free()
