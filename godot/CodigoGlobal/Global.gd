extends Node

#var player
var playerLife:int = 100
var playerSpeed:float = 50.0
var playerDmg:float = 5.0
var balasDisponibles:int = 6 #a revisar
var puntaje:int = 0

### VAR ARMAS
#pistola
var balaSpeed1:float = 200.0
var balaDmg1:int = 5

var revolver_actual_ammo_held:int = 10
var revolver_max_ammo_held:int = 40
var escopeta_max_ammo_held:int = 48
#escopeta
var escopetaSpeed:float = 150.0
var escopetaDmg:int = 2

var escopeta_actual_ammo_held:int = 10


#enemigos
var enemigo_1_vida:int = 12
var enemigo_1_speed:float = 60.0
var enemyDmg:int = 4

var chancho_lata_vida:int = 40
var chanchoDmg:int = 35

var luz_mala_dmg:int = 45
var luz_mala_vida:int = 80
var luz_mala_speed:float = 70

func efecto_muerte(enemigo: CharacterBody2D):
	# Crear rastro para la sangre
	var rastro_original_pos: Vector2
	rastro_original_pos = enemigo.global_position
	
	# Desactivar colisiones y lógica del enemigo
	enemigo.set_process(false)
	enemigo.set_physics_process(false)	
	# Desactivar Collisions de hijos directos (no collisions secundarias)
	if enemigo.has_node("CollisionShape2D"):
		enemigo.get_node("CollisionShape2D").set_deferred("diabled", true)		
	# Creación tween para animación de muerte
	var tween = create_tween()
	tween.set_parallel(true)	
	# Gira mientras desaparece
	tween.tween_property(enemigo, "scale", Vector2(0.1, 0.1), 0.5)	
	# Efecto de desvanecer
	tween.tween_property(enemigo, "modulate", Color (1, 0, 0, 0), 0.5)	
	# Eliminar el nodo al terminar animación
	await tween.finished	
	#REVISAR!!!!s
	if not enemigo.is_queued_for_deletion(): # Pongo esto porque cuando se mata a uno con escopeta, los proyectiles que quedan crashean el juego.
		enemigo.queue_free()
	spawn_rastro_sangre(rastro_original_pos)

func spawn_rastro_sangre(pos: Vector2):
	var rastro_scene = load("res://enemigos/onDeath/charcho_sangre.tscn")
	var rastro = rastro_scene.instantiate()
	rastro.global_position = pos
	get_parent().add_child(rastro)
