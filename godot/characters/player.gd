extends CharacterBody2D
@export var speed = Global.playerSpeed
@export var life = Global.playerLife

func _physics_process(_delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	# Normalizamos para evitar que se mueva más rápido en diagonal
	input_vector = input_vector.normalized()
	velocity = input_vector * speed
	move_and_slide()
   # para que rote hacia el mouse
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	rotation = direction.angle()
