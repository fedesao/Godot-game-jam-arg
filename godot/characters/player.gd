extends CharacterBody2D
@export var speed = Global.playerSpeed
@export var life = Global.playerLife
@onready var posicion_pistola = $Marker2D
@onready var weapon = $weapon
#cambio de armas
@onready var weapon_slot = $WeaponSlots
var current_weapon: Node = null
var weapon_list: Array = []
var current_weapon_index = 0
#RELOAD
@onready var shootTimer = $ShootTimer
var current_weapon_name = "revolver"
@onready var progress_bar = %ProgressBar
####ESCOPETA
@export var max_escopeta_ammo:int = 2
@onready var current_escopeta_ammo = max_escopeta_ammo
@export var escopeta_reload_time:float = 1.5
var escopeta_bullet_texture = preload("res://assets/cartucho_escopeta.png")
var escopeta_bullet_texture_used = preload("res://assets/cartucho_escopeta_vacia.png")
####REVOVLER
@export var max_revolver_ammo:int = 6
@onready var current_revolver_ammo = max_revolver_ammo
@export var revolver_reload_time:float = 2.0
var revolver_bullet_texture = preload("res://assets/bala_revolver.png")
var revolver_bullet_texture_used = preload("res://assets/bala_revolver_vacia.png")

@onready var is_reloading:bool = false


func _ready():
	update_ammo_display()
	weapon_list = weapon_slot.get_children()
	print(weapon_list)
	if weapon_list.size() > 0:
		select_weapon(0)

func _physics_process(_delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	# Normalizamos para evitar que se mueva más rápido en diagonal
	input_vector = input_vector.normalized()
	velocity = input_vector * speed
	move_and_slide()
   # para que rote hacia el mouse
	look_at(get_global_mouse_position())
	#SELECCION DE ARMAS##
	if Input.is_action_just_pressed("arma1"):
		select_weapon(0)
		print("arma 1 revolver")
		shootTimer.stop()
		current_weapon_name = "revolver"
		update_ammo_display()
	elif Input.is_action_just_pressed("arma2"):
		select_weapon(1)
		shootTimer.stop()
		print("arma 2 escopeta")
		current_weapon_name = "escopeta"
		update_ammo_display()
	elif Input.is_action_just_pressed("arma3"):
		select_weapon(2)
		shootTimer.stop()
		print("arma 3 faca")
	if Input.is_action_just_pressed("disparar"):
		var direction2 = (get_global_mouse_position() - global_position).normalized()
		shoot_current_weapon(direction2)
		update_ammo_display()

		
#disparar arma seleccionado
func shoot_current_weapon(direction: Vector2):
	if not shootTimer.is_stopped():
		return
	if is_reloading:
		print("¡Todavía recargando!")
		return	
	match current_weapon_index:
		0:  # Revolver
			if current_revolver_ammo > 0:
				weapon.shoot_pistola(posicion_pistola.global_position, direction, get_parent())
				current_revolver_ammo -= 1
				print("revolver-Balas restantes: ", current_revolver_ammo)
			else:
				print("Sin balas")
				start_reload_revolver()
		1:  # Escopeta
			if current_escopeta_ammo > 0:
				weapon.shoot_escopeta(posicion_pistola.global_position, direction, get_parent())
				current_escopeta_ammo -= 1
				print("escopeta-Balas restantes: ", current_escopeta_ammo)
			else:
				print("Sin balas")
				start_reload_escopeta()
	shootTimer.start()

func start_reload_revolver():
	if current_revolver_ammo < max_revolver_ammo and not is_reloading:
		is_reloading = true
		show_reload_bar(revolver_reload_time)
		print("Recargando revolver...")		
		var timer = get_tree().create_timer(revolver_reload_time)
		show_reload_bar(revolver_reload_time)
		await timer.timeout		
		current_revolver_ammo = max_revolver_ammo
		is_reloading = false
		print("Recarga completa. Balas: ", current_revolver_ammo)
		update_ammo_display()

func start_reload_escopeta():
	if current_escopeta_ammo < max_escopeta_ammo and not is_reloading:
		is_reloading = true		
		print("Recargando escopeta...")
		var timer = get_tree().create_timer(escopeta_reload_time)
		show_reload_bar(escopeta_reload_time)
		await timer.timeout		
		current_escopeta_ammo = max_escopeta_ammo
		is_reloading = false
		print("Recarga completa. Balas: ", current_escopeta_ammo)
		update_ammo_display()

func select_weapon(index: int):
	current_weapon_index = index
	if index >= weapon_list.size():
		return
	for i in range(weapon_list.size()):
		weapon_list[i].visible = (i == index)
	current_weapon = weapon_list[index]

func update_ammo_display():
	# Acceder al `HBoxContainer` que contiene las balas
	var hbox = %Cargador_balas
	# Limpiar el `HBoxContainer`
	for child in hbox.get_children():
		hbox.remove_child(child)
		child.queue_free()		
	# Determinar la textura y la munición según el arma seleccionada
	var bullet_texture = revolver_bullet_texture if current_weapon_name == "revolver" else escopeta_bullet_texture
	var current_ammo = current_revolver_ammo if current_weapon_name == "revolver" else current_escopeta_ammo
	# Añadir nuevos `TextureRect` al `HBoxContainer`
	for i in range(current_ammo):
		var bullet_rect = TextureRect.new()
		bullet_rect.texture = bullet_texture
		bullet_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED  # Ajusta según el diseño deseado
		hbox.add_child(bullet_rect)
		
func show_reload_bar(duration: float):
	progress_bar.visible = true
	progress_bar.max_value = 100
	progress_bar.value = 0
	var time_passed := 0.0
	while time_passed < duration:
		await get_tree().process_frame
		time_passed += get_process_delta_time()		
		var percentage := (time_passed / duration) * 100.0
		progress_bar.value = clamp(percentage, 0, 100)
	progress_bar.value = 100
	progress_bar.visible = false
