extends Node3D

@export var fadeDownValue: float = 0.0
@export var fadeUpValue: float = 8.0
@export var fadeTime: float = 1

var fade = true
var fadeTween: Tween

@onready var spot_light_3d: OmniLight3D = $House/Room1/SpotLight3D
@onready var timer: Timer = $House/Room1/SpotLight3D/Timer



func _on_timer_timeout() -> void:
	if fade:
		light_fade_in()
	else:
		light_fade_out()
	timer.start(fadeTime)

func light_fade_in() -> void:
	if fadeTween:
		fadeTween.kill()
		
	fadeTween = create_tween()
	#fadeTween.set_ease(Tween.EASE_IN_OUT)
	
	fadeTween.tween_property(spot_light_3d, "light_energy", fadeUpValue, fadeTime)
	

func light_fade_out() -> void:
	if fadeTween:
		fadeTween.kill()
	
	fadeTween = create_tween()
	#fadeTween.set_ease(Tween.EASE_IN_OUT)

	fadeTween.tween_property(spot_light_3d, "light_energy", fadeDownValue, fadeTime)
	
