extends CharacterBody2D
signal player_muere
@export var speed = Global.playerSpeed
@export var life = Global.playerLife
@onready var posicion_pistola = %markerRevolver
@onready var posicion_escopeta = %markerEscopeta
@onready var weapon = $weapon
var impulso = Vector2.ZERO
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
var escopeta_max_ammo_held = Global.escopeta_max_ammo_held
var escopeta_actual_ammo_held = Global.escopeta_actual_ammo_held
@export var max_escopeta_ammo:int = 2
@onready var current_escopeta_ammo = max_escopeta_ammo
@export var escopeta_reload_time:float = 1.5
var escopeta_bullet_texture = preload("res://assets/cartucho_escopeta.png")
var escopeta_bullet_texture_used = preload("res://assets/cartucho_escopeta_vacia.png")
####REVOVLER
var revolver_max_ammo_held = Global.revolver_max_ammo_held
var revolver_actual_ammo_held = Global.revolver_actual_ammo_held
@export var max_revolver_ammo:int = 6
@onready var current_revolver_ammo = max_revolver_ammo
@export var revolver_reload_time:float = 2.0
var revolver_bullet_texture = preload("res://assets/bala_revolver.png")
var revolver_bullet_texture_used = preload("res://assets/bala_revolver_vacia.png")

@onready var is_reloading:bool = false
@onready var barra_vida = %BarraVida

##DASH
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 1.0
var can_dash: bool = true
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO


func _ready():
	update_ammo_display()
	weapon_list = weapon_slot.get_children()
	print(weapon_list)
	if weapon_list.size() > 0:
		select_weapon(0)
	barra_vida.max_value = life

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	# Normalizamos para evitar que se mueva más rápido en diagonal
	input_vector = input_vector.normalized()
	velocity = input_vector * speed + impulso
	move_and_slide()
	impulso = impulso.lerp(Vector2.ZERO, 5 * delta)
	update_life()
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
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		dash_direction = input_vector
		if dash_direction != Vector2.ZERO:
			start_dash()

		
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
				print("revolver - Balas cargador: ", current_revolver_ammo)
			elif revolver_actual_ammo_held > 0:
				print("Sin balas en el cargador. Recargando...")
				start_reload_revolver()
			else:
				print("¡No quedan balas de revolver!")
		1:  # Escopeta
			if current_escopeta_ammo > 0:
				weapon.shoot_escopeta(posicion_escopeta.global_position, direction, get_parent())
				current_escopeta_ammo -= 1
				aplicar_retroceso(direction, 85)
				$Camera2D.start_camera_shake(20.0)
				print("escopeta - Balas cargador: ", current_escopeta_ammo)
			elif escopeta_actual_ammo_held > 0:
				print("Sin balas en el cargador. Recargando...")
				start_reload_escopeta()
			else:
				print("¡No quedan balas de escopeta!")
	shootTimer.start()
	update_ammo_display()


func start_reload_revolver():
	if is_reloading or current_revolver_ammo == max_revolver_ammo:
		return

	var balas_necesarias = max_revolver_ammo - current_revolver_ammo
	var balas_a_recargar = min(balas_necesarias, revolver_actual_ammo_held)

	if balas_a_recargar <= 0:
		print("No quedan balas para recargar el revolver.")
		return

	is_reloading = true
	show_reload_bar(revolver_reload_time)
	print("Recargando revolver...")
	await get_tree().create_timer(revolver_reload_time).timeout

	current_revolver_ammo += balas_a_recargar
	revolver_actual_ammo_held -= balas_a_recargar
	is_reloading = false
	print("Recarga completa. Cargador: ", current_revolver_ammo, " | Reservas: ", revolver_actual_ammo_held)
	update_ammo_display()


func start_reload_escopeta():
	if is_reloading or current_escopeta_ammo == max_escopeta_ammo:
		return

	var balas_necesarias = max_escopeta_ammo - current_escopeta_ammo
	var balas_a_recargar = min(balas_necesarias, escopeta_actual_ammo_held)

	if balas_a_recargar <= 0:
		print("No quedan balas para recargar la escopeta.")
		return

	is_reloading = true
	show_reload_bar(escopeta_reload_time)
	print("Recargando escopeta...")
	await get_tree().create_timer(escopeta_reload_time).timeout

	current_escopeta_ammo += balas_a_recargar
	escopeta_actual_ammo_held -= balas_a_recargar
	is_reloading = false
	print("Recarga completa. Cargador: ", current_escopeta_ammo, " | Reservas: ", escopeta_actual_ammo_held)
	update_ammo_display()


func select_weapon(index: int):
	current_weapon_index = index
	if index >= weapon_list.size():
		return
	for i in range(weapon_list.size()):
		weapon_list[i].visible = (i == index)
	current_weapon = weapon_list[index]

func update_ammo_display():
	var hbox = %Cargador_balas
	for child in hbox.get_children():
		hbox.remove_child(child)
		child.queue_free()
	var bullet_texture = revolver_bullet_texture if current_weapon_name == "revolver" else escopeta_bullet_texture
	var current_ammo = current_revolver_ammo if current_weapon_name == "revolver" else current_escopeta_ammo
	for i in range(current_ammo):
		var bullet_rect = TextureRect.new()
		bullet_rect.texture = bullet_texture
		bullet_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(bullet_rect)
	# Actualizar los labels de texto
	$CanvasLayer/balasRevolver.text = str(current_revolver_ammo) + "/" + str(revolver_actual_ammo_held)
	$CanvasLayer/balasEscopeta.text = str(current_escopeta_ammo) + "/" + str(escopeta_actual_ammo_held)

		
		
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


###RECIBIR DAÑO
func take_damage_player(dmgDone):
	life -= dmgDone
	update_life()
	print(" player recibio daño")
	print(life)
	if life <= 0:
		player_muere.emit()
		queue_free()
		
func update_life():
	barra_vida.value = life	
	
func aplicar_retroceso(direccion_disparo: Vector2, fuerza: float):
	impulso = -direccion_disparo.normalized() * fuerza

func agregar_municion(arma: String, cantidad: int):
	if arma == "revolver":
		revolver_actual_ammo_held = min(revolver_actual_ammo_held + cantidad, revolver_max_ammo_held)
		print("Recogiste balas de revolver. Total ahora: ", revolver_actual_ammo_held)
	elif arma == "escopeta":
		escopeta_actual_ammo_held = min(escopeta_actual_ammo_held + cantidad, escopeta_max_ammo_held)
		print("Recogiste balas de escopeta. Total ahora: ", escopeta_actual_ammo_held)
	update_ammo_display()

###DASH
func start_dash():
	is_dashing = true
	can_dash = false
	impulso = dash_direction.normalized() * dash_speed
	var dash_timer = get_tree().create_timer(dash_duration)
	await dash_timer.timeout
	is_dashing = false
	# Enfriamiento
	var cooldown_timer = get_tree().create_timer(dash_cooldown)
	await cooldown_timer.timeout
	can_dash = true
