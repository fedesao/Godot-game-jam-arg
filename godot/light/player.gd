extends CharacterBody2D

@export var speed: float = 200.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var flashlight = $PointLight2D

func _ready():
	flashlight.rotation = 0
	pass
	
func _physics_process(delta):
	var direction = Vector2.ZERO
	
	# Detectar input para el movimiento
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
		animated_sprite.flip_h = false
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
		animated_sprite.flip_h = true
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	

	if direction.length() > 0:
		direction = direction.normalized()
		

		if abs(direction.x) > abs(direction.y):
			# Movimiento horizontal predominante
			animated_sprite.play("run")
		else:

			if direction.y > 0:
				animated_sprite.play("run")
			else:
				animated_sprite.play("run")
	else:

		animated_sprite.play("idle")

	velocity = direction * speed
	

	move_and_slide()
	# Rotar la linterna para que apunte al cursor
	update_flashlight_rotation(delta)
	
func update_flashlight_rotation(_delta):
	var mouse_position = get_global_mouse_position()
	
	var direction = (mouse_position - global_position).normalized()
	flashlight.rotation = direction.angle() + deg_to_rad(-45)
	
