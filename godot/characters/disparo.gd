extends Node
@export var projectile_scene_1: PackedScene

func shoot_proyectile_1(origin: Vector2, direction: Vector2, parent: Node):
	if projectile_scene_1 == null:
		return
	var projectile = projectile_scene_1.instantiate()
	parent.add_child(projectile)
	projectile.global_position = origin
	projectile.set_direction(direction)
