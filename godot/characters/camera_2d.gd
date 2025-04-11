extends Camera2D

var shake_strength: float = 0.0
var shake_decay: float = 5.0

func _process(delta):
	if shake_strength > 0:
		offset = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_strength
		shake_strength = lerp(shake_strength, 0.0, delta * shake_decay)
	else:
		offset = Vector2.ZERO

func shake(intensidad: float):
	shake_strength = intensidad
