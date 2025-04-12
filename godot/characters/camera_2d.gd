extends Camera2D
# En el script del Camera2D
var shake_strength = 0.0
var shake_decay = 5.0
var original_position = Vector2.ZERO

func _ready():
	original_position = position

func _process(delta):
	if shake_strength > 0:
		var offset1 = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		) * shake_strength
		position = original_position + offset1
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
	else:
		position = original_position

func start_camera_shake(strength: float):
	shake_strength = strength
