extends CharacterBody2D
@export var speed = Global.playerSpeed
@export var life = Global.playerLife
@onready var posicion_pistola = $Marker2D
@onready var weapon = $weapon
#escena proyectil 1


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
		var direction = (get_global_mouse_position() - global_position).normalized()
		weapon.shoot_proyectile_1(posicion_pistola.global_position, direction, get_parent())
		
