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

####ESCOPETA
@export var max_escopeta_ammo:int = 2
@onready var current_escopeta_ammo = max_escopeta_ammo
@export var escopeta_reload_time:float = 1.5
####REVOVLER
@export var max_revolver_ammo:int = 6
@onready var current_revolver_ammo = max_revolver_ammo
@export var revolver_reload_time:float = 2.0

@onready var is_reloading:bool = false



func _ready():
	# Guardamos todas las armas en el slot
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
	elif Input.is_action_just_pressed("arma2"):
		select_weapon(1)
		shootTimer.stop()
		print("arma 2 escopeta")
	elif Input.is_action_just_pressed("arma3"):
		select_weapon(2)
		shootTimer.stop()
		print("arma 3 faca")
	if Input.is_action_just_pressed("disparar"):
		var direction2 = (get_global_mouse_position() - global_position).normalized()
		shoot_current_weapon(direction2)

		
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
		print("Recargando revolver...")
		await get_tree().create_timer(revolver_reload_time).timeout
		current_revolver_ammo = max_revolver_ammo
		is_reloading = false
		print("Recarga completa. Balas: ", current_revolver_ammo)

func start_reload_escopeta():
	if current_escopeta_ammo < max_escopeta_ammo and not is_reloading:
		is_reloading = true
		print("Recargando escopeta...")
		await get_tree().create_timer(escopeta_reload_time).timeout
		current_escopeta_ammo = max_escopeta_ammo
		is_reloading = false
		print("Recarga completa. Balas: ", current_escopeta_ammo)

func select_weapon(index: int):
	current_weapon_index = index
	if index >= weapon_list.size():
		return
	for i in range(weapon_list.size()):
		weapon_list[i].visible = (i == index)
	current_weapon = weapon_list[index]
