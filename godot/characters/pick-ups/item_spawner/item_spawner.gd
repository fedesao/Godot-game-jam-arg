extends Area2D

@export var balas_revolver: PackedScene 
@export var balas_escopeta: PackedScene
@export var mates:PackedScene

var spawn_area = Rect2(Vector2(100, 100), Vector2(1000, 1000))
@export var spawn_interval: float = 2.0  # Intervalo entre cada aparición (en segundos)
@export var max_objects: int = 5  # Número máximo de objetos en el área
@onready var timer = $spawn_timer
var current_objects: int = 0  # Contador de objetos actuales

func _ready():
	start_spawning()

func start_spawning():
	# Inicia un temporizador para la aparición de objetos
	timer.start()


func _on_spawn_timer_timeout():
	# Si no hemos alcanzado el máximo de objetos, spawn un nuevo objeto
	if current_objects < max_objects:
		spawn_object_revolver()
		spawn_object_escopeta()
		spawn_object_mate()
	else:
		# Reinicia el temporizador para la próxima aparición
		start_spawning()

func spawn_object_revolver():
	# Calcula una posición aleatoria dentro del área de aparición
	var random_position = Vector2(
		randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
		randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	)	
	# Instancia el objeto y lo coloca en la posición aleatoria
	var new_object = balas_revolver.instantiate()
	new_object.position = random_position
	get_parent().add_child(new_object)  # Añadir el objeto a la escena
	current_objects += 1
	print("balas creado en: ", random_position)
	
func spawn_object_escopeta():
	# Calcula una posición aleatoria dentro del área de aparición
	var random_position = Vector2(
		randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
		randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	)	
	# Instancia el objeto y lo coloca en la posición aleatoria
	var new_object = balas_escopeta.instantiate()
	new_object.position = random_position
	get_parent().add_child(new_object)  # Añadir el objeto a la escena
	current_objects += 1
	print("escopeta creado en: ", random_position)
	
func spawn_object_mate():
	# Calcula una posición aleatoria dentro del área de aparición
	var random_position = Vector2(
		randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
		randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	)	
	# Instancia el objeto y lo coloca en la posición aleatoria
	var new_object = balas_revolver.instantiate()
	new_object.position = random_position
	get_parent().add_child(new_object)  # Añadir el objeto a la escena
	current_objects += 1
	print("mate creado en: ", random_position)
	
# Función para reducir la cantidad de objetos cuando uno se elimina
func remove_object():
	current_objects -= 1
