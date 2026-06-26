extends RigidBody3D

const SPEED :float = 12.0
const LIFETIME: int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		linear_velocity += transform.basis * Vector3(0, 0, -SPEED)
		var timer = Timer.new()
		timer.autostart = true
		add_child(timer)
		timer.start(LIFETIME)
		timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout() -> void:
	if multiplayer.is_server():
		self.queue_free()
		
		
