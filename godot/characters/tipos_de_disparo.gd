extends Node
@export var projectile_scene_1: PackedScene
@export var projectile_scene_2 : PackedScene

@export var num_pellets: int = 6
@export var spread_angle_degrees: float = 25.0



func shoot_pistola(origin: Vector2, direction: Vector2, parent: Node):
	if projectile_scene_1 == null:
		return
	var projectile = projectile_scene_1.instantiate()
	parent.add_child(projectile)
	projectile.global_position = origin
	projectile.set_direction(direction)


func shoot_escopeta(origin: Vector2, direction: Vector2, parent: Node):
	if projectile_scene_2 == null:
		return
	for i in num_pellets:
		# ángulo aleatorio de dispersión
		var angle_offset = deg_to_rad(randf_range(-spread_angle_degrees / 2, spread_angle_degrees / 2))
		var dir = direction.rotated(angle_offset).normalized()
		var projectile = projectile_scene_2.instantiate()
		parent.add_child(projectile)
		projectile.global_position = origin
		projectile.set_direction(dir)

		
