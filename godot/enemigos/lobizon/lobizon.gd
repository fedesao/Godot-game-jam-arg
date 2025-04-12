extends CharacterBody2D


@onready var vidaActual = vida
@export var vida = 100
@export var speed = 50
@export var prob_esquivar = 0.2
@export var duracion_esquive = 1
@export var velocidad_esquive = 50
@onready var barraVida = $ProgressBar
@onready var sprite = $ElFamiliarConceptArt
@onready var marker = $Marker2D
@onready var col_shape = $CollisionShape2D


var player
var esquivando = false
var direccion_esquive = Vector2.ZERO
var timer_esquive = 0.0
signal enemigo_muere

func _ready():
	player = get_node("../Player")
	timer_esquive = 0.0

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position) # Calcular dirección
	var angle = direction.angle() # Calcular ángulo
	sprite.rotation = angle
	marker.rotation = angle
	col_shape.rotation = angle + deg_to_rad(90)
	
	if esquivando:
		velocity = direccion_esquive * speed * velocidad_esquive
		timer_esquive -= delta
		if timer_esquive <= 0:
			esquivando = false
			print("Terminó la esquiva")
	else:
		velocity = direction * speed
		
	move_and_slide()
	barraVida.max_value = vida#ACTUALIZAR VIDA
	barraVida.value = vidaActual
	
func intentar_esquivar(direccion_proyectil):
	if esquivando:
		print("Ya esquivando, no puede hacerlo de nuevo")
		return false
	
	if randf() < prob_esquivar:
		# Dirección perpendicular al proyectil
		direccion_esquive = Vector2(-direccion_proyectil.y, direccion_proyectil.x).normalized()
		
		# Decisión aleatoria de dirección de esquive
		if randf() > 0.5:
			direccion_esquive = -direccion_esquive
			
		esquivando = true
		print("Esquivando hacia ", direccion_esquive, "!")
		return true
	print("Intento de esquive fallido")
	return false
	
func _on_area_detection_area_entered(area):
	if area.get_collision_layer_value(3):
		print("Proyectil detectado!")
		var direccion_proyectil = area.global_position.direction_to(global_position)
		intentar_esquivar(direccion_proyectil)

func take_damage(dmgDone):
	var direction = player.global_position.direction_to(global_position)
	
	if not esquivando: # Intenta esquivar si no está esquivando ya
		intentar_esquivar(direction)
	vidaActual -= dmgDone # Para aplicar el daño sin importar la esquiva
	print("recibio daño: ", vida)
	barraVida.value = vidaActual
	
	if vidaActual <= 0:
		print("Lobezno ha muerto!")
		enemigo_muere.emit()
		Global.efecto_muerte(self)
				
func _on_enemigo_muere() -> void:
	Global.puntaje += 1
