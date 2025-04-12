extends CharacterBody2D

@export var vida: int = 80
@onready var vidaActual = vida
@export var speed: float = 70
@export var tiempo_entre_teleport: float = 4.0
@export var distancia_teleport_min: float = 200
@export var distancia_teleport_max: float = 400
@export var tiempo_preparacion: float = 0.8
@export var tiempo_recuperacion: float = 0.5
@export var max_intentos_teleport: int = 10  # Intentos máximos para encontrar posición válida

var player
var luz
var timer_teleport: float
var estado: String = "perseguir"
var estado_anterior: String = ""
var rastro_original_pos: Vector2
var rng = RandomNumberGenerator.new()

var frecuencia: float = 6.0
var amplitud: float = 0.5

var luz_energy_original: float
var luz_scale_original: Vector2

signal enemigo_muere
signal efecto_teleport(pos_inicial, pos_final)

func _ready():
	player = get_node("../Player")
	luz = $PointLight2D
	timer_teleport = tiempo_entre_teleport
	rng.randomize()
	luz_energy_original = luz.energy
	luz_scale_original = luz.scale

func _physics_process(delta):
	
	if estado != estado_anterior:
		print("Cambio de estado a ", estado)
		estado_anterior = estado
	
	match estado:
		"perseguir":
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * speed
			
			# Cuenta regresiva para teleportación
			timer_teleport -= delta
			if timer_teleport <= 0:
				estado = "preparar_teleport"
				timer_teleport = tiempo_preparacion
				rastro_original_pos = global_position
				velocity = Vector2.ZERO
				
		"preparar_teleport":
			# Efecto visual de preparación
			velocity = Vector2.ZERO
			timer_teleport -= delta
			#var t = tiempo_preparacion - timer_teleport
			#luz.energy = intensidad_base + sin(t * frecuencia) * amplitud
			get_viewport().get_camera_2d().start_camera_shake(20.0)
			var t = Time.get_ticks_msec() / 1000.0
			var pulso = sin(t * frecuencia * 3.0) * 0.5 + sin(t * frecuencia) * 0.5
			luz.energy = luz_energy_original + pulso * amplitud * 1.5
			luz.scale = luz_scale_original * (1.0 + pulso * 0.2)
			if timer_teleport <= 0:
				realizar_teleport()
				
		"recuperacion":
			velocity = Vector2.ZERO
			timer_teleport -= delta
			luz.energy = luz_energy_original
			luz.scale = luz_scale_original
			if timer_teleport <= 0:
				estado = "perseguir"
				timer_teleport = tiempo_entre_teleport	
	move_and_slide()

func realizar_teleport():
	var pos_valida = encontrar_posicion_teleport()
	
	if pos_valida != Vector2.ZERO:
		print("Teleportando de ", global_position, " a ", pos_valida)		
		# Señal para efectos visuales
		efecto_teleport.emit(global_position, pos_valida)		
		spawn_rastro_fantasmal(rastro_original_pos)		
		# Realizar teleport
		global_position = pos_valida		
		# Cambiar a recuperación
		estado = "recuperacion"
		timer_teleport = tiempo_recuperacion
	else:
		print("Teleportación fallida - no se encontró posición válida")
		estado = "perseguir"
		timer_teleport = tiempo_entre_teleport * 0.5 # Espera menos tiempo para reintentar
		
func encontrar_posicion_teleport() -> Vector2:
	for _i in range(max_intentos_teleport):
		# Generar ángulo aleatorio alrededor del player
		var angulo = rng.randf_range(0, 2 * PI)
		var distancia = rng.randf_range(distancia_teleport_min, distancia_teleport_max)
		
		# Calcula nueva pos
		var pos_potencial = player.global_position + Vector2(cos(angulo), sin(angulo)) * distancia
		
		# Verificacion posición válida
		if es_posicion_valida(pos_potencial):
			return pos_potencial
			
	return Vector2.ZERO # No se encontró posición válida
	
func es_posicion_valida(pos: Vector2) -> bool:
	# Calcula posición básica libre de colisione con raycast
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, pos, 4, [self])
	var result = space_state.intersect_ray(query)
	
	# Si no hay colisión, la posición es válida
	return result.is_empty()
	
func spawn_rastro_fantasmal(pos: Vector2):
	# Deja un área de daño
	var rastro_scene = load("res://enemigos/luz_mala/rastro_fantasmal.tscn")
	var rastro = rastro_scene.instantiate()
	rastro.global_position = pos
	get_parent().add_child(rastro)
	print("Rastro fantasmal creado en ", pos)

func take_damage(dmgDone):
	vidaActual -= dmgDone
	print("Teleportador recibió daño: ", dmgDone, " - Vida: ", vida)
	
	# Teleport inmediato al recibir daño
	if vidaActual <= 0 and estado == "perseguir" and rng.randf() < 0.3:
		print("Escape de emergencia!")
		estado = "preparar_teleport"
		#timer_teleport = tiempo_preparacion * 0.5 # Más rápido por emergencia
		#rastro_original_pos = global_position
		#velocity = Vector2.ZERO
		
	if vidaActual <= 0:
		enemigo_muere.emit()
		queue_free()


func _on_enemigo_muere() -> void:
	pass # sumar puntos?
