extends CharacterBody2D

@export var vida = Global.chancho_lata_vida
@export var speed_normal = 50
@export var speed_embestida = 300
@export var distancia_deteccion = 200
@export var tiempo_preparacion = 0.5
@export var tiempo_recuperacion = 1.0
@export var duracion_maxima_embestida = 2.0
@export var distancia_maxima_embestida = 400

var player
var estado = "perseguir"
var direccion_embestida = Vector2.ZERO
var timer = 0.0
var posicion_inicio_embestida = Vector2.ZERO # Calcula la distancia recorrida
signal enemigo_muere

func _ready():
	player = get_node("../Player")

func _physics_process(delta):
	match estado:
		"perseguir":

			var direction = global_position.direction_to(player.global_position)
			velocity = direction * speed_normal			
			# Si está cerca, embiste
			if global_position.distance_to(player.global_position) < distancia_deteccion:
				estado = "preparar_embestida"
				timer = tiempo_preparacion
				# Guardar dirección hacia el player para embestida
				direccion_embestida = direction				
		"preparar_embestida":

			velocity = Vector2.ZERO
			timer -= delta
			if timer <= 0:
				estado = "embestida"
				timer = duracion_maxima_embestida
				posicion_inicio_embestida = global_position
				# Acá podrían ir efectos de sonido
				
		"embestida":

			velocity = direccion_embestida * speed_embestida
			# Detectar si chocó contra pared
			if is_on_wall():
				estado = "aturdido"
				timer = tiempo_recuperacion
				return				
			# Por límite de tiempo
			timer -= delta
			if timer <= 0:

				estado = "perseguir"
				return
				
			# Por límite de distancia
			var distancia_recorrida = global_position.distance_to(posicion_inicio_embestida)
			if distancia_recorrida >= distancia_maxima_embestida:

				estado = "perseguir"
				return
			
		"aturdido":

			velocity = Vector2.ZERO
			timer -= delta
			if timer <= 0:
				estado = "perseguir"
	move_and_slide()

func take_damage(dmgDone):
	vida -= dmgDone
	print(" chancho =recibio daño")
	if vida <= 0:
		enemigo_muere.emit()
		queue_free()


func _on_enemigo_muere() -> void:
	pass # sumar puntos?
