extends CharacterBody2D
@export var speed = Global.playerSpeed
@export var life = Global.playerLife
@onready var pistola = $Marker2D
#escena proyectil 1
@export var projectile_scene_1: PackedScene

func _physics_process(_delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	# Normalizamos para evitar que se mueva más rápido en diagonal
	input_vector = input_vector.normalized()
	velocity = input_vector * speed
	move_and_slide()
   # para que rote hacia el mouse
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	rotation = direction.angle()
	
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot_proyectile_1()
		
func shoot_proyectile_1():
	if projectile_scene_1 == null:
		return
	var projectile = projectile_scene_1.instantiate()
	get_parent().add_child(projectile)  
	projectile.global_position = pistola.global_position     # Posicionar el proyectil en el personaje
	# Calcular dirección hacia el mouse
	var dir = (get_global_mouse_position() - global_position).normalized()
	projectile.set_direction(dir)
