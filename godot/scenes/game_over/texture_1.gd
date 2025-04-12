extends Sprite2D

# Dentro de un Node2D o el script del fondo
var original_pos: Vector2
var time := 0.0

func _ready():
	original_pos = position

func _process(delta):
	time += delta
	position = original_pos + Vector2(0, sin(time) * 5)
	modulate.a = 0.2 + sin(time) * 0.1  # oscilante 
