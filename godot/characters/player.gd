extends CharacterBody2D
signal player_muere
@export var speed = Global.playerSpeed
@export var life = Global.playerLife
@onready var posicion_pistola = %markerRevolver
@onready var posicion_escopeta = %markerEscopeta
@onready var weapon = $weapon
var impulso = Vector2.ZERO
@onready var puntaje = $CanvasLayer/puntaje
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
var escopeta_bullet_texture = preload("res://assets/armas/BalaEscopeta1.png")
var escopeta_bullet_texture_used = preload("res://assets/cartucho_escopeta_vacia.png")
@onready var escopeta_reload_audio = $ReloadingAudioEscopeta
@onready var escopeta_shoot_audio = $ShootAudioEscopeta
@onready var escopeta_changebullet_audio = $ChangeBulletAudioEscopeta
####REVOVLER
var revolver_max_ammo_held = Global.revolver_max_ammo_held
var revolver_actual_ammo_held = Global.revolver_actual_ammo_held
@export var max_revolver_ammo:int = 6
@onready var current_revolver_ammo = max_revolver_ammo
@export var revolver_reload_time:float = 2.0
var revolver_bullet_texture = preload("res://assets/armas/BalaRevolver.png")
var revolver_bullet_texture_used = preload("res://assets/bala_revolver_vacia.png")

@onready var is_reloading:bool = false
@onready var barra_vida = %BarraVida
@onready var revolver_shoot_audio = $ShootAudioRevolver
@onready var revolver_reload_audio = $ReloadingRevolver

##DASH

@onready var dash_icon = $"CanvasLayer/Dash-icon"
var dash_timer: float = 0.0
var dash_cooldown: float = 3.0  # Tiempo de enfriamiento
var dash_duration: float = 0.2  # Duración del dash
var dash_speed: float = 300  # Velocidad del dash
var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO  # Dirección del dash






func _ready():
	update_ammo_display()
	weapon_list = weapon_slot.get_children()
	print(weapon_list)
	if weapon_list.size() > 0:
		select_weapon(0)
	barra_vida.max_value = life
	$"CanvasLayer/icon-Revolver".visible = true
	$"CanvasLayer/icon-Escopeta".visible = false


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
	puntaje.text = "Enemigos Exorcisados  :  " + str(Global.puntaje)
   # para que rote hacia el mouse
	look_at(get_global_mouse_position())
	#SELECCION DE ARMAS##
	if Input.is_action_just_pressed("arma1"):
		select_weapon(0)
		print("arma 1 revolver")
		shootTimer.stop()
		current_weapon_name = "revolver"
		update_ammo_display()
		$"CanvasLayer/icon-Revolver".visible = true
		$"CanvasLayer/icon-Escopeta".visible = false
	elif Input.is_action_just_pressed("arma2"):
		select_weapon(1)
		shootTimer.stop()
		print("arma 2 escopeta")
		current_weapon_name = "escopeta"
		update_ammo_display()
		$"CanvasLayer/icon-Revolver".visible = false
		$"CanvasLayer/icon-Escopeta".visible = true
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
	if Input.is_action_just_pressed("recargar"):
		if not is_reloading:
			if current_weapon_name == "revolver" and current_revolver_ammo < max_revolver_ammo and revolver_actual_ammo_held > 0:
				start_reload_revolver()
			elif current_weapon_name == "escopeta" and current_escopeta_ammo < max_escopeta_ammo and escopeta_actual_ammo_held > 0:
				start_reload_escopeta()

		
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
				revolver_shoot_audio.play()
			elif revolver_actual_ammo_held > 0:
				print("Sin balas en el cargador. Recargando...")
				start_reload_revolver()
			else:
				print("¡No quedan balas de revolver!")
		1:  # Escopeta
			if current_escopeta_ammo > 0:
				weapon.shoot_escopeta(posicion_escopeta.global_position, direction, get_parent())
				current_escopeta_ammo -= 1
				escopeta_shoot_audio.play()
				aplicar_retroceso(direction, 85)
				$Camera2D.start_camera_shake(20.0)
				print("escopeta - Balas cargador: ", current_escopeta_ammo)
				await get_tree().create_timer(1.0).timeout
				escopeta_changebullet_audio.play()
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
	revolver_reload_audio.play()

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
	escopeta_reload_audio.play()


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
		bullet_rect.custom_minimum_size = Vector2(200, 0)  # Aumentar
		hbox.add_child(bullet_rect)
	# Actualizar los labels de texto
	$CanvasLayer/balasRevolver.text = str(current_revolver_ammo) + " de " + str(revolver_actual_ammo_held)
	$CanvasLayer/balasEscopeta.text = str(current_escopeta_ammo) + " de " + str(escopeta_actual_ammo_held)

		
		
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
		get_tree().change_scene_to_file("res://scenes/game_over/game_over.tscn")
		
func update_life():
	barra_vida.value = life	
	update_damage_screen_effect()
	
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
	
##RECUPERAR VIDA
func recuperar_vida(cantidad:int):
	life += cantidad
	update_life()
	

###DASH
func start_dash():
	if can_dash:  # Solo ejecutar si se puede hacer el dash
		is_dashing = true
		can_dash = false
		dash_icon.modulate.a = 0.0
		impulso = dash_direction.normalized() * dash_speed
		var dash_timer_instance = get_tree().create_timer(dash_duration)
		await dash_timer_instance.timeout  # Esperar a que termine el dash
		is_dashing = false		# Fin del dash
		# Enfriamiento
		var cooldown_timer_instance = get_tree().create_timer(dash_cooldown)
		await cooldown_timer_instance.timeout  # Esperar el tiempo de cooldown
		can_dash = true
		dash_icon.modulate.a = 1.0
	
func update_damage_screen_effect():
	var screen = %color_muerte
	var base_alpha: float = clamp(1.0 - float(life) / float(Global.playerLife), 0.0, 0.7)
	var color: Color = Color(1.0, 1.0 - base_alpha, 1.0 - base_alpha, base_alpha)
	# Si la vida está críticamente baja, hacer parpadear
	if life <= Global.playerLife * 0.2:
		var pulse := sin(Time.get_ticks_msec() / 100.0) * 0.2
		color.a = clamp(base_alpha + pulse, 0.0, 1.0)
	screen.modulate = color
