extends OmniLight3D

@export var maxEnergy: float = 8.0
@export var minEnergy: float = 0.0

@export var FadeInTime: float = 0.5
@export var FadeOutTime: float = 0.1

var nextFadeIn: bool = false
var fadeTween: Tween

func _on_timer_timeout() -> void:
	if nextFadeIn:
		fade_in()
		nextFadeIn = false
		$Timer.start(FadeInTime)
	else:
		fade_out()
		nextFadeIn = true
		$Timer.start(FadeOutTime)
		
		

func fade_in() -> void:
	if fadeTween:
		fadeTween.kill()
	
	fadeTween = create_tween()
	fadeTween.tween_property(self, "light_energy", maxEnergy, FadeInTime)

func fade_out() -> void:
	if fadeTween:
		fadeTween.kill()
	
	fadeTween = create_tween()
	fadeTween.tween_property(self, "light_energy", minEnergy, FadeOutTime)
