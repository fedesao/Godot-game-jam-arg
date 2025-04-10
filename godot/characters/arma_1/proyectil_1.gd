extends Node2D
@export var speed = Global.balaSpeed1
var direction: Vector2 = Vector2.ZERO

func set_direction(dir: Vector2):
	direction = dir.normalized()
	rotation = direction.angle()  # Solo se rota una vez al disparar

func _physics_process(delta):
	position += direction * speed * delta
