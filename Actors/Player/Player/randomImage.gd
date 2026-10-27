@tool # Allows it to update in the editor in real-time

extends Sprite3D


# The maximum allowed width or height in 3D units (meters)
@export var max_size_meters: float = 2.0:
	set(value):
		max_size_meters = value
		_ready()

func _ready() -> void:
	var images: Array = [
		preload("res://secrets/IMG_20260212_103444_495.jpg"),
		preload("res://secrets/IMG_20260408_222429_344.jpg"),
		preload("res://secrets/IMG_20260815_162023_008.jpg"),
		preload("res://secrets/IMG_20260819_194716_500.jpg"),
		preload("res://secrets/IMG_20260828_133646_424.jpg"),
		preload("res://secrets/IMG_20260917_060749_228.jpg"),
		preload("res://secrets/Screenshot_20260517_213134_Instagram.jpg"),
		preload("res://secrets/Snapchat-431630032.jpg"),
		preload("res://secrets/Snapchat-459407843.jpg"),
		preload("res://secrets/Snapchat-546684059.jpg"),
		preload("res://secrets/Snapchat-1766340598.jpg"),
	]
	
	texture = images.pick_random()
	
	# Re-clamp whenever the texture changes at runtime
	texture_changed.connect(_clamp_size)
	_clamp_size()

func _clamp_size() -> void:
	if !texture:
		return
		
	# 1. Reset scale to 1 to calculate base 3D size accurately
	scale = Vector3.ONE
	
	# 2. Calculate the base size in 3D units (pixels * pixel_size)
	var texture_size = texture.get_size()
	var base_width_meters = texture_size.x * pixel_size
	var base_height_meters = texture_size.y * pixel_size
	
	# 3. Find the largest dimension
	var max_current_dimension = max(base_width_meters, base_height_meters)
	
	# 4. If it exceeds the limit, calculate the uniform reduction scale
	if max_current_dimension > max_size_meters:
		var reduction_factor = max_size_meters / max_current_dimension
		scale = Vector3(reduction_factor, reduction_factor, reduction_factor)
