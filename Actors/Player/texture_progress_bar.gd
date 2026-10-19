extends NinePatchRect

@onready var progress_bar: TextureProgressBar = $TextureProgressBar

# Adjust this to match the literal pixel width of your single 10-health box image
@export var single_box_pixel_width: float = 10.0

func _ready() -> void:
	# Makes sure the child progress bar copies the exact parent size
	progress_bar.set_anchors_preset(Control.PRESET_FULL_RECT)

## Call this function from your player whenever health or max health updates
func update_health(current_health: float, max_health: float = 100) -> void:
	progress_bar.max_value = max_health
	progress_bar.value = current_health
	
	# R6 Style Math: Calculate how many total 10-HP boxes are needed
	var total_segments: float = max_health / 10.0
	
	# Dynamically scale the horizontal width of the UI component
	var desired_width: float = total_segments * single_box_pixel_width
	
	# Update the parent border size. The child progress bar will auto-stretch to fit!
	custom_minimum_size.x = desired_width
